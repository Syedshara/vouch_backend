import { createSignal, onMount, For, Show } from "solid-js"
import { supabase, authHelpers } from "../lib/supabase"

export default function AnalyticsPage() {
  const [stats, setStats] = createSignal({
    totalLocations: 0,
    activeLocations: 0,
    totalCampaigns: 0,
    activeCampaigns: 0,
    totalCustomers: 0,
    totalRedemptions: 0,
  })
  const [recentActivity, setRecentActivity] = createSignal([])
  const [topLocations, setTopLocations] = createSignal([])
  const [topCampaigns, setTopCampaigns] = createSignal([])
  const [loading, setLoading] = createSignal(true)

  onMount(async () => {
    await loadAnalytics()
  })

  const loadAnalytics = async () => {
    const { user } = await authHelpers.getUser()
    if (!user) return

    // Load stats
    const [locationsData, campaignsData, customersData, redemptionsData] = await Promise.all([
      supabase.from("locations").select("id, is_active").eq("owner_id", user.id),
      supabase.from("campaigns").select("id, is_active").eq("owner_id", user.id),
      supabase.from("customers").select("id").eq("business_id", user.id),
      supabase.from("loyalty_transactions").select("id").eq("business_id", user.id),
    ])

    setStats({
      totalLocations: locationsData.data?.length || 0,
      activeLocations: locationsData.data?.filter((l) => l.is_active).length || 0,
      totalCampaigns: campaignsData.data?.length || 0,
      activeCampaigns: campaignsData.data?.filter((c) => c.is_active).length || 0,
      totalCustomers: customersData.data?.length || 0,
      totalRedemptions: redemptionsData.data?.length || 0,
    })

    // Load top locations by customer count
    const { data: locationStats } = await supabase
      .from("locations")
      .select(
        `
        id,
        name,
        customers:customers(count)
      `,
      )
      .eq("owner_id", user.id)
      .eq("is_active", true)
      .limit(5)

    if (locationStats) {
      const sorted = locationStats
        .map((loc) => ({
          id: loc.id,
          name: loc.name,
          count: loc.customers?.[0]?.count || 0,
        }))
        .sort((a, b) => b.count - a.count)
      setTopLocations(sorted)
    }

    // Load top campaigns by redemption count
    const { data: campaignStats } = await supabase
      .from("campaigns")
      .select(
        `
        id,
        name,
        campaign_type,
        loyalty_transactions(count)
      `,
      )
      .eq("owner_id", user.id)
      .eq("is_active", true)
      .limit(5)

    if (campaignStats) {
      const sorted = campaignStats
        .map((camp) => ({
          id: camp.id,
          name: camp.name,
          type: camp.campaign_type,
          count: camp.loyalty_transactions?.[0]?.count || 0,
        }))
        .sort((a, b) => b.count - a.count)
      setTopCampaigns(sorted)
    }

    // Load recent activity
    const { data: recentData } = await supabase
      .from("loyalty_transactions")
      .select(
        `
        id,
        transaction_type,
        points_change,
        created_at,
        customers (
          name,
          email
        ),
        campaigns (
          name
        )
      `,
      )
      .eq("business_id", user.id)
      .order("created_at", { ascending: false })
      .limit(10)

    if (recentData) {
      setRecentActivity(recentData)
    }

    setLoading(false)
  }

  const formatDate = (dateString) => {
    const date = new Date(dateString)
    const now = new Date()
    const diffMs = now - date
    const diffMins = Math.floor(diffMs / 60000)
    const diffHours = Math.floor(diffMs / 3600000)
    const diffDays = Math.floor(diffMs / 86400000)

    if (diffMins < 1) return "Just now"
    if (diffMins < 60) return `${diffMins}m ago`
    if (diffHours < 24) return `${diffHours}h ago`
    if (diffDays < 7) return `${diffDays}d ago`
    return date.toLocaleDateString()
  }

  const getTransactionIcon = (type) => {
    switch (type) {
      case "earn":
        return (
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <line x1="12" y1="5" x2="12" y2="19" />
            <polyline points="19 12 12 19 5 12" />
          </svg>
        )
      case "redeem":
        return (
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <polyline points="20 6 9 17 4 12" />
          </svg>
        )
      default:
        return (
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10" />
          </svg>
        )
    }
  }

  return (
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="page-title">Analytics</h1>
          <p class="page-subtitle">Track your business performance and customer engagement</p>
        </div>
      </div>

      <Show when={!loading()} fallback={<div class="loading">Loading analytics...</div>}>
        {/* Stats Grid */}
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon purple">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                <circle cx="12" cy="10" r="3" />
              </svg>
            </div>
            <div class="stat-content">
              <div class="stat-label">Total Locations</div>
              <div class="stat-value">{stats().totalLocations}</div>
              <div class="stat-sublabel">{stats().activeLocations} active</div>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon green">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z" />
                <line x1="7" y1="7" x2="7.01" y2="7" />
              </svg>
            </div>
            <div class="stat-content">
              <div class="stat-label">Total Campaigns</div>
              <div class="stat-value">{stats().totalCampaigns}</div>
              <div class="stat-sublabel">{stats().activeCampaigns} active</div>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon blue">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                <circle cx="9" cy="7" r="4" />
                <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                <path d="M16 3.13a4 4 0 0 1 0 7.75" />
              </svg>
            </div>
            <div class="stat-content">
              <div class="stat-label">Total Customers</div>
              <div class="stat-value">{stats().totalCustomers}</div>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon orange">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
              </svg>
            </div>
            <div class="stat-content">
              <div class="stat-label">Total Redemptions</div>
              <div class="stat-value">{stats().totalRedemptions}</div>
            </div>
          </div>
        </div>

        {/* Charts and Lists */}
        <div class="analytics-grid">
          {/* Top Locations */}
          <div class="analytics-card">
            <h3 class="analytics-card-title">Top Locations</h3>
            <Show when={topLocations().length > 0} fallback={<div class="analytics-empty">No location data yet</div>}>
              <div class="analytics-list">
                <For each={topLocations()}>
                  {(location, index) => (
                    <div class="analytics-list-item">
                      <div class="analytics-list-rank">{index() + 1}</div>
                      <div class="analytics-list-content">
                        <div class="analytics-list-name">{location.name}</div>
                        <div class="analytics-list-meta">{location.count} customers</div>
                      </div>
                      <div class="analytics-list-bar">
                        <div
                          class="analytics-list-bar-fill"
                          style={{
                            width: `${(location.count / (topLocations()[0]?.count || 1)) * 100}%`,
                          }}
                        />
                      </div>
                    </div>
                  )}
                </For>
              </div>
            </Show>
          </div>

          {/* Top Campaigns */}
          <div class="analytics-card">
            <h3 class="analytics-card-title">Top Campaigns</h3>
            <Show when={topCampaigns().length > 0} fallback={<div class="analytics-empty">No campaign data yet</div>}>
              <div class="analytics-list">
                <For each={topCampaigns()}>
                  {(campaign, index) => (
                    <div class="analytics-list-item">
                      <div class="analytics-list-rank">{index() + 1}</div>
                      <div class="analytics-list-content">
                        <div class="analytics-list-name">{campaign.name}</div>
                        <div class="analytics-list-meta">{campaign.count} redemptions</div>
                      </div>
                      <div class="analytics-list-bar">
                        <div
                          class="analytics-list-bar-fill green"
                          style={{
                            width: `${(campaign.count / (topCampaigns()[0]?.count || 1)) * 100}%`,
                          }}
                        />
                      </div>
                    </div>
                  )}
                </For>
              </div>
            </Show>
          </div>
        </div>

        {/* Recent Activity */}
        <div class="analytics-card full-width">
          <h3 class="analytics-card-title">Recent Activity</h3>
          <Show when={recentActivity().length > 0} fallback={<div class="analytics-empty">No recent activity</div>}>
            <div class="activity-list">
              <For each={recentActivity()}>
                {(activity) => (
                  <div class="activity-item">
                    <div class={`activity-icon ${activity.transaction_type === "earn" ? "blue" : "green"}`}>
                      {getTransactionIcon(activity.transaction_type)}
                    </div>
                    <div class="activity-content">
                      <div class="activity-title">
                        {activity.customers?.name || "Unknown Customer"}
                        <span class="activity-action">
                          {activity.transaction_type === "earn" ? " earned " : " redeemed "}
                        </span>
                        {Math.abs(activity.points_change)} points
                      </div>
                      <div class="activity-meta">
                        {activity.campaigns?.name || "Direct transaction"} • {formatDate(activity.created_at)}
                      </div>
                    </div>
                    <div class={`activity-points ${activity.transaction_type === "earn" ? "positive" : "negative"}`}>
                      {activity.points_change > 0 ? "+" : ""}
                      {activity.points_change}
                    </div>
                  </div>
                )}
              </For>
            </div>
          </Show>
        </div>
      </Show>
    </div>
  )
}
