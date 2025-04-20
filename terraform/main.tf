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
  user_data = <<-EOF
    #!/bin/bash
    apt update
    apt-get install gnupg curl
    curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
    apt-get update
    apt-get install -y mongodb-org
    sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
    echo -e 'replication:\n  replSetName: "rs0"' >> /etc/mongod.conf
    systemctl enable mongod
    systemctl start mongod
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
      "sleep 30", # Wait for mongod to fully start
      "until /usr/bin/mongosh --eval 'db.runCommand({ ping: 1 })'; do echo 'Waiting for mongod...'; sleep 5; done", # Retry until mongod is up
      "/usr/bin/mongosh --eval 'rs.initiate({ _id: \"rs0\", members: [ {_id: 0, host: \"${aws_instance.mongo_node[0].public_ip}:27017\"}, {_id: 1, host: \"${aws_instance.mongo_node[1].public_ip}:27017\"}, {_id: 2, host: \"${aws_instance.mongo_node[2].public_ip}:27017\", arbiterOnly: true} ] })'"
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
  value = aws_instance.mongo_node[*].public_ip
}
