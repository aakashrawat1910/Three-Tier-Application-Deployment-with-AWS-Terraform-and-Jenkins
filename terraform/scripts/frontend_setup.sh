#!/bin/bash

# Frontend setup script

# Update system packages
apt-get update
apt-get upgrade -y

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs git

# Create app directory
mkdir -p /app
cd /app

# Clone the application repository
git clone https://github.com/username/TravelMemory.git .
# Note: Replace with actual repository URL in production

# Install frontend dependencies
cd /app/frontend
npm install

# Configure frontend to connect to backend
echo "REACT_APP_BACKEND_URL=${backend_url}" > /app/frontend/.env

# Build the frontend application
npm run build

# Install serve to serve the static files
npm install -g serve

# Create a systemd service for the frontend
cat > /etc/systemd/system/travelmemory-frontend.service << EOF
[Unit]
Description=TravelMemory Frontend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/app/frontend
ExecStart=/usr/bin/serve -s build -l ${frontend_port}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl enable travelmemory-frontend.service
systemctl start travelmemory-frontend.service

echo "Frontend setup completed"