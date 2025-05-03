#!/bin/bash

# MongoDB setup script

# Update system packages
apt-get update
apt-get upgrade -y

# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt-get update
apt-get install -y mongodb-org

# Create data directory if it doesn't exist
mkdir -p /data/db
chown -R mongodb:mongodb /data/db

# Configure MongoDB to accept connections from backend
cat > /etc/mongod.conf << EOF
storage:
  dbPath: /data/db
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
net:
  port: 27017
  bindIp: 0.0.0.0
security:
  authorization: disabled
EOF

# Start MongoDB service
systemctl start mongod
systemctl enable mongod

# Create database and user
sleep 10
mongosh --eval "db = db.getSiblingDB('travelmemory'); db.createUser({user: 'travelmemory', pwd: 'password', roles: [{role: 'readWrite', db: 'travelmemory'}]});"

# Create a test collection
mongosh --eval "db = db.getSiblingDB('travelmemory'); db.createCollection('trips');"

echo "MongoDB setup completed"