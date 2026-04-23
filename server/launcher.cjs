// Backend launcher for packaged Electron app
// This script starts the Express server from the bundled resources
const path = require("path");
const fs = require("fs");
const { execSync } = require("child_process");

// Single instance lock - check if already running
const pidFile = path.join(process.env.DATA_DIR || "/tmp", "thehighgrader.pid");
if (fs.existsSync(pidFile)) {
  try {
    const pid = parseInt(fs.readFileSync(pidFile, "utf-8").trim());
    // Check if process is actually running
    process.kill(pid, 0);
    console.log("[TheHighGrader] Backend already running (PID:", pid, ")");
    process.exit(0);
  } catch (e) {
    // Process not running, stale PID file
    fs.unlinkSync(pidFile);
  }
}

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

// Start the server
console.log("[TheHighGrader] Starting backend server...");
console.log("[TheHighGrader] Data directory:", process.env.DATA_DIR);
console.log("[TheHighGrader] Port:", process.env.PORT);

// Write PID file
fs.writeFileSync(pidFile, process.pid.toString());

// Cleanup on exit
process.on("exit", () => {
  if (fs.existsSync(pidFile)) {
    fs.unlinkSync(pidFile);
  }
});
process.on("SIGTERM", () => process.exit(0));
process.on("SIGINT", () => process.exit(0));

// Use tsx to run TypeScript server files
const { spawn: spawnServer } = require("child_process");
const npxCmd = process.platform === "win32" ? "npx.cmd" : "npx";

const serverProc = spawnServer(npxCmd, ["tsx", path.join(__dirname, "index.ts")], {
  cwd: __dirname,
  env: { ...process.env },
  stdio: ["ignore", "pipe", "pipe"],
  detached: false, // Keep attached so we can monitor it
});

serverProc.stdout?.on("data", (d) => process.stdout.write(d));
serverProc.stderr?.on("data", (d) => process.stderr.write(d));
serverProc.on("exit", (code) => {
  console.log("[TheHighGrader] Server exited with code:", code);
  if (fs.existsSync(pidFile)) {
    fs.unlinkSync(pidFile);
  }
  process.exit(code || 0);
});
