# Sharded Cluster Configuration

Includes:
- Setting up config servers
- Choosing shard keys
- Testing shard splits and routing

## Setting up config servers
   - Stop all running mongod processes
   - Create directories for shards (assume 2 shards for now)
   - Create config server (single node for now - simplicity. we will expand upon it
   - Create shard servers
   - Create mongosh router
   - Initiate all 4 of the above rs.initiate()
   - connect to router and add the shards
   - load data through mongoimport
   - enable sharding
   - create index on data 
   - Shard the collection using the created index
   - rs.status() to verify how the sharding went through
      - db.colname.getShardDistribution()
      - `note`: for data size less the 64 mb mongo won't shard the data. But it can be achieved manually.
      - find the split point and split the data "sh.splitAt(,{})
      - move one chunk to another shard  "sh.moveChunk()
