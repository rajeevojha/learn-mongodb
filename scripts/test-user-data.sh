#!bin/bash

    f1 = "111"
    f2 = "222"
    echo "{$f1/999/$f2}"
#    sed 's/bindIp: 0.0.0.0/bindIp: 90.0.0.0/' /etc/mongod.conf
#   uncomment and update the security line, had to do in 2 steps
#    sed  's/^#security:/security:/' /etc/mongod.conf
#    sed  '/^security:/a\  authorization: enabled' /etc/mongod.conf
#   uncomment and update the replication; had to do in 2 steps
#    sed  's/^#replication:/replication:/' /etc/mongod.conf
#    sed  '/^replication:/a\  replSetName: "rs0"' /etc/mongod.conf
