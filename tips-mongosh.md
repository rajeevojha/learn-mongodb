# Tips
- you can directly get records using mongosh eval function
  - example 
   > mongosh "mongodb://localhost:27017/superstore" --eval "db.sales.find().limit(3)" --quiet
   > mongosh "mongodb://localhost:27017/superstore" --eval "db.sales.find({'City':'West Jordan'}).limit(3)" --quiet
   > mongosh "mongodb://localhost:27017/superstore" --eval "var hello = 'hello world'" --shell
## config
  -  mongosh --nodb # runs the mongo shell with no db attached, useful when you want to just check certain config settings 
  - config.reset(<"setting name">) to reset the value
## load <- load an external function in mongosh
## db.getSiblingDB()
The db.getSiblingDB() method allows you to change databases within a script that gets loaded into mongosh by using the load() method. The db.getSiblingDB() method accepts one argument, which is a string that contains the name of the database that you want to switch to.

## creating a function
- you can directly type/paste in the shell and it creates the function

function addUsernamesCollection() { const database = db.getSiblingDB('sample_analytics'); const customers = database.customers.find({}, { username: 1, _id: 0 }, { limit: 50 }); customers.forEach((customer) => db.usernames.insertOne(customer)); }

db.transactions.updateOne(
  { account_id: 443178 },
  { $push: {
      transactions: {
      date: new Date(),
      amount: Math.floor(Math.random() * 1000),
      transaction_code: Math.random() < 0.5 ? "buy" : "sell",
      symbol: "test",
      price: "100.00",
      total: "1337.10",
    }
   }
  }
)
