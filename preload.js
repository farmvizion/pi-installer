const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  installSDK: () => ipcRenderer.invoke('install-sdk')
});
