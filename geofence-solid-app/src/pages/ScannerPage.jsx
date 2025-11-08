// src/pages/ScannerPage.jsx
import { createSignal, onMount, onCleanup, Show } from "solid-js";
import { Html5QrcodeScanner } from "html5-qrcode";
import { api } from "../lib/api";

export default function ScannerPage() {
  const [scanResult, setScanResult] = createSignal(null);
  const [scanError, setScanError] = createSignal(null);
  const [isScanning, setIsScanning] = createSignal(true);
  let html5QrcodeScanner;

  const onScanSuccess = async (decodedText, decodedResult) => {
    // We have a result! Pause the scanner.
    if (isScanning()) {
      setIsScanning(false);
      setScanError(null);
      setScanResult("Verifying token...");

      try {
        // Call the API endpoint you built
        const result = await api.redeemReward(decodedText);

        if (result.error) {
          // Handle API errors (Not found, already redeemed, etc.)
          setScanError(result.error);
          setScanResult(null);
        } else {
          // Success!
          setScanResult(
            `Success! Redeemed: ${result.reward.reward_description}`
          );
        }
      } catch (e) {
        setScanError(`Scan Error: ${e.message}`);
        setScanResult(null);
      }

      // Resume scanning after 3 seconds
      setTimeout(() => {
        setScanError(null);
        setScanResult(null);
        setIsScanning(true);
      }, 3000);
    }
  };

  const onScanFailure = (error) => {
    // This is called a lot, just ignore it.
  };

  onMount(() => {
    // Initialize the scanner
    html5QrcodeScanner = new Html5QrcodeScanner(
      "qr-reader",
      {
        fps: 10,
        qrbox: { width: 250, height: 250 },
      },
      false // verbose
    );
    html5QrcodeScanner.render(onScanSuccess, onScanFailure);
  });

  onCleanup(() => {
    // Stop the scanner when the component is unmounted
    if (html5QrcodeScanner) {
      html5QrcodeScanner.clear().catch((error) => {
        console.error("Failed to clear html5QrcodeScanner.", error);
      });
    }
  });

  return (
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="page-title">Voucher Scanner</h1>
          <p class="page-subtitle">
            Scan a customer's QR code to redeem their voucher
          </p>
        </div>
      </div>

      <div class="scanner-card">
        {/* The scanner viewfinder will be rendered here */}
        <div id="qr-reader" />

        <div class="scanner-status">
          <Show when={scanResult()}>
            <div class="scanner-message success">{scanResult()}</div>
          </Show>
          <Show when={scanError()}>
            <div class="scanner-message error">{scanError()}</div>
          </Show>
          <Show when={!scanResult() && !scanError() && isScanning()}>
            <div class="scanner-message default">
              Point your camera at a customer's QR code
            </div>
          </Show>
        </div>
      </div>
    </div>
  );
}
