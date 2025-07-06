const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { spawn } = require('child_process');

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  win.loadFile('index.html');
}

// Stream stdout and stderr to renderer
ipcMain.handle('run-install-script', async (event) => {
  return new Promise((resolve, reject) => {
    const script = spawn('bash', ['install-farmvizion-git.sh'], {
      cwd: __dirname,
    });

    script.stdout.on('data', (data) => {
      event.sender.send('install-output', data.toString());
    });

    script.stderr.on('data', (data) => {
      event.sender.send('install-output', `ERROR: ${data.toString()}`);
    });

    script.on('close', (code) => {
      if (code === 0) {
        resolve('Installation completed.');
      } else {
        reject(new Error(`Script exited with code ${code}`));
      }
    });

    script.on('error', (err) => {
      reject(err);
    });
  });
});
