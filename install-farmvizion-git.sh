#!/bin/bash

# FarmVizion SDK installation script (read-only mode for Raspberry Pi/Linux)
set -e  # Exit immediately on error

GIT_REPO="git@github.com:farmvizion/farmvizion-sdk.git"



echo "📦 Installing FarmVizion SDK in read-only mode..."

# --- Step 1: Ensure Git is installed ---
if ! command -v git &> /dev/null; then
    echo "🔧 Git is not installed. Installing..."
    sudo apt update
    sudo apt install -y git
else
    echo "✅ Git is already installed."
fi

SDK_DIR="$HOME/farmvizion-sdk"


# --- Step 2: Clone or pull the SDK ---
if [ -d "$SDK_DIR/.git" ]; then
    echo "🔄 SDK already exists. Pulling latest changes..."
    cd "$SDK_DIR"
    git reset --hard
    git clean -fd
    
    git pull origin main
else
    echo "⬇️ Cloning SDK from GitHub..."
    git clone --depth 1 "$GIT_REPO" "$SDK_DIR"
fi

chmod -R u+rwX "$SDK_DIR"


# --- Step 3: Make repo read-only ---
#cd "$SDK_DIR"
#git remote set-url --push origin DISABLE
#git config --local advice.detachedHead false
#chmod -R a-w "$SDK_DIR"

#echo "✅ SDK is ready and read-only at $SDK_DIR"

# --- Step 4: System package updates ---
echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# --- Step 5: Install Avahi (for .local name resolution) ---
echo "📡 Installing Avahi..."
sudo apt install -y avahi-daemon
sudo systemctl enable --now avahi-daemon

# --- Step 6: Install Mosquitto MQTT broker ---
echo "📶 Installing Mosquitto MQTT broker..."
sudo apt install -y mosquitto mosquitto-clients
sudo cp "$SDK_DIR/conf/mosquitto.conf" /etc/mosquitto/mosquitto.conf
sudo systemctl enable --now mosquitto

# --- Step 7: Python virtual environment setup ---
echo "🐍 Setting up Python virtual environment..."

# Create venv in home folder or a separate writable location
python3 -m venv "$HOME/fvenv-farmvizion"
source "$HOME/fvenv-farmvizion/bin/activate"
pip install --upgrade pip
pip install -r "$SDK_DIR/fvapp/requirements.txt"

deactivate
chmod -R u+w "$SDK_DIR/farmvizion-backend"
chmod -R u+w "$SDK_DIR/farmvizion-frontend"

# --- Step 8: Node.js via NVM ---
echo "🟢 Installing Node.js with NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

# --- Step 9: Install backend & frontend Node dependencies ---
echo "📦 Installing backend and frontend dependencies..."
cd "$SDK_DIR/farmvizion-backend"
npm install

cd "$SDK_DIR/farmvizion-frontend"
npm install

# --- Step 10: Systemd services setup ---
echo "🧰 Installing systemd services..."
sudo cp "$SDK_DIR/system-services/farmvizion-backend.service" /etc/systemd/system/
sudo cp "$SDK_DIR/system-services/farmvizion-frontend.service" /etc/systemd/system/
sudo cp "$SDK_DIR/system-services/farmvizion-detection.service" /etc/systemd/system/
#sudo cp "$SDK_DIR/system-services/farmvizion-update.service" /etc/systemd/system/


echo "🔁 Enabling and starting FarmVizion services..."
sudo systemctl daemon-reload
sudo systemctl enable --now farmvizion-backend.service
sudo systemctl enable --now farmvizion-detection.service
sudo systemctl enable --now farmvizion-frontend.service
#sudo systemctl enable --now farmvizion-update.service

sudo systemctl restart farmvizion-backend.service
sudo systemctl restart farmvizion-detection.service
sudo systemctl restart farmvizion-frontend.service

echo "✅ All done! FarmVizion SDK is installed and services are running."
