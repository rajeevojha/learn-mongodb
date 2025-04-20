# Quick-Reference MongoDB Commands (Updated)

## Database Commands:
- use testdb – Switch to or create a database.
- show dbs – List all databases.
- show collections – List collections in current database.
## CRUD Operations:
- db.test.insertOne({"name": "Alice", "age": 25}) – Insert one document.
- db.test.insertMany([{"name": "Bob"}, {"name": "Charlie"}]) – Insert multiple documents.
- db.test.find().pretty() – Retrieve all documents, formatted.
- db.test.find({"name": "Alice"}) – Find by query.
- db.test.updateOne({"name": "Alice"}, {$set: {"age": 26}}) – Update one document.
- db.test.updateMany({"age": {$gt: 20}}, {$set: {"status": "adult"}}) – Update multiple documents.
- db.test.deleteOne({"name": "Alice"}) – Delete one document.
- db.test.deleteMany({"status": "adult"}) – Delete multiple documents.
## Replica Set Commands:
- rs.initiate({...}) – Initialize a replica set (as in your Terraform script).
- rs.status() – Check replica set status.
- db.getMongo().setReadPref('secondary') – Allow reads from secondary (modern alternative to rs.slaveOk()).
- rs.stepDown() – Force primary to step down (for failover testing).
## Admin Commands:
- db.version() – Show MongoDB version.
- db.stats() – Show database stats.
- db.serverStatus() – Show server status (e.g., connections, memory).
- db.getCollectionInfos() – List collection details.
