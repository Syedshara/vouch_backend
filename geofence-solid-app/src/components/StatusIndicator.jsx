function StatusIndicator(props) {
  return (
    <>
      <div id="status-indicator">
        <strong>Status:</strong>{" "}
        <span id="statusText">{props.statusText()}</span>
      </div>

      <div id="output-container">
        <strong>GeoJSON Output:</strong>
        <pre id="output">{props.geoJsonOutput()}</pre>
      </div>
    </>
  );
}

export default StatusIndicator;
