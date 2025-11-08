// src/pages/ProfilePage.jsx
import { createSignal, onMount } from "solid-js";
import { authHelpers } from "../lib/supabase";
import { api } from "../lib/api"; // <-- IMPORT NEW API HELPER

export default function ProfilePage() {
  const [businessName, setBusinessName] = createSignal("");
  const [email, setEmail] = createSignal("");
  const [phone, setPhone] = createSignal("");
  const [website, setWebsite] = createSignal("");
  const [description, setDescription] = createSignal("");
  const [loading, setLoading] = createSignal(true);
  const [saving, setSaving] = createSignal(false);
  const [message, setMessage] = createSignal({ type: "", text: "" });

  onMount(async () => {
    await loadProfile();
  });

  const loadProfile = async () => {
    setLoading(true);
    try {
      // --- THIS IS THE FIX ---
      const data = await api.getProfile();
      setBusinessName(data.business_name || "");
      setEmail(data.email || "");
      setPhone(data.phone || "");
      setWebsite(data.website || "");
      setDescription(data.description || "");
    } catch (error) {
      setMessage({ type: "error", text: error.message });
      // Fallback if no profile, get email from auth
      const { user } = await authHelpers.getUser();
      if (user) setEmail(user.email || "");
    }
    setLoading(false);
  };

  const handleSave = async () => {
    setSaving(true);
    setMessage({ type: "", text: "" });

    const profileData = {
      business_name: businessName(),
      email: email(),
      phone: phone(),
      website: website(),
      description: description(),
    };

    try {
      // --- THIS IS THE FIX ---
      await api.updateProfile(profileData);
      setMessage({ type: "success", text: "Profile saved successfully!" });
      setTimeout(() => setMessage({ type: "", text: "" }), 3000);
    } catch (error) {
      setMessage({
        type: "error",
        text: "Failed to save profile. Please try again.",
      });
    }

    setSaving(false);
  };

  const handleSignOut = async () => {
    await authHelpers.signOut();
    window.location.href = "/login"; // Use window.location to force full reload
  };

  // ... (Your JSX remains identical) ...
  return (
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="page-title">Business Profile</h1>
          <p class="page-subtitle">
            Manage your business information and settings
          </p>
        </div>
      </div>
      {loading() ? (
        <div class="loading">Loading profile...</div>
      ) : (
        <div class="profile-card">
          <form
            class="profile-form"
            onSubmit={(e) => {
              e.preventDefault();
              handleSave();
            }}
          >
            <div class="form-group">
              <label class="form-label">Business Name</label>
              <input
                type="text"
                class="form-input"
                placeholder="Your Business Name"
                value={businessName()}
                onInput={(e) => setBusinessName(e.target.value)}
              />
            </div>
            <div class="form-group">
              <label class="form-label">Email</label>
              <input
                type="email"
                class="form-input"
                placeholder="business@example.com"
                value={email()}
                onInput={(e) => setEmail(e.target.value)}
              />
              <p class="form-hint">
                This email will be used for customer communications
              </p>
            </div>
            <div class="form-group">
              <label class="form-label">Phone</label>
              <input
                type="tel"
                class="form-input"
                placeholder="+1 (555) 123-4567"
                value={phone()}
                onInput={(e) => setPhone(e.target.value)}
              />
            </div>
            <div class="form-group">
              <label class="form-label">Website</label>
              <input
                type="url"
                class="form-input"
                placeholder="https://yourbusiness.com"
                value={website()}
                onInput={(e) => setWebsite(e.target.value)}
              />
            </div>
            <div class="form-group">
              <label class="form-label">Description</label>
              <textarea
                class="form-input"
                rows="4"
                placeholder="Tell customers about your business..."
                value={description()}
                onInput={(e) => setDescription(e.target.value)}
              />
            </div>
            {message().text && (
              <div class={`message ${message().type}`}>{message().text}</div>
            )}
            <div class="profile-actions">
              <button type="submit" class="btn-primary" disabled={saving()}>
                {saving() ? "Saving..." : "Save Changes"}
              </button>
              <button type="button" class="btn-danger" onClick={handleSignOut}>
                Sign Out
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
