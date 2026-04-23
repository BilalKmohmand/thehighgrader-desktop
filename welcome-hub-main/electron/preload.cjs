const { contextBridge } = require("electron");

contextBridge.exposeInMainWorld("thg", {
  platform: process.platform,
  versions: {
    node: process.versions.node,
    chrome: process.versions.chrome,
    electron: process.versions.electron,
  },
});
