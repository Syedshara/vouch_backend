// src/pages/LocationsPage.jsx
"use client";

import { createSignal, onMount, For, Show } from "solid-js";
import { api } from "../lib/api"; // <-- IMPORT NEW API HELPER
import GeofenceMap from "../components/GeofenceMap";
import ControlPanel from "../components/ControlPanel";
import LocationModal from "../components/LocationModal";

export default function LocationsPage() {
  const [locations, setLocations] = createSignal([]);
  const [selectedLocation, setSelectedLocation] = createSignal(null);
  const [isCreating, setIsCreating] = createSignal(false);
  const [isEditing, setIsEditing] = createSignal(false);
  const [loading, setLoading] = createSignal(true);

  // Geofence editor state
  const [currentShape, setCurrentShape] = createSignal(null);
  const [statusText, setStatusText] = createSignal("Idle");
  const [businessName, setBusinessName] = createSignal("");
  const [geoJsonOutput, setGeoJsonOutput] = createSignal("No shape drawn yet.");
  const [isDrawing, setIsDrawing] = createSignal(false);
  const [mapActions, setMapActions] = createSignal(null);

  const [address, setAddress] = createSignal("");
  const [category, setCategory] = createSignal("Restaurant");
  const [dwellTime, setDwellTime] = createSignal(5);

  onMount(async () => {
    await loadLocations();
  });

  const loadLocations = async () => {
    setLoading(true);
    try {
      // --- THIS IS THE FIX ---
      const data = await api.getLocations();
      setLocations(data);
    } catch (error) {
      setStatusText(`Error: ${error?.message}`);
    }
    setLoading(false);
  };

  const handleCreateNew = () => {
    setIsCreating(true);
    setIsEditing(false);
    setSelectedLocation(null);
    setCurrentShape(null);
    setBusinessName("");
    setAddress("");
    setCategory("Restaurant");
    setDwellTime(5);
    setGeoJsonOutput("No shape drawn yet.");
    mapActions()?.clearShape();
  };

  const handleEditLocation = (location) => {
    setSelectedLocation(location);
    setIsEditing(true);
  };

  const handleDeleteLocation = async (locationId) => {
    if (!confirm("Are you sure you want to delete this location?")) return;
    try {
      // --- THIS IS THE FIX ---
      await api.deleteLocation(locationId);
      await loadLocations();
      setStatusText("Location deleted successfully!");
    } catch (error) {
      setStatusText(`Error: ${error?.message}`);
    }
  };

  const handleToggleActive = async (location) => {
    try {
      // --- THIS IS THE FIX ---
      // Send *only* the change
      await api.updateLocation(location.id, {
        is_active: !location.is_active,
      });
      await loadLocations();
    } catch (error) {
      setStatusText(`Error: ${error?.message}`);
    }
  };

  const handleSaveLocation = async () => {
    if (!currentShape()) {
      setStatusText("Error: Please draw a geofence on the map first.");
      return;
    }
    if (!businessName()) {
      setStatusText("Error: Please enter a Location Name.");
      return;
    }

    const geofenceData = JSON.parse(geoJsonOutput());

    const locationData = {
      name: businessName(),
      address: address(),
      category: category(),
      geofence: geofenceData, // Send the full GeoJSON Feature
      dwell_time_minutes: dwellTime(),
    };

    try {
      // --- THIS IS THE FIX ---
      await api.createLocation(locationData);
      await loadLocations();
      setIsCreating(false);
      setStatusText("Location saved successfully!");
    } catch (error) {
      setStatusText(`Error: ${error?.message}`);
    }
  };

  const handleUpdateLocation = async (updatedData) => {
    try {
      // --- THIS IS THE FIX ---
      await api.updateLocation(selectedLocation().id, updatedData);
      await loadLocations();
      setIsEditing(false);
      setSelectedLocation(null);
      setStatusText("Location updated successfully!");
    } catch (error) {
      setStatusText(`Error: ${error?.message}`);
    }
  };

  // ... (Your JSX remains identical) ...
  return (
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="page-title">Locations</h1>
          <p class="page-subtitle">
            Manage your business locations and geofences
          </p>
        </div>
        <button class="btn-primary" onClick={handleCreateNew}>
          Add Location
        </button>
      </div>
      <Show
        when={!loading()}
        fallback={<div class="loading">Loading locations...</div>}
      >
        <div class="geofence-editor">
          <div class="editor-sidebar">
            <Show when={isCreating()}>
              <div class="editor-form">
                <h3 class="editor-form-title">Location Details</h3>
                <div class="form-group">
                  <label class="form-label">Location Name</label>
                  <input
                    type="text"
                    class="form-input"
                    placeholder="My Coffee Shop"
                    value={businessName()}
                    onInput={(e) => setBusinessName(e.target.value)}
                  />
                </div>
                <div class="form-group">
                  <label class="form-label">Address</label>
                  <input
                    type="text"
                    class="form-input"
                    placeholder="123 Main St, City, State"
                    value={address()}
                    onInput={(e) => setAddress(e.target.value)}
                  />
                </div>
                <div class="form-group">
                  <label class="form-label">Category</label>
                  <select
                    class="form-input"
                    value={category()}
                    onChange={(e) => setCategory(e.target.value)}
                  >
                    <option value="Restaurant">Restaurant</option>
                    <option value="Retail">Retail</option>
                    <option value="Cafe">Cafe</option>
                    <option value="Gym">Gym</option>
                    <option value="Salon">Salon</option>
                    <option value="Hotel">Hotel</option>
                    <option value="Other">Other</option>
                  </select>
                </div>
                <div class="form-group">
                  <label class="form-label">Dwell Time (minutes)</label>
                  <input
                    type="number"
                    class="form-input"
                    min="1"
                    max="60"
                    value={dwellTime()}
                    onInput={(e) =>
                      setDwellTime(Number.parseInt(e.target.value) || 5)
                    }
                  />
                  <p class="form-hint">
                    Minimum time a customer must spend to earn a vouch
                  </p>
                </div>
                <div class="editor-actions">
                  <button
                    class="btn-secondary"
                    onClick={() => setIsCreating(false)}
                  >
                    Cancel
                  </button>
                  <button
                    class="btn-primary"
                    onClick={handleSaveLocation}
                    disabled={!currentShape() || !businessName()}
                  >
                    Save Location
                  </button>
                </div>
              </div>
              <ControlPanel
                currentShape={currentShape}
                setCurrentShape={setCurrentShape}
                statusText={statusText}
                setStatusText={setStatusText}
                businessName={businessName}
                setBusinessName={setBusinessName}
                geoJsonOutput={geoJsonOutput}
                setGeoJsonOutput={setGeoJsonOutput}
                isDrawing={isDrawing}
                setIsDrawing={setIsDrawing}
                mapActions={mapActions}
              />
            </Show>
            <Show when={!isCreating()}>
              <Show
                when={locations().length > 0}
                fallback={
                  <div class="empty-state">
                    <svg
                      class="empty-icon"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                    >
                      <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                      <circle cx="12" cy="10" r="3" />
                    </svg>
                    <h3 class="empty-title">No locations yet</h3>
                    <p class="empty-text">
                      Click "Add Location" to create your first geofence
                    </p>
                  </div>
                }
              >
                <div
                  style={{
                    "overflow-y": "auto",
                    "max-height": "calc(100vh - 16rem)",
                  }}
                >
                  <For each={locations()}>
                    {(location) => (
                      <div
                        class="location-card"
                        style={{ "margin-bottom": "1rem" }}
                      >
                        <div class="location-card-header">
                          <h3 class="location-card-title">{location.name}</h3>
                          <span
                            class={`status-badge ${
                              location.is_active ? "active" : "inactive"
                            }`}
                          >
                            {location.is_active ? "Active" : "Inactive"}
                          </span>
                        </div>
                        <p class="location-card-text">{location.address}</p>
                        <div class="location-card-meta-row">
                          <span class="location-card-meta">
                            <svg
                              class="meta-icon"
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                            >
                              <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z" />
                            </svg>
                            {location.category}
                          </span>
                          <span class="location-card-meta">
                            <svg
                              class="meta-icon"
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                            >
                              <circle cx="12" cy="12" r="10" />
                              <polyline points="12 6 12 12 16 14" />
                            </svg>
                            {location.dwell_time_minutes} min
                          </span>
                        </div>
                        <div class="location-card-actions">
                          <button
                            class="btn-icon-sm"
                            onClick={() => handleToggleActive(location)}
                            title={
                              location.is_active ? "Deactivate" : "Activate"
                            }
                          >
                            <svg
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                            >
                              <circle cx="12" cy="12" r="10" />
                              <line x1="12" y1="8" x2="12" y2="12" />
                              <line x1="12" y1="16" x2="12.01" y2="16" />
                            </svg>
                          </button>
                          <button
                            class="btn-icon-sm"
                            onClick={() => handleEditLocation(location)}
                            title="Edit"
                          >
                            <svg
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                            >
                              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                              <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                            </svg>
                          </button>
                          <button
                            class="btn-icon-sm danger"
                            onClick={() => handleDeleteLocation(location.id)}
                            title="Delete"
                          >
                            <svg
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                            >
                              <polyline points="3 6 5 6 21 6" />
                              <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                            </svg>
                          </button>
                        </div>
                      </div>
                    )}
                  </For>
                </div>
              </Show>
            </Show>
          </div>
          <div class="map-container">
            <GeofenceMap
              currentShape={currentShape}
              setCurrentShape={setCurrentShape}
              setStatusText={setStatusText}
              setGeoJsonOutput={setGeoJsonOutput}
              isDrawing={isDrawing}
              setIsDrawing={setIsDrawing}
              registerActions={setMapActions}
            />
          </div>
        </div>
      </Show>
      <Show when={isEditing()}>
        <LocationModal
          location={selectedLocation()}
          onClose={() => {
            setIsEditing(false);
            setSelectedLocation(null);
          }}
          onSave={handleUpdateLocation}
        />
      </Show>
    </div>
  );
}
