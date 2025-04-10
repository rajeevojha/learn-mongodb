# learn mongodb from wsl terminal
- sudo systemctl start mongod //* start mongodb
- mongosh                     //* start mongodb shell
- show dbs                    //* list all the databases available
- use <dbname>                //* switch to the database
- https://www.mongodb.com/docs/manual/crud/

##CRUD
  - insert one 
    db.collection.insertOne({"key":"value"})
  - inesrt many
    db.collection.insertMany({"key1":"value1"},{"key2":"value2"})
    All write operations are atomic on the level of a single document. 
  - read (find)
    db.collection.find({
      age:{"$gt":18},                 //find a record where age is gt
      sex:{"$eq":"F"}},               //than 18 and sex is "F"
      {name:1,address:1}).limit(5)   //include name and address, 
                                     //and selection only 5 records
  - update
    db.collection.updateOne()
    db.collection.updateMany()
    db.collection.replaceMany()
       db.users.updateMany(         //update the users collection
         {age: {$lt:18}},           //find subject with age less than 18
         {$set:{status:"reject"}}   //change status to reject
         )
