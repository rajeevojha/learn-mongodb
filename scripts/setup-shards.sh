#!/bin/bash

# Exit on error
set -e

# Stop any existing MongoDB processes
echo "Stopping existing MongoDB processes..."
pkill -f mongod || true
pkill -f mongos || true
sleep 2

# Verify no processes are running
if sudo lsof -i :27017,27018,27019,27020; then
    echo "Error: Ports still in use. Please stop processes manually."
    exit 1
fi

# Create directories with correct permissions
echo "Creating directories..."
mkdir -p ~/mongo_shard/config ~/mongo_shard/shard1 ~/mongo_shard/shard2 ~/mongo_shard/mongos
chmod -R 755 ~/mongo_shard

# Start config server as a replica set
echo "Starting config server on port 27019..."
mongod --configsvr --replSet configReplSet --dbpath ~/mongo_shard/config --port 27019  --fork --logpath ~/mongo_shard/config.log --bind_ip 127.0.0.1 || {
    echo "Config server failed to start. Check ~/mongo_shard/config.log"
    exit 1
}

# Start shard servers as replica sets
echo "Starting shard1 on port 27018..."
mongod --shardsvr --replSet shard1ReplSet --dbpath ~/mongo_shard/shard1 --port 27018 --fork --logpath ~/mongo_shard/shard1.log --bind_ip 127.0.0.1 || {
    echo "Shard1 failed to start. Check ~/mongo_shard/shard1.log"
    exit 1
}

echo "Starting shard2 on port 27020..."
mongod --shardsvr --replSet shard2ReplSet --dbpath ~/mongo_shard/shard2 --port 27020 --fork --logpath ~/mongo_shard/shard2.log --bind_ip 127.0.0.1 || {
    echo "Shard2 failed to start. Check ~/mongo_shard/shard2.log"
    exit 1
}

# Wait for servers to start
echo "Waiting for servers to initialize..."
sleep 10

# Initialize config server replica set
echo "Initializing config server replica set..."
mongosh --port 27019 --eval 'rs.initiate({
    _id: "configReplSet",
    configsvr: true,
    members: [{ _id: 0, host: "127.0.0.1:27019" }]
})' || {
    echo "Config server init failed. Check ~/mongo_shard/config.log"
    exit 1
}

# Initialize shard1 replica set
echo "Initializing shard1 replica set..."
mongosh --port 27018 --eval 'rs.initiate({
    _id: "shard1ReplSet",
    members: [{ _id: 0, host: "127.0.0.1:27018" }]
})' || {
    echo "Shard1 init failed. Check ~/mongo_shard/shard1.log"
    exit 1
}

# Initialize shard2 replica set
echo "Initializing shard2 replica set..."
mongosh --port 27020 --eval 'rs.initiate({
    _id: "shard2ReplSet",
    members: [{ _id: 0, host: "127.0.0.1:27020" }]
})' || {
    echo "Shard2 init failed. Check ~/mongo_shard/shard2.log"
    exit 1
}

# Wait for replica sets to elect primaries
echo "Waiting for replica sets to stabilize..."
sleep 15

# Verify config server is ready
echo "Checking config server status..."
mongosh --port 27019 --eval 'rs.status()' | grep -q "PRIMARY" || {
    echo "Config server not ready. Check ~/mongo_shard/config.log"
    exit 1
}

# Start mongos
echo "Starting mongos on port 27017..."
mongos --configdb configReplSet/127.0.0.1:27019 --port 27017 --fork --logpath ~/mongo_shard/mongos.log --bind_ip 127.0.0.1 || {
    echo "Mongos failed to start. Check ~/mongo_shard/mongos.log"
    exit 1
}

# Wait for mongos to start
echo "Waiting for mongos to initialize..."
sleep 5

# Verify mongos is running
if ! pgrep -f "mongos.*27017"; then
    echo "Error: mongos failed to start. Check ~/mongo_shard/mongos.log"
    exit 1
fi

# Add shards via mongos
echo "Adding shards to the cluster..."
mongosh --port 27017 --eval 'sh.addShard("shard1ReplSet/127.0.0.1:27018")' || {
    echo "Failed to add shard1"
    exit 1
}
mongosh --port 27017 --eval 'sh.addShard("shard2ReplSet/127.0.0.1:27020")' || {
    echo "Failed to add shard2"
    exit 1
}

# Enable sharding and shard the sales collection
echo "Enabling sharding and sharding collection..."
mongosh --port 27017 --eval 'sh.enableSharding("superstore")' || {
    echo "Failed to enable sharding"
    exit 1
}
mongosh --port 27017 --eval 'sh.shardCollection("superstore.sales", {"Order ID": "hashed"})' || {
    echo "Failed to shard collection"
    exit 1
}

echo "Sharded cluster setup complete!"
echo "Connect to mongos: mongosh --port 27017"
echo "Import data: mongoimport --port 27017 --db superstore --collection sales --jsonArray --file train.json"
echo "Check logs if issues persist: ~/mongo_shard/*.log"
