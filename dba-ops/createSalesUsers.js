use sales;
db.createUser({
  user: "readonly-sales",
  pwd: "readonly-sales",
  roles: [ { role: "read", db: "sales" } ]
});

db.createUser({
  user: "readwrite-sales",
  pwd: "readwrite-sales",
  roles: [ { role: "readWrite", db: "sales" } ]
});

