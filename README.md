# learn mongodb from wsl terminal
- sudo systemctl start mongod //* start mongodb
- mongosh                     //* start mongodb shell
- show dbs                    //* list all the databases available
- use <dbname>                //* switch to the database
- https://www.mongodb.com/docs/manual/crud/

## CRUD
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
## get some huge data for practice - source kaggle
   > look for something like task app 
   > use pandas /python to convert the file into JSON
   > and then load into mongo.
   > note we have mongo currently in wsl which we will leverage
## convert Superstore Sales data (from kaggle) to json using python and pd
   load json into mongodb
   mongoimport --db superstore --collection sales --jsonArray --file ~/learn-mongodb/data/train.json
## first attempt at import
   - only 2000 records could be updated 
   - the Due Date field had NaN for some records and mongo stopped import at the first error. 
   - 2000 records were in the database and not 2233. This is because of default batchsize is 4mb data or 1000 records which ever comes first.
## data cleanup
   - pandas was used to replace NaN with 0.
   - df['Postal Code'] = df['Postal Code'].fillna(0)
   - existing mongodb database was dropped. =======> db.dropDatabase()
   - data reimported using mongoimport --db ...
     > 9800 document(s) imported successfully. 0 document(s) failed to import.  
