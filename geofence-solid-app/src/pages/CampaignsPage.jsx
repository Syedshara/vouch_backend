// src/pages/CampaignsPage.jsx
import { createSignal, onMount, For, Show } from "solid-js";
import { api } from "../lib/api"; // <-- IMPORT NEW API HELPER
import CampaignModal from "../components/CampaignModal";

export default function CampaignsPage() {
  const [campaigns, setCampaigns] = createSignal([]);
  const [locations, setLocations] = createSignal([]);
  const [rewards, setRewards] = createSignal([]); // <-- ADD THIS
  const [loading, setLoading] = createSignal(true);
  const [isCreating, setIsCreating] = createSignal(false);
  const [isEditing, setIsEditing] = createSignal(false);
  const [selectedCampaign, setSelectedCampaign] = createSignal(null);

  onMount(async () => {
    setLoading(true);
    // Load locations, campaigns, AND rewards
    await Promise.all([loadCampaigns(), loadLocations(), loadRewards()]); // <-- ADD loadRewards()
    setLoading(false);
  });

  const loadCampaigns = async () => {
    try {
      const data = await api.getCampaigns();
      setCampaigns(data);
    } catch (error) {
      console.error("Error loading campaigns:", error);
    }
  };

  const loadLocations = async () => {
    try {
      const data = await api.getLocations();
      setLocations(data.filter((loc) => loc.is_active));
    } catch (error) {
      console.error("Error loading locations:", error);
    }
  };

  // --- ADD THIS NEW FUNCTION ---
  const loadRewards = async () => {
    try {
      const data = await api.getRewards();
      setRewards(data);
    } catch (error) {
      console.error("Error loading rewards:", error);
    }
  };
  // --- END NEW FUNCTION ---

  const handleCreateCampaign = async (campaignData) => {
    try {
      await api.createCampaign(campaignData);
      await loadCampaigns();
      setIsCreating(false);
    } catch (error) {
      console.error("Error creating campaign:", error);
      alert(`Error: ${error.message}`);
    }
  };

  const handleUpdateCampaign = async (campaignData) => {
    try {
      await api.updateCampaign(selectedCampaign().id, campaignData);
      await loadCampaigns();
      setIsEditing(false);
      setSelectedCampaign(null);
    } catch (error) {
      console.error("Error updating campaign:", error);
      alert(`Error: ${error.message}`);
    }
  };

  const handleDeleteCampaign = async (campaignId) => {
    if (!confirm("Are you sure you want to delete this campaign?")) return;
    try {
      await api.deleteCampaign(campaignId);
      await loadCampaigns();
    } catch (error) {
      console.error("Error deleting campaign:", error);
    }
  };

  const handleToggleActive = async (campaign) => {
    try {
      // This is correct because our backend PUT just updates req.body
      await api.updateCampaign(campaign.id, {
        is_active: !campaign.is_active,
      });
      await loadCampaigns();
    } catch (error) {
      console.error("Error toggling campaign:", error);
    }
  };

  const getCampaignTypeLabel = (type) => {
    const labels = {
      visit_count: "Visit Count",
      spend_amount: "Spend Amount",
      referral: "Referral",
      time_based: "Time Based",
    };
    return labels[type] || type;
  };

  // ... (Your JSX remains identical) ...
  return (
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="page-title">Campaigns</h1>
          <p class="page-subtitle">Manage loyalty campaigns and rewards</p>
        </div>
        <button class="btn-primary" onClick={() => setIsCreating(true)}>
          Create Campaign
        </button>
      </div>
      <Show
        when={!loading()}
        fallback={<div class="loading">Loading campaigns...</div>}
      >
        <Show
          when={campaigns().length > 0}
          fallback={
            <div class="empty-state">
              <svg
                class="empty-icon"
                viewBox="0 0 24"
                fill="none"
                stroke="currentColor"
              >
                <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z" />
                <line x1="7" y1="7" x2="7.01" y2="7" />
              </svg>
              <h3 class="empty-title">No campaigns yet</h3>
              <p class="empty-text">
                Create your first loyalty campaign to start rewarding customers
              </p>
              <button class="btn-primary" onClick={() => setIsCreating(true)}>
                Create Campaign
              </button>
            </div>
          }
        >
          <div class="campaigns-grid">
            <For each={campaigns()}>
              {(campaign) => (
                <div class="campaign-card">
                  <div class="campaign-card-header">
                    <div>
                      <h3 class="campaign-card-title">{campaign.name}</h3>
                      <span class="campaign-type-badge">
                        {getCampaignTypeLabel(campaign.campaign_type)}
                      </span>
                    </div>
                    <span
                      class={`status-badge ${
                        campaign.is_active ? "active" : "inactive"
                      }`}
                    >
                      {campaign.is_active ? "Active" : "Inactive"}
                    </span>
                  </div>
                  <p class="campaign-card-description">
                    {campaign.description}
                  </p>
                  <div class="campaign-card-details">
                    <div class="campaign-detail-item">
                      <span class="detail-label">Reward</span>
                      <span class="detail-value">
                        {campaign.reward_description}
                      </span>
                    </div>
                    <div class="campaign-detail-item">
                      <span class="detail-label">Target</span>
                      <span class="detail-value">{campaign.target_value}</span>
                    </div>
                    <Show when={campaign.locations}>
                      <div class="campaign-detail-item">
                        <span class="detail-label">Location</span>
                        <span class="detail-value">
                          {campaign.locations.name}
                        </span>
                      </div>
                    </Show>
                  </div>
                  <div class="campaign-card-dates">
                    <span class="date-text">
                      {new Date(campaign.start_date).toLocaleDateString()} -{" "}
                      {new Date(campaign.end_date).toLocaleDateString()}
                    </span>
                  </div>
                  <div class="campaign-card-actions">
                    <button
                      class="btn-icon-sm"
                      onClick={() => handleToggleActive(campaign)}
                      title={campaign.is_active ? "Deactivate" : "Activate"}
                    >
                      <svg viewBox="0 0 24" fill="none" stroke="currentColor">
                        <circle cx="12" cy="12" r="10" />
                        <line x1="12" y1="8" x2="12" y2="12" />
                        <line x1="12" y1="16" x2="12.01" y2="16" />
                      </svg>
                    </button>
                    <button
                      class="btn-icon-sm"
                      onClick={() => {
                        setSelectedCampaign(campaign);
                        setIsEditing(true);
                      }}
                      title="Edit"
                    >
                      <svg viewBox="0 0 24" fill="none" stroke="currentColor">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                      </svg>
                    </button>
                    <button
                      class="btn-icon-sm danger"
                      onClick={() => handleDeleteCampaign(campaign.id)}
                      title="Delete"
                    >
                      <svg viewBox="0 0 24" fill="none" stroke="currentColor">
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
      <Show when={isCreating()}>
        <CampaignModal
          locations={locations()}
          rewards={rewards()}
          onClose={() => setIsCreating(false)}
          onSave={handleCreateCampaign}
        />
      </Show>
      <Show when={isEditing()}>
        <CampaignModal
          campaign={selectedCampaign()}
          locations={locations()}
          rewards={rewards()}
          onClose={() => {
            setIsEditing(false);
            setSelectedCampaign(null);
          }}
          onSave={handleUpdateCampaign}
        />
      </Show>
    </div>
  );
}
