// Backend launcher for packaged Electron app
// This script starts the Express server from the bundled resources
const path = require("path");
const fs = require("fs");
const { execSync } = require("child_process");

// Load .env manually
const envPath = path.join(__dirname, ".env");
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, "utf-8");
  envContent.split("\n").forEach((line) => {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) return;
    const eqIndex = trimmed.indexOf("=");
    if (eqIndex > 0) {
      const key = trimmed.slice(0, eqIndex).trim();
      const val = trimmed.slice(eqIndex + 1).trim();
      if (!process.env[key]) {
        process.env[key] = val;
      }
    }
  });
}

// Set data directory for persistence
if (!process.env.DATA_DIR) {
  const userDataDir = path.join(
    process.env.HOME || process.env.USERPROFILE || "/tmp",
    "thehighgrader-data"
  );
  process.env.DATA_DIR = userDataDir;
}

process.env.PORT = process.env.PORT || "5050";
process.env.NODE_ENV = process.env.NODE_ENV || "production";

// Install npm dependencies if missing (first run)
const nodeModulesPath = path.join(__dirname, "node_modules");
if (!fs.existsSync(nodeModulesPath)) {
  console.log("[TheHighGrader] First run - installing server dependencies...");
  try {
    execSync("npm install --production", {
      cwd: __dirname,
      stdio: "pipe",
      timeout: 300000, // 5 minute timeout
    });
    console.log("[TheHighGrader] Dependencies installed successfully.");
  } catch (e) {
    console.error("[TheHighGrader] Failed to install dependencies:", e.message);
    console.error("[TheHighGrader] Please ensure you have internet connection for first run.");
  }
}

// Dynamically import the server
console.log("[TheHighGrader] Starting backend server...");
console.log("[TheHighGrader] Data directory:", process.env.DATA_DIR);
console.log("[TheHighGrader] Port:", process.env.PORT);

// Use dynamic import for ESM
import(path.join(__dirname, "index.ts")).catch(() => {
  // Fallback: try to load compiled JS
  try {
    require(path.join(__dirname, "index.js"));
  } catch (e) {
    console.error("[TheHighGrader] Failed to start server:", e.message);
    console.error("[TheHighGrader] Make sure tsx is available or server is compiled.");
  }
});
