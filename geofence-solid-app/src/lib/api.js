// src/lib/api.js
import { authHelpers } from "./supabase";

// Your new Node.js server's address
const API_URL = "https://vouch-backend-1.onrender.com/api";

const getAuthHeaders = async () => {
  const { session } = await authHelpers.getSession();
  if (!session) throw new Error("Not authenticated");
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${session.access_token}`,
  };
};

const handleResponse = async (response) => {
  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(
      errorData.error || `HTTP error! status: ${response.status}`
    );
  }
  if (response.status === 204) return null; // For DELETE requests
  return response.json();
};

export const api = {
  // Profile (for ProfilePage.jsx)
  getProfile: async () => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/my-profile`, { headers });
    return handleResponse(response);
  },
  updateProfile: async (profileData) => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/my-profile`, {
      method: "PUT",
      headers,
      body: JSON.stringify(profileData),
    });
    return handleResponse(response);
  },

  // Locations (for LocationsPage.jsx)
  getLocations: async () => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/locations`, { headers });
    return handleResponse(response);
  },
  createLocation: async (locationData) => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/locations`, {
      method: "POST",
      headers,
      body: JSON.stringify(locationData),
    });
    return handleResponse(response);
  },
  updateLocation: async (id, locationData) => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/locations/${id}`, {
      method: "PUT",
      headers,
      body: JSON.stringify(locationData),
    });
    return handleResponse(response);
  },
  deleteLocation: async (id) => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/locations/${id}`, {
      method: "DELETE",
      headers,
    });
    return handleResponse(response);
  },

  // Campaigns (for CampaignsPage.jsx)
  getCampaigns: async () => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/campaigns`, { headers });
    return handleResponse(response);
  },
  createCampaign: async (campaignData) => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/campaigns`, {
      method: "POST",
      headers,
      body: JSON.stringify(campaignData),
    });
    return handleResponse(response);
  },
  updateCampaign: async (id, campaignData) => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/campaigns/${id}`, {
      method: "PUT",
      headers,
      body: JSON.stringify(campaignData),
    });
    return handleResponse(response);
  },
  deleteCampaign: async (id) => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/campaigns/${id}`, {
      method: "DELETE",
      headers,
    });
    return handleResponse(response);
  },

  // For the CampaignModal dropdown
  getRewards: async () => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/rewards`, { headers });
    return handleResponse(response);
  },

  // For AnalyticsPage.jsx
  getStats: async () => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/analytics/stats`, { headers });
    return handleResponse(response);
  },

  // For ScannerPage.jsx
  redeemReward: async (token) => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/rewards/redeem`, {
      method: "POST",
      headers,
      body: JSON.stringify({ unique_token: token }),
    });
    // We don't use handleResponse here because we want to
    // read the error JSON even on a 404 or 409
    return response.json();
  },

  // --- THIS IS THE NEW FUNCTION THAT WAS MISSING ---
  getReviews: async () => {
    const headers = await getAuthHeaders();
    const response = await fetch(`${API_URL}/reviews`, { headers });
    return handleResponse(response);
  },
  // --- END NEW FUNCTION ---
};
