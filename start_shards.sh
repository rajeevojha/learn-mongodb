# Start config server
./scripts/shard_setup/start_configsvr.sh

# Initialize config server replica set
mongo --port 27019 --eval 'rs.initiate()'

# Start shard servers
./scripts/shard_setup/start_shardsvr.sh

# Initialize shard1
mongo --port 27018 --eval 'rs.initiate()'

# Initialize shard2
mongo --port 27020 --eval 'rs.initiate()'

# Start mongos
./scripts/shard_setup/start_mongos.sh

