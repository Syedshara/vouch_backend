/* @refresh reload */
import { render } from "solid-js/web"
import AppRouter from "./router"
import "./styles/geofence.css"
import "./styles/auth.css"
import "./styles/dashboard.css"

const root = document.getElementById("root")

if (import.meta.env.DEV && !(root instanceof HTMLElement)) {
  throw new Error(
    "Root element not found. Did you forget to add it to your index.html? Or maybe the id attribute got misspelled?",
  )
}

render(() => <AppRouter />, root)
