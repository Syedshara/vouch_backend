import { createSignal, onMount } from "solid-js";

export default function LocationModal(props) {
  const [name, setName] = createSignal("");
  const [address, setAddress] = createSignal("");
  const [category, setCategory] = createSignal("Restaurant");
  const [dwellTime, setDwellTime] = createSignal(5);
  const [isActive, setIsActive] = createSignal(true);

  onMount(() => {
    if (props.location) {
      setName(props.location.name);
      setAddress(props.location.address);
      setCategory(props.location.category);
      setDwellTime(props.location.dwell_time_minutes);
      setIsActive(props.location.is_active);
    }
  });

  const handleSave = () => {
    props.onSave({
      name: name(),
      address: address(),
      category: category(),
      dwell_time_minutes: dwellTime(),
      is_active: isActive(),
    });
  };

  return (
    <div class="modal-overlay" onClick={props.onClose}>
      <div class="modal-content" onClick={(e) => e.stopPropagation()}>
        <div class="modal-header">
          <h2 class="modal-title">Edit Location</h2>
          <button class="modal-close" onClick={props.onClose}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Location Name</label>
            <input
              type="text"
              class="form-input"
              value={name()}
              onInput={(e) => setName(e.target.value)}
            />
          </div>

          <div class="form-group">
            <label class="form-label">Address</label>
            <input
              type="text"
              class="form-input"
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
          </div>

          <div class="form-group-checkbox">
            <input
              type="checkbox"
              id="isActive"
              checked={isActive()}
              onChange={(e) => setIsActive(e.target.checked)}
            />
            <label for="isActive" class="form-label-checkbox">
              Location is active
            </label>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn-secondary" onClick={props.onClose}>
            Cancel
          </button>
          <button class="btn-primary" onClick={handleSave}>
            Save Changes
          </button>
        </div>
      </div>
    </div>
  );
}
