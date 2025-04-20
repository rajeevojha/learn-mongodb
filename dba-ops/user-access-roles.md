# MongoDB DBA Operations – User & Access Roles

This document contains examples and notes on:
- Creating MongoDB users
- Granting roles
- Managing authentication

## creating user - access to all databases
- connect to the primary
- connect to mongosh
-  
``` code
use admin
db.createUser({
  user: "dba-admin",
  pwd: "dba-password",
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "readWriteAnyDatabase", db: "admin" },
    { role: "dbAdminAnyDatabase", db: "admin" },
    { role: "clusterAdmin", db: "admin" }
  ]
})
```
## creating user - access to a sales database

>   ensure you log in using the newly minted dba-admin

``` code
    use sales
    db.createUser({
    user: "readonly-user",
      pwd: "readonly-pass",
      roles: [ { role: "read", db: "sales" } ]
    })
```
> note: if the above code is saved in ~/scripts/createSalesUsers.js
>        we can execute the same by issueing the below command
>        mongosh ~/scripts/createSalesUsers.js
