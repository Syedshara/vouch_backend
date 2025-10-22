import { createSignal, onMount } from "solid-js";
import { supabase, authHelpers } from "../lib/supabase";

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
    const { user } = await authHelpers.getUser();
    if (!user) return;

    const { data, error } = await supabase
      .from("business_profiles")
      .select("*")
      .eq("user_id", user.id)
      .single();

    if (data) {
      setBusinessName(data.business_name || "");
      setEmail(data.email || user.email || "");
      setPhone(data.phone || "");
      setWebsite(data.website || "");
      setDescription(data.description || "");
    } else if (!error || error.code === "PGRST116") {
      // No profile exists yet, use user email
      setEmail(user.email || "");
    }

    setLoading(false);
  };

  const handleSave = async () => {
    const { user } = await authHelpers.getUser();
    if (!user) return;

    setSaving(true);
    setMessage({ type: "", text: "" });

    const profileData = {
      user_id: user.id,
      business_name: businessName(),
      email: email(),
      phone: phone(),
      website: website(),
      description: description(),
    };

    // Check if profile exists
    const { data: existing } = await supabase
      .from("business_profiles")
      .select("id")
      .eq("user_id", user.id)
      .single();

    let error;

    if (existing) {
      // Update existing profile
      const result = await supabase
        .from("business_profiles")
        .update(profileData)
        .eq("user_id", user.id);
      error = result.error;
    } else {
      // Insert new profile
      const result = await supabase
        .from("business_profiles")
        .insert([profileData]);
      error = result.error;
    }

    if (error) {
      setMessage({
        type: "error",
        text: "Failed to save profile. Please try again.",
      });
    } else {
      setMessage({ type: "success", text: "Profile saved successfully!" });
      setTimeout(() => setMessage({ type: "", text: "" }), 3000);
    }

    setSaving(false);
  };

  const handleSignOut = async () => {
    await authHelpers.signOut();
    window.location.href = "/auth";
  };

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
