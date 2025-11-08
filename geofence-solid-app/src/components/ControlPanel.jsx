import { createSignal, Show, For, createEffect, onCleanup } from "solid-js";

function ControlPanel(props) {
  const [showDrawOptions, setShowDrawOptions] = createSignal(false);

  // search state
  const [searchQuery, setSearchQuery] = createSignal("");
  const [searching, setSearching] = createSignal(false);
  const [searchResults, setSearchResults] = createSignal([]);

  const hasShape = () => props.currentShape() !== null;

  // --- THIS IS THE FIX ---
  // We remove canSubmit() and handleSubmit()
  // as they are no longer needed.
  // -----------------------

  const actions = () =>
    typeof props.mapActions === "function" ? props.mapActions() : null;

  const handleDrawMenuClick = () => setShowDrawOptions(!showDrawOptions());

  const handleShapeSelect = (shapeType) => {
    setShowDrawOptions(false);
    const a = actions();
    if (a?.drawShape) {
      a.drawShape(shapeType);
      props.setStatusText?.(`Drawing ${shapeType}...`);
    } else {
      props.setStatusText?.("Map not ready yet. Please wait.");
    }
  };

  const handleEdit = () => {
    const a = actions();
    if (a?.editShape) a.editShape();
    else props.setStatusText?.("Map not ready yet. Please wait.");
  };

  const handleClear = () => {
    const a = actions();
    if (a?.clearShape) a.clearShape();
    props.setBusinessName("");
  };

  const handleLocateMe = () => {
    const a = actions();
    if (a?.locateMe) a.locateMe();
    else props.setStatusText?.("Map not ready yet. Please wait.");
  };

  // Real-time debounced search (replaces manual Search button)
  const doSearch = async (q) => {
    if (!q) {
      setSearchResults([]);
      return;
    }
    setSearching(true);
    setSearchResults([]);
    try {
      const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(
        q
      )}&limit=5`;
      const res = await fetch(url, { headers: { Accept: "application/json" } });
      const data = await res.json();
      setSearchResults(Array.isArray(data) ? data : []);
    } catch (e) {
      console.error("[v0] Search error:", e);
    } finally {
      setSearching(false);
    }
  };

  createEffect(() => {
    const q = searchQuery().trim();
    const id = setTimeout(() => doSearch(q), 350);
    onCleanup(() => clearTimeout(id));
  });

  const goToResult = (item) => {
    const a = actions();
    if (a?.flyTo) {
      a.flyTo(item.lat, item.lon, 15);
    }
  };

  // --- THIS IS THE FIX ---
  // The entire handleSubmit function has been REMOVED.
  // -----------------------

  return (
    <aside id="control-panel" class="sidebar">
      {/* Section 1: Location */}
      <section class="panel-section">
        <h4 class="section-title">Location</h4>
        <button
          class="control-button btn-primary"
          onClick={handleLocateMe}
          aria-label="Use current location"
        >
          Use Current Location
        </button>

        <div class="search-block">
          <input
            type="text"
            class="input-field search-input"
            placeholder="Search place, city, address…"
            value={searchQuery()}
            onInput={(e) => setSearchQuery(e.target.value)}
            aria-label="Search location"
          />
          <Show when={searching()}>
            <div class="search-hint">Searching…</div>
          </Show>
          <Show when={searchResults().length > 0}>
            <div class="search-results">
              <For each={searchResults()}>
                {(item) => (
                  <button
                    class="result-item"
                    onClick={() => goToResult(item)}
                    title={item.display_name}
                  >
                    {item.display_name}
                  </button>
                )}
              </For>
            </div>
          </Show>
        </div>
      </section>

      {/* Section 2: Geofencing */}
      <section class="panel-section">
        <h4 class="section-title">Geofencing</h4>

        <div class="dropdown">
          <button
            id="drawMenuBtn"
            class="control-button btn-secondary"
            onClick={handleDrawMenuClick}
            disabled={hasShape()}
          >
            Draw New Geofence ▼
          </button>

          <Show when={showDrawOptions()}>
            <div id="draw-options" class="show">
              <a href="#" onClick={() => handleShapeSelect("polygon")}>
                Polygon
              </a>
              <a href="#" onClick={() => handleShapeSelect("rectangle")}>
                Rectangle
              </a>
              <a href="#" onClick={() => handleShapeSelect("circle")}>
                Circle
              </a>
            </div>
          </Show>
        </div>

        <div class="row">
          <button
            id="editBtn"
            class="control-button btn-primary"
            onClick={handleEdit}
            disabled={!hasShape()}
          >
            Edit Shape
          </button>
          <button
            id="clearBtn"
            class="control-button btn-ghost"
            onClick={handleClear}
            disabled={!hasShape()}
          >
            Clear Shape
          </button>
        </div>
      </section>

      {/* Section 3: Details */}
      <section class="panel-section">
        <h4 class="section-title">Details</h4>
        <input
          type="text"
          id="businessNameInput"
          class="input-field"
          placeholder="Enter Business Name…"
          value={props.businessName()}
          onInput={(e) => props.setBusinessName(e.target.value)}
          disabled={!hasShape()}
        />
      </section>

      {/* --- THIS IS THE FIX ---
        Section 4: Submit has been REMOVED.
      ----------------------- */}
    </aside>
  );
}

export default ControlPanel;
