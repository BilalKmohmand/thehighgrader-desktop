const { app, BrowserWindow, shell } = require("electron");
const path = require("path");
const { spawn } = require("child_process");

const isDev = !app.isPackaged;
let backendProc = null;

function startBackend() {
  if (isDev) return; // In dev mode, backend is started separately

  const serverDir = path.join(process.resourcesPath, "server");
  const launcher = path.join(serverDir, "launcher.cjs");

  backendProc = spawn(
    process.execPath,
    [launcher],
    {
      cwd: serverDir,
      env: {
        ...process.env,
        PORT: "5050",
        NODE_ENV: "production",
        DATA_DIR: path.join(app.getPath("userData"), "data"),
      },
      stdio: ["ignore", "pipe", "pipe"],
    }
  );

  backendProc.stdout?.on("data", (d) => console.log("[backend]", d.toString().trim()));
  backendProc.stderr?.on("data", (d) => console.error("[backend]", d.toString().trim()));
  backendProc.on("exit", (code) => console.log("[backend] exited", code));
}

function stopBackend() {
  if (backendProc) {
    backendProc.kill();
    backendProc = null;
  }
}

function createWindow() {
  const win = new BrowserWindow({
    title: "TheHighGrader",
    width: 1200,
    height: 800,
    minWidth: 1000,
    minHeight: 700,
    backgroundColor: "#0d0d14",
    show: false,
    webPreferences: {
      preload: path.join(__dirname, "preload.cjs"),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false,
    },
  });

  win.once("ready-to-show", () => win.show());

  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: "deny" };
  });

  if (isDev) {
    win.loadURL("http://localhost:8080");
    win.webContents.openDevTools({ mode: "detach" });
  } else {
    // In production, load from the bundled backend server
    win.loadURL("http://localhost:5050");
  }
}

app.whenReady().then(() => {
  startBackend();

  // Wait for backend to be ready before loading the window
  const tryLoad = () => {
    const http = require("http");
    const req = http.get("http://localhost:5050/health", (res) => {
      res.on("data", () => {});
      res.on("end", () => createWindow());
    });
    req.on("error", () => setTimeout(tryLoad, 1000));
    req.end();
  };

  if (isDev) {
    createWindow();
  } else {
    tryLoad();
  }

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", () => {
  stopBackend();
  if (process.platform !== "darwin") app.quit();
});

app.on("before-quit", () => {
  stopBackend();
});
