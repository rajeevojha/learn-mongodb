use testdb
db.users.insertOne({"name": "Raveena", "age": 25})
db.users.findOne()
db.users.updateOne({"name":"Raveena",{$set:{"age":26}}})
db.users.deleteOne({"name":"Raveena"})

