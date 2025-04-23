function createUsers() {
  if (rs.status().myState === 1) {
    db.getSiblingDB("admin").createUser({
      user: "dba-admin",
      pwd: "dba-password",
      roles: [
        { role: "userAdminAnyDatabase", db: "admin" },
        { role: "readWriteAnyDatabase", db: "admin" },
        { role: "dbAdminAnyDatabase", db: "admin" },
        { role: "clusterAdmin", db: "admin" }
      ]
    });
    print("User created successfully");
  } else {
    print("Not primary, skipping user creation");
  }
}

function getPrimaryHost() {
  var status = rs.status();
  for (var i = 0; i < status.members.length; i++) {
    if (status.members[i].state === 1) {
      print(status.members[i].name);
      return status.members[i].name;
    }
  }
  print("No primary found");
  return null;
}

// Export functions for external calls
exports.createUsers = createUsers;
exports.getPrimaryHost = getPrimaryHost;
