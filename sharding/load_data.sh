# import data - mongoimport
mongoimport --host localhost:27017 --db sales --collection superstore --file ../data/train.json
# connect to mongosh
mongosh --port 27017
# enable sharding on the database
sh.enableSharding("sales")
# chose a shard key
db.superstore.createIndex({ CustomerID: 1 })
# shard the collection
sh.shardCollection("sales.superstore", { CustomerID: 1 })
# verify sharding
db.superstore.getShardDistribution()
