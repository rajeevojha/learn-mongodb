resource "null_resource" "init_replica_set" {
  depends_on = [aws_instance.mongo_node]
  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "export PATH=$PATH:/usr/bin",
      "until mongosh --host ${aws_instance.mongo_node[0].public_ip}:27017  --eval 'db.runCommand({ ping: 1 })' > /dev/null 2>&1; do echo 'Waiting for mongod.0.'; sleep 5; done",
      "mongosh --host ${aws_instance.mongo_node[0].public_ip}:27017 --quiet --eval 'rs.initiate({ _id: \"rs0\", members: [ {_id: 0, host: \"${aws_instance.mongo_node[0].public_ip}:27017\", priority: 2}, {_id: 1, host: \"${aws_instance.mongo_node[1].public_ip}:27017\", priority: 1}, {_id: 2, host: \"${aws_instance.mongo_node[2].public_ip}:27017\", arbiterOnly: true} ] })'",
      "mongosh --eval 'rs.status()'",
      "echo 'step 1 - replica set initiated'",
      "sleep 60",
      "PRIMARY_HOST=$(mongosh 'mongodb://${aws_instance.mongo_node[0].public_ip}:27017,${aws_instance.mongo_node[1].public_ip}:27017,${aws_instance.mongo_node[2].public_ip}:27017/admin?replicaSet=rs0' --quiet --eval 'load(\"/etc/mongodb/mongo_utils.js\"); getPrimaryHost();')",
      "echo Primary host: $PRIMARY_HOST ",
      "PRIMARY_IP=$(echo $PRIMARY_HOST | cut -d ':' -f 1)",
     # "mongosh 'mongodb://${aws_instance.mongo_node[0].public_ip}:27017,${aws_instance.mongo_node[1].public_ip}:27017,${aws_instance.mongo_node[2].public_ip}:27017/admin?replicaSet=rs0' --quiet --eval 'load(\"/etc/mongodb/mongo_utils.js\"); createUsers();' || echo 'Failed to run createUsers'",
     "mongosh mongodb://$PRIMARY_IP:27017/admin?replicaSet=rs0 --quiet --eval 'load(\"/etc/mongodb/mongo_utils.js\"); createUsers();' || echo 'Failed to run createUsers'",

      "echo 'now getting file from aws'",
      "aws s3 cp s3://ro-kaggle-superstore/superstore.json /tmp/superstore.json",        
      "ssh -i ~/.ssh/cloud9.pem -o StrictHostKeyChecking=no ubuntu@$PRIMARY_IP 'mongoimport --host localhost:27017 --db sales --collection superstore --file /tmp/superstore.json --type json --jsonArray' || echo 'Failed to mongo import'",
      "mongosh mongodb://$PRIMARY_IP:27017/sales?replicaSet=rs0 --quiet --eval 'db.superstore.find({}).limit(1)'",
      "mongosh mongodb://$PRIMARY_IP:27017/admin?replicaSet=rs0 --quiet --eval 'rs.status()'"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/cloud9.pem")
      host        = aws_instance.mongo_node[0].public_ip
    }
  }
}

