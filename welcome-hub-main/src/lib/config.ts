export const DASHBOARD_URL =
  import.meta.env.VITE_DASHBOARD_URL ||
  (import.meta.env.DEV ? "http://localhost:5050/dashboard" : "http://localhost:5050/dashboard");

export const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  (import.meta.env.DEV ? "http://localhost:5050" : "http://localhost:5050");
