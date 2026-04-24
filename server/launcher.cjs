// Backend launcher for packaged Electron app
// This script starts the Express server from the bundled resources
const path = require("path");
const fs = require("fs");
const { spawn } = require("child_process");

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

fs.mkdirSync(process.env.DATA_DIR, { recursive: true });

// Single instance lock - check if already running
const pidFile = path.join(process.env.DATA_DIR, "thehighgrader-backend.pid");
if (fs.existsSync(pidFile)) {
  try {
    const pid = parseInt(fs.readFileSync(pidFile, "utf-8").trim(), 10);
    process.kill(pid, 0);
    console.log("[TheHighGrader] Backend already running (PID:", pid, ")");
    process.exit(0);
  } catch (_e) {
    try {
      fs.unlinkSync(pidFile);
    } catch (_e2) {
      // ignore
    }
  }
}

process.env.PORT = process.env.PORT || "5050";
process.env.NODE_ENV = process.env.NODE_ENV || "production";

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

const serverEntry = path.join(__dirname, "dist", "index.cjs");
if (!fs.existsSync(serverEntry)) {
  console.error("[TheHighGrader] Missing server build:", serverEntry);
  process.exit(1);
}

const serverProc = spawn(process.execPath, [serverEntry], {
  cwd: __dirname,
  env: { ...process.env },
  stdio: ["ignore", "pipe", "pipe"],
});

serverProc.stdout?.on("data", (d) => process.stdout.write(d));
serverProc.stderr?.on("data", (d) => process.stderr.write(d));
serverProc.on("exit", (code) => {
  console.log("[TheHighGrader] Server exited with code:", code);
  try {
    if (fs.existsSync(pidFile)) fs.unlinkSync(pidFile);
  } catch (_e) {
    // ignore
  }
  process.exit(code || 0);
});
