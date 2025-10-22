import { createSignal, onMount } from "solid-js";

export default function CampaignModal(props) {
  const [name, setName] = createSignal("");
  const [description, setDescription] = createSignal("");
  const [campaignType, setCampaignType] = createSignal("visit_count");
  const [targetValue, setTargetValue] = createSignal(5);
  const [rewardDescription, setRewardDescription] = createSignal("");
  const [locationId, setLocationId] = createSignal("");
  const [startDate, setStartDate] = createSignal("");
  const [endDate, setEndDate] = createSignal("");
  const [isActive, setIsActive] = createSignal(true);

  onMount(() => {
    if (props.campaign) {
      setName(props.campaign.name);
      setDescription(props.campaign.description || "");
      setCampaignType(props.campaign.campaign_type);
      setTargetValue(props.campaign.target_value);
      setRewardDescription(props.campaign.reward_description);
      setLocationId(props.campaign.location_id || "");
      setStartDate(props.campaign.start_date?.split("T")[0] || "");
      setEndDate(props.campaign.end_date?.split("T")[0] || "");
      setIsActive(props.campaign.is_active);
    } else {
      // Set default dates for new campaigns
      const today = new Date().toISOString().split("T")[0];
      const nextMonth = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
        .toISOString()
        .split("T")[0];
      setStartDate(today);
      setEndDate(nextMonth);
    }
  });

  const handleSave = () => {
    if (!name() || !rewardDescription() || !startDate() || !endDate()) {
      alert("Please fill in all required fields");
      return;
    }

    props.onSave({
      name: name(),
      description: description(),
      campaign_type: campaignType(),
      target_value: targetValue(),
      reward_description: rewardDescription(),
      location_id: locationId() || null,
      start_date: startDate(),
      end_date: endDate(),
      is_active: isActive(),
    });
  };

  return (
    <div class="modal-overlay" onClick={props.onClose}>
      <div
        class="modal-content modal-large"
        onClick={(e) => e.stopPropagation()}
      >
        <div class="modal-header">
          <h2 class="modal-title">
            {props.campaign ? "Edit Campaign" : "Create Campaign"}
          </h2>
          <button class="modal-close" onClick={props.onClose}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">Campaign Name *</label>
            <input
              type="text"
              class="form-input"
              placeholder="Buy 5 Get 1 Free"
              value={name()}
              onInput={(e) => setName(e.target.value)}
            />
          </div>

          <div class="form-group">
            <label class="form-label">Description</label>
            <textarea
              class="form-input"
              rows="3"
              placeholder="Describe your campaign..."
              value={description()}
              onInput={(e) => setDescription(e.target.value)}
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="form-label">Campaign Type *</label>
              <select
                class="form-input"
                value={campaignType()}
                onChange={(e) => setCampaignType(e.target.value)}
              >
                <option value="visit_count">Visit Count</option>
                <option value="spend_amount">Spend Amount</option>
                <option value="referral">Referral</option>
                <option value="time_based">Time Based</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Target Value *</label>
              <input
                type="number"
                class="form-input"
                min="1"
                value={targetValue()}
                onInput={(e) =>
                  setTargetValue(Number.parseInt(e.target.value) || 1)
                }
              />
              <p class="form-hint">
                {campaignType() === "visit_count" &&
                  "Number of visits required"}
                {campaignType() === "spend_amount" && "Amount to spend"}
                {campaignType() === "referral" && "Number of referrals"}
                {campaignType() === "time_based" && "Days to complete"}
              </p>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Reward Description *</label>
            <input
              type="text"
              class="form-input"
              placeholder="Free coffee, 20% off, etc."
              value={rewardDescription()}
              onInput={(e) => setRewardDescription(e.target.value)}
            />
          </div>

          <div class="form-group">
            <label class="form-label">Location (Optional)</label>
            <select
              class="form-input"
              value={locationId()}
              onChange={(e) => setLocationId(e.target.value)}
            >
              <option value="">All Locations</option>
              {props.locations.map((loc) => (
                <option key={loc.id} value={loc.id}>
                  {loc.name}
                </option>
              ))}
            </select>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="form-label">Start Date *</label>
              <input
                type="date"
                class="form-input"
                value={startDate()}
                onInput={(e) => setStartDate(e.target.value)}
              />
            </div>

            <div class="form-group">
              <label class="form-label">End Date *</label>
              <input
                type="date"
                class="form-input"
                value={endDate()}
                onInput={(e) => setEndDate(e.target.value)}
              />
            </div>
          </div>

          <div class="form-group-checkbox">
            <input
              type="checkbox"
              id="campaignActive"
              checked={isActive()}
              onChange={(e) => setIsActive(e.target.checked)}
            />
            <label for="campaignActive" class="form-label-checkbox">
              Campaign is active
            </label>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn-secondary" onClick={props.onClose}>
            Cancel
          </button>
          <button class="btn-primary" onClick={handleSave}>
            {props.campaign ? "Save Changes" : "Create Campaign"}
          </button>
        </div>
      </div>
    </div>
  );
}
