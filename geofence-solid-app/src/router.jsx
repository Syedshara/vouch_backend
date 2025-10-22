// src/router.jsx

import { lazy } from "solid-js";
// CORRECTED: The import does not use 'Routes'
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

// CORRECTED: Define routes as an array for this version of the router
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
      { path: "/analytics", component: AnalyticsPage },
      { path: "/campaigns", component: CampaignsPage },
      { path: "/reviews", component: ReviewsPage },
      { path: "/profile", component: ProfilePage },
    ],
  },
];

export default function AppRouter() {
  // CORRECTED: The Router component takes the 'routes' array as a prop
  return <Router>{routes}</Router>;
}
