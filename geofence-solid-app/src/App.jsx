import { createSignal } from "solid-js"
import GeofenceMap from "./components/GeofenceMap"
import ControlPanel from "./components/ControlPanel"
import "./styles/geofence.css"

function App() {
  // Shared state between components
  const [currentShape, setCurrentShape] = createSignal(null)
  const [statusText, setStatusText] = createSignal("Idle")
  const [businessName, setBusinessName] = createSignal("")
  const [geoJsonOutput, setGeoJsonOutput] = createSignal("No shape drawn yet.")
  const [isDrawing, setIsDrawing] = createSignal(false)

  // New: wire map actions between Map and ControlPanel
  const [mapActions, setMapActions] = createSignal(null)

  return (
    <div class="app-container">
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
        // Pass mapActions to panel
        mapActions={mapActions}
      />

      <div class="main-content">
        <GeofenceMap
          currentShape={currentShape}
          setCurrentShape={setCurrentShape}
          setStatusText={setStatusText}
          setGeoJsonOutput={setGeoJsonOutput}
          isDrawing={isDrawing}
          setIsDrawing={setIsDrawing}
          // Register actions from map to parent
          registerActions={setMapActions}
        />
      </div>
    </div>
  )
}

export default App
