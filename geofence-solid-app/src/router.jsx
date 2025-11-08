// src/router.jsx

import { lazy } from "solid-js";
import { Router, Route } from "@solidjs/router";

// --- Lazy load pages for better performance ---
const Login = lazy(() => import("./pages/Login"));
const Signup = lazy(() => import("./pages/Signup"));
const DashboardLayout = lazy(() => import("./pages/Dashboard"));
const LocationsPage = lazy(() => import("./pages/LocationsPage"));
const AnalyticsPage = lazy(() => import("./pages/AnalyticsPage"));
const CampaignsPage = lazy(() => import("./pages/CampaignsPage"));
const ReviewsPage = lazy(() => import("./pages/ReviewsPage"));
const ProfilePage = lazy(() => import("./pages/ProfilePage"));
// --- ADD NEW LAZY IMPORT ---
const ScannerPage = lazy(() => import("./pages/ScannerPage"));

const routes = [
  {
    path: "/login",
    component: Login,
  },
  {
    path: "/signup",
    component: Signup,
  },
  {
    path: "/",
    component: DashboardLayout,
    children: [
      { path: "/", component: LocationsPage },
      // --- ADD NEW ROUTE ---
      { path: "/scanner", component: ScannerPage },
      { path: "/analytics", component: AnalyticsPage },
      { path: "/campaigns", component: CampaignsPage },
      { path: "/reviews", component: ReviewsPage },
      { path: "/profile", component: ProfilePage },
    ],
  },
];

export default function AppRouter() {
  return <Router>{routes}</Router>;
}
