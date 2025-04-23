provider "aws" {
  region = "us-west-1"
}
resource "aws_instance" "mongo_node" {
  count         = 3
  ami           = "ami-04f7a54071e74f488" # Ubuntu 24.04 AMI (us-west-1)
  instance_type = "t3.micro"
  key_name      = "cloud9"
  vpc_security_group_ids = [aws_security_group.mongo_sg.id]
  tags = {
    Name = "mongo-node-${count.index}"
  }
#upload the mongoDB-key file  
  provisioner "file" {
    source      = "${path.module}/../mongodb-keyfile.pem"
    destination = "/tmp/mongodb-keyfile.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/cloud9.pem")
      host        = self.public_dns
    }
  }
  provisioner "file" {
    source      = "${path.module}/../scripts/create_users.js"
    destination = "/tmp/create-users.js"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/cloud9.pem")
      host        = self.public_dns
    }
  }

user_data = <<-EOF
  Content-Type: multipart/mixed; boundary="//"
  MIME-Version: 1.0

  --//
  Content-Type: text/x-shellscript; charset="us-ascii"
  MIME-Version: 1.0
  Content-Transfer-Encoding: 7bit
  Content-Disposition: attachment; filename="userdata.txt"

  #!/bin/bash -xe
  set -x
  sudo bash -c 'echo "Starting user_data script" > /var/log/user-data.log 2>&1'
  sudo bash -c 'exec >> /var/log/user-data.log 2>&1'
  sudo cat /etc/os-release | grep PRETTY_NAME
  sudo apt-get update || { echo "apt-get update failed"; exit 1; }
  sudo apt-get install -y gnupg curl || { echo "apt-get install gnupg curl failed"; exit 1; }
  sudo echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list || { echo "tee repo list failed"; exit 1; }
  sudo curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg || { echo "curl/gpg failed"; exit 1; }
  sudo apt-get update || { echo "second apt-get update failed"; exit 1; }
  sudo apt-get install -y mongodb-org mongodb-mongosh || { echo "mongodb install failed"; exit 1; }
  sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf || { echo "sed bindIp failed"; exit 1; }
  sudo sed -i 's/^#replication:/replication:/' /etc/mongod.conf || { echo "sed replication failed"; exit 1; }
  sudo sed -i '/^replication:/a\  replSetName: "rs0"' /etc/mongod.conf || { echo "sed replication append failed"; exit 1; }
   # Create a new directory to hold the security key
     sudo mkdir -p /etc/mongodb/pki
     # move the key to the correct directory
     sudo mv /tmp/mongodb-keyfile.pem /etc/mongodb/pki/mongodb-keyfile.pem
     # Give the mongodb user ownership of the pki directory
       sudo chown mongodb:mongodb /etc/mongodb/pki/mongodb-keyfile.pem
       sudo chmod 0400 /etc/mongodb/pki/mongodb-keyfile.pem
       sudo chmod 0755 /etc/mongodb
    # Move the user creation script
       sudo mv /tmp/create-users.js /etc/mongodb/create-users.js
       sudo chown mongodb:ubuntu /etc/mongodb/create-users.js
       sudo chmod 0440 /etc/mongodb/create-users.js  
  sudo systemctl enable mongod || { echo "systemctl enable failed"; exit 1; }
  sudo systemctl start mongod || { echo "mongod start failed"; exit 1; }
  sudo echo "user_data script completed" >> /var/log/user-data.log
  EOF
}
resource "aws_security_group" "mongo_sg" {
  ingress {
    from_port   = 22 
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "null_resource" "init_replica_set" {
  depends_on = [aws_instance.mongo_node]
  provisioner "remote-exec" {
    inline = [
      "sleep 90",
      "export PATH=$PATH:/usr/bin",
      "until mongosh --host ${aws_instance.mongo_node[0].public_ip}:27017 --quiet --eval 'db.runCommand({ ping: 1 })' > /dev/null 2>&1; do echo 'Waiting for mongod...'; sleep 5; done",
      "mongosh --host ${aws_instance.mongo_node[0].public_ip}:27017 --quiet --eval 'rs.initiate({ _id: \"rs0\", members: [ {_id: 0, host: \"${aws_instance.mongo_node[0].public_ip}:27017\", priority: 2}, {_id: 1, host: \"${aws_instance.mongo_node[1].public_ip}:27017\", priority: 1}, {_id: 2, host: \"${aws_instance.mongo_node[2].public_ip}:27017\", arbiterOnly: true} ] })' || echo 'Replica set already initialized'",
      "mongosh --eval 'rs.status()'",
      "echo 'step 1'",
      "sleep 30",
      "mongosh 'mongodb://${aws_instance.mongo_node[0].public_ip}:27017,${aws_instance.mongo_node[1].public_ip}:27017,${aws_instance.mongo_node[2].public_ip}:27017/admin?replicaSet=rs0' --quiet /etc/mongodb/create-users.js",
      "mongosh 'mongodb://${aws_instance.mongo_node[0].public_ip}:27017,${aws_instance.mongo_node[1].public_ip}:27017,${aws_instance.mongo_node[2].public_ip}:27017/admin?replicaSet=rs0' --quiet --eval 'rs.status()'"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/cloud9.pem")
      host        = aws_instance.mongo_node[0].public_ip
    }
  }
}

output "mongo_ips" {
  value = {
    node0 = "ec2-${replace(aws_instance.mongo_node[0].public_ip, ".", "-")}.us-west-1.compute.amazonaws.com"
    node1 = "ec2-${replace(aws_instance.mongo_node[1].public_ip, ".", "-")}.us-west-1.compute.amazonaws.com"
    node2 = "ec2-${replace(aws_instance.mongo_node[2].public_ip, ".", "-")}.us-west-1.compute.amazonaws.com"
  }
}
