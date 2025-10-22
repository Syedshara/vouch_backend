import { createSignal, onMount } from "solid-js";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import "leaflet-draw/dist/leaflet.draw.css";
import "leaflet-draw";

function GeofenceMap(props) {
  let mapContainer; // Reference to DOM element
  const [map, setMap] = createSignal(null);
  const [drawnItems, setDrawnItems] = createSignal(null);

  // new markers for location/search highlights
  let locationMarker = null;
  let searchMarker = null;

  onMount(() => {
    initializeMap();
  });

  const initializeMap = () => {
    const mapInstance = L.map(mapContainer, {
      scrollWheelZoom: true,
      zoomControl: true,
      keyboard: true,
      doubleClickZoom: true,
      dragging: true,
      touchZoom: true,
    }).setView([13.0827, 80.2707], 13);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
    }).addTo(mapInstance);

    const drawnItemsGroup = new L.FeatureGroup();
    mapInstance.addLayer(drawnItemsGroup);

    setupDrawControls(mapInstance, drawnItemsGroup);

    setMap(mapInstance);
    setDrawnItems(drawnItemsGroup);

    // important: fix black tiles after mount due to sizing
    setTimeout(() => mapInstance.invalidateSize(), 0);

    const actions = {
      drawShape,
      editShape,
      clearShape,
      locateMe, // new
      flyTo, // new
    };
    props.registerActions && props.registerActions(() => actions);
  };

  const setupDrawControls = (mapInstance, drawnItemsGroup) => {
    mapInstance.on(L.Draw.Event.CREATED, (event) => {
      const layer = event.layer;
      drawnItemsGroup.addLayer(layer);
      updateOutput(layer);
      props.setStatusText("Shape temporarily saved.");
    });

    mapInstance.on(L.Draw.Event.EDITED, (event) => {
      const layers = event.layers;
      layers.eachLayer((layer) => {
        updateOutput(layer);
      });
      props.setStatusText("Edits temporarily saved.");
    });
  };

  const updateOutput = (layer) => {
    props.setCurrentShape(layer);
    const geojsonData = layer.toGeoJSON();
    props.setGeoJsonOutput(JSON.stringify(geojsonData, null, 2));
  };

  const drawShape = (shapeType) => {
    const mapInstance = map();
    if (!mapInstance) return;

    props.setStatusText(`Drawing ${shapeType}...`);
    props.setIsDrawing(true);

    let drawHandler;
    const drawOptions = getDrawOptions();

    switch (shapeType) {
      case "polygon":
        drawHandler = new L.Draw.Polygon(mapInstance, drawOptions.polygon);
        break;
      case "rectangle":
        drawHandler = new L.Draw.Rectangle(mapInstance, drawOptions.rectangle);
        break;
      case "circle":
        drawHandler = new L.Draw.Circle(mapInstance, drawOptions.circle);
        break;
    }

    if (drawHandler) drawHandler.enable();
  };

  const getDrawOptions = () => ({
    polygon: {
      shapeOptions: {
        color: "#f0abfc", // light purplish pink border
        weight: 3,
        fillColor: "#7c3aed", // purple fill
        fillOpacity: 0.25,
      },
    },
    rectangle: {
      shapeOptions: {
        color: "#f0abfc",
        weight: 3,
        fillColor: "#7c3aed",
        fillOpacity: 0.25,
      },
    },
    circle: {
      shapeOptions: {
        color: "#f0abfc",
        weight: 3,
        fillColor: "#7c3aed",
        fillOpacity: 0.2,
      },
    },
  });

  const editShape = () => {
    const mapInstance = map();
    const drawnItemsGroup = drawnItems();
    if (!mapInstance || !drawnItemsGroup) return;

    const editHandler = new L.EditToolbar.Edit(mapInstance, {
      featureGroup: drawnItemsGroup,
    });
    editHandler.enable();
    props.setStatusText("Editing shape...");
  };

  const clearShape = () => {
    const drawnItemsGroup = drawnItems();
    if (drawnItemsGroup) drawnItemsGroup.clearLayers();
    props.setCurrentShape(null);
    props.setGeoJsonOutput("No shape drawn yet.");
    props.setStatusText("Idle");
  };

  const locateMe = () => {
    const mapInstance = map();
    if (!mapInstance) return;
    if (!navigator.geolocation) {
      props.setStatusText("Geolocation not supported.");
      return;
    }
    props.setStatusText("Locating…");
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const latlng = [pos.coords.latitude, pos.coords.longitude];
        mapInstance.flyTo(latlng, 15);
        if (!locationMarker) {
          locationMarker = L.circleMarker(latlng, {
            radius: 8,
            color: "#f0abfc",
            fillColor: "#f0abfc",
            fillOpacity: 0.7,
          }).addTo(mapInstance);
        } else {
          locationMarker.setLatLng(latlng);
        }
        props.setStatusText("Centered on your location.");
      },
      (err) => {
        console.error("[v0] Geolocation error:", err);
        props.setStatusText("Failed to get location.");
      },
      { enableHighAccuracy: true, timeout: 10000 }
    );
  };

  const flyTo = (lat, lon, zoom = 14) => {
    const mapInstance = map();
    if (!mapInstance) return;
    const latlng = [Number(lat), Number(lon)];
    mapInstance.flyTo(latlng, zoom);
    if (!searchMarker) {
      searchMarker = L.circleMarker(latlng, {
        radius: 7,
        color: "#a78bfa", // soft purple outline
        fillColor: "#f0abfc", // light purplish pink fill
        fillOpacity: 0.6,
      }).addTo(mapInstance);
    } else {
      searchMarker.setLatLng(latlng);
    }
    props.setStatusText("Moved to search result.");
  };

  return <div ref={mapContainer} id="map" />;
}

export default GeofenceMap;
