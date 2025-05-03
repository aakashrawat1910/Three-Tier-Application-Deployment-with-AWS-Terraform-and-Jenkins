#!/bin/bash

# Backend setup script

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

# Install backend dependencies
cd /app/backend
npm install

# Create .env file with MongoDB connection and port
cat > /app/backend/.env << EOF
MONGO_URI=mongodb://${mongodb_ip}:27017/travelmemory
PORT=${backend_port}
EOF

# Create a systemd service for the backend
cat > /etc/systemd/system/travelmemory-backend.service << EOF
[Unit]
Description=TravelMemory Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/app/backend
ExecStart=/usr/bin/npm start
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Update package.json to include start script if not already present
if ! grep -q '"start"' /app/backend/package.json; then
  sed -i 's/"scripts": {/"scripts": {\n    "start": "node index.js",/g' /app/backend/package.json
fi

# Enable and start the service
systemctl enable travelmemory-backend.service
systemctl start travelmemory-backend.service

echo "Backend setup completed"