#!bin/bash
    sed -i 's/bindIp: 0.0.0.0/bindIp: 90.0.0.0/' /etc/mongod.conf
#   uncomment and update the security line, had to do in 2 steps
    sed -i 's/^#security:/security:/' /etc/mongod.conf
    sed -i '/^security:/a\  authorization: enabled' /etc/mongod.conf
#   uncomment and update the replication; had to do in 2 steps
    sed -i 's/^#replication:/replication:/' /etc/mongod.conf
    sed -i '/^replication:/a\  replSetName: "rs0"' /etc/mongod.conf
