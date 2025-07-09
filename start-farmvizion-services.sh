
echo "🔁 Enabling and starting FarmVizion services..."
sudo systemctl daemon-reload
sudo systemctl enable --now farmvizion-backend.service
sudo systemctl enable --now farmvizion-detection.service
sudo systemctl enable --now farmvizion-frontend.service
#sudo systemctl enable --now farmvizion-update.service

sudo systemctl restart farmvizion-backend.service
sudo systemctl restart farmvizion-detection.service
sudo systemctl restart farmvizion-frontend.service

echo "✅ All done! FarmVizion services are running."
