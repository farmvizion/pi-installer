const { app, BrowserWindow, ipcMain } = require('electron');
const { exec } = require('child_process');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 400,
    height: 250,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  win.loadFile('index.html');
}

app.whenReady().then(createWindow);

ipcMain.handle('install-sdk', async () => {
  return new Promise((resolve) => {
    exec('bash ~/pi-installer/install-farmvizion-git.sh', (error, stdout, stderr) => {
      if (error) {
        resolve(`Error: ${error.message}`);
        return;
      }
      if (stderr) {
        resolve(`Stderr: ${stderr}`);
        return;
      }
      resolve(`Success:\n${stdout}`);
    });
  });
});
