// MongoDB Practice Script for Interview Prep
print("=== MongoDB Practice ===")

// 1. Database Setup
use testdb
print("Current DB: " + db)

// 2. CRUD Operations
print("\n=== CRUD Operations ===")
db.test.drop() // Clear collection
db.test.insertOne({"name": "Alice", "age": 25, "role": "Dev"})
db.test.insertMany([
  {"name": "Bob", "age": 30, "role": "Ops"},
  {"name": "Charlie", "age": 28, "role": "QA"}
])
print("All documents:")
db.test.find().pretty()
print("Find Alice:")
db.test.find({"name": "Alice"}).pretty()
db.test.updateOne({"name": "Bob"}, {$set: {"age": 31}})
print("Updated Bob:")
db.test.find({"name": "Bob"}).pretty()
db.test.deleteOne({"name": "Charlie"})
print("After deleting Charlie:")
db.test.find().pretty()

// 3. Replica Set Commands
print("\n=== Replica Set Commands ===")
print("Replica set status:")
rs.status()
print("Switch to secondary read preference:")
db.getMongo().setReadPref('secondary')
print("Read from secondary:")
db.test.find().pretty()

// 4. Admin Commands
print("\n=== Admin Commands ===")
print("MongoDB Version: " + db.version())
print("Database Stats:")
db.stats()
