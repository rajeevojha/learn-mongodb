#!/bin/bash
# Start shard1
mongod --shardsvr --replSet shard1ReplSet \
  --port 27018 \
  --dbpath $(pwd)/data/shard1 \
  --bind_ip localhost \
  --fork --logpath $(pwd)/data/shard1/shard1.log

# Start shard2
mongod --shardsvr --replSet shard2ReplSet \
  --port 27020 \
  --dbpath $(pwd)/data/shard2 \
  --bind_ip localhost \
  --fork --logpath $(pwd)/data/shard2/shard2.log

