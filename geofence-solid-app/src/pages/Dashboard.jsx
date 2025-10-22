// src/pages/Dashboard.jsx

import { createSignal, onMount, Show } from "solid-js";
import { useNavigate } from "@solidjs/router";
import { authHelpers, supabase } from "../lib/supabase";
import Sidebar from "../components/Sidebar";

// The "props" argument will automatically contain a "children" property
// which represents the nested routes defined in router.jsx
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

    const { data: profileData } = await supabase
      .from("business_profiles") // Make sure this table name matches your DB
      .select("business_name")
      .eq("user_id", user.id)
      .single();

    setProfile(profileData);
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
        <main class="dashboard-main">
          {/* THIS IS THE FIX: 
            Instead of <Outlet />, we render props.children. The router will
            automatically place the correct child page component here.
          */}
          {props.children}
        </main>
      </div>
    </Show>
  );
}
