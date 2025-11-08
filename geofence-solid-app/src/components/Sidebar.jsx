import { createSignal, Show } from "solid-js";
import { A } from "@solidjs/router";

export default function Sidebar(props) {
  const [isCollapsed, setIsCollapsed] = createSignal(false);

  return (
    <aside class={`sidebar ${isCollapsed() ? "collapsed" : ""}`}>
      <div class="sidebar-header">
        <div class="logo">
          <div class="logo-icon">V</div>
          {!isCollapsed() && (
            <Show
              when={props.profile}
              fallback={<span class="logo-text">Vouch</span>}
            >
              <span class="logo-text">
                {props.profile?.business_name || "Vouch"}
              </span>
            </Show>
          )}
        </div>
      </div>

      <nav class="sidebar-nav">
        <A href="/" class="nav-item" activeClass="active" end>
          <svg
            class="nav-icon"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
          >
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
            <circle cx="12" cy="10" r="3" />
          </svg>
          {!isCollapsed() && <span>Locations</span>}
        </A>

        {/* --- THIS IS THE NEW SCANNER LINK --- */}
        <A href="/scanner" class="nav-item" activeClass="active">
          <svg
            class="nav-icon"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
          >
            {/* Scanner Icon */}
            <path d="M3 7v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V7M2 12h20" />
            <path d="M16 3H8a2 2 0 0 0-2 2v2M18 21v-2a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2" />
          </svg>
          {!isCollapsed() && <span>Scanner</span>}
        </A>
        {/* --- END OF NEW LINK --- */}

        <A href="/analytics" class="nav-item" activeClass="active">
          <svg
            class="nav-icon"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
          >
            <path d="M3 3v18h18" />
            <path d="M18 17V9" />
            <path d="M13 17V5" />
            <path d="M8 17v-3" />
          </svg>
          {!isCollapsed() && <span>Analytics</span>}
        </A>

        <A href="/campaigns" class="nav-item" activeClass="active">
          <svg
            class="nav-icon"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
          >
            <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z" />
            <line x1="7" y1="7" x2="7.01" y2="7" />
          </svg>
          {!isCollapsed() && <span>Campaigns</span>}
        </A>

        <A href="/reviews" class="nav-item" activeClass="active">
          <svg
            class="nav-icon"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
          >
            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
          </svg>
          {!isCollapsed() && <span>Reviews</span>}
        </A>

        <A href="/profile" class="nav-item" activeClass="active">
          <svg
            class="nav-icon"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
          >
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
            <circle cx="12" cy="7" r="4" />
          </svg>
          {!isCollapsed() && <span>Profile</span>}
        </A>
      </nav>

      <div class="sidebar-footer">
        <button class="nav-item" onClick={props.onSignOut}>
          <svg
            class="nav-icon"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
          >
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
            <polyline points="16 17 21 12 16 7" />
            <line x1="21" y1="12" x2="9" y2="12" />
          </svg>
          {!isCollapsed() && <span>Sign Out</span>}
        </button>
      </div>
    </aside>
  );
}
