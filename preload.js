// preload.js
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('farmvizionAPI', {
  runInstall: () => ipcRenderer.invoke('run-install-script'),
  onOutput: (callback) => ipcRenderer.on('install-output', (event, data) => callback(data)),
});
