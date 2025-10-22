import { For } from "solid-js";
import "./OtpInput.css"; // We will create this CSS file next

export default function OtpInput(props) {
  const numInputs = 6;

  const handleInput = (e, index) => {
    const value = e.target.value;
    props.onInput(
      (prev) => prev.substring(0, index) + value + prev.substring(index + 1)
    );

    // Auto-focus to the next input if a digit is entered
    if (value && e.target.nextElementSibling) {
      e.target.nextElementSibling.focus();
    }
  };

  const handleKeyDown = (e, index) => {
    // Handle backspace to move focus to the previous input
    if (
      e.key === "Backspace" &&
      !e.target.value &&
      e.target.previousElementSibling
    ) {
      e.target.previousElementSibling.focus();
    }
  };

  const handlePaste = (e) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData("text").slice(0, numInputs);
    props.onInput(pastedData);
  };

  return (
    <div class="otp-container">
      <For each={Array(numInputs).fill(0)}>
        {(_, index) => (
          <input
            class="otp-input"
            type="text"
            inputmode="numeric"
            maxlength="1"
            value={props.value().charAt(index()) || ""}
            onInput={(e) => handleInput(e, index())}
            onKeyDown={(e) => handleKeyDown(e, index())}
            onPaste={index() === 0 ? handlePaste : undefined} // Only handle paste on the first input
          />
        )}
      </For>
    </div>
  );
}
