// src/pages/Dashboard.jsx
import { createSignal, onMount, Show } from "solid-js";
import { useNavigate } from "@solidjs/router";
import { authHelpers } from "../lib/supabase";
import { api } from "../lib/api"; // <-- IMPORT NEW API HELPER
import Sidebar from "../components/Sidebar";

export default function Dashboard(props) {
  const [profile, setProfile] = createSignal(null);
  const [loading, setLoading] = createSignal(true);
  const navigate = useNavigate();

  onMount(async () => {
    const { user } = await authHelpers.getUser();
    if (!user) {
      navigate("/login");
      return;
    }

    try {
      // --- THIS IS THE FIX ---
      // Fetch profile from our secure Node.js backend
      const profileData = await api.getProfile();
      setProfile(profileData);
    } catch (error) {
      console.error("Failed to load dashboard profile:", error);
      // If profile fetch fails (e.g., still being created),
      // sign out or show an error.
      // For now, we just won't set the name.
    }

    setLoading(false);
  });

  const handleSignOut = async () => {
    await authHelpers.signOut();
    navigate("/login");
  };

  return (
    <Show
      when={!loading()}
      fallback={<div class="loading-screen">Loading Dashboard...</div>}
    >
      <div class="dashboard-container">
        <Sidebar profile={profile()} onSignOut={handleSignOut} />
        <main class="dashboard-main">{props.children}</main>
      </div>
    </Show>
  );
}
