provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "mongo_node" {
  count         = 3
  ami           = "ami-04f7a54071e74f488" # Ubuntu 24.04 AMI (us-west-1)
  instance_type = "t3.micro"
  key_name      = "cloud9"
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_read_access.name
  vpc_security_group_ids = [aws_security_group.mongo_sg.id]
  tags = {
    Name = "mongo-node-${count.index}"
  }

#upload the mongo util script
  provisioner "file" {
    source      = "${path.module}/../scripts/mongo_utils.js"
    destination = "/tmp/mongo_utils.js"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/cloud9.pem")
      host        = self.public_dns
    }
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

#upload the key file
  provisioner "file" {
    source      = "~/.ssh/cloud9.pem"
    destination = "/tmp/cloud9.pem"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/cloud9.pem")
      host        = self.public_dns
    }
  }
  user_data = <<-EOF
  #!/bin/bash
  exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
  echo "Running user-data script..."

  cat /etc/os-release | grep PRETTY_NAME

  apt-get update
  apt-get install -y gnupg curl unzip

  # Install AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  echo "installing aws cli"

  sudo ./aws/install

  
  # Add MongoDB repository
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
  curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg

  apt-get update
  echo "installing mongodb"
  apt-get install -y mongodb-org mongodb-mongosh

  # Modify mongod.conf
  sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
  sed -i 's/^#replication:/replication:/' /etc/mongod.conf
  sed -i '/^replication:/a\  replSetName: "rs0"' /etc/mongod.conf

  # Set up keyfile security
  mkdir -p /etc/mongodb/pki
  mv /tmp/mongodb-keyfile.pem /etc/mongodb/pki/mongodb-keyfile.pem
  chown mongodb:mongodb /etc/mongodb/pki/mongodb-keyfile.pem
  chmod 0400 /etc/mongodb/pki/mongodb-keyfile.pem
  chmod 0755 /etc/mongodb

  # Move user creation script
  mv /tmp/mongo_utils.js /etc/mongodb/mongo_utils.js
  chown mongodb:ubuntu /etc/mongodb/mongo_utils.js
  chmod 0440 /etc/mongodb/mongo_utils.js

   # Move security pem file paleez
  mv /tmp/cloud9.pem /home/ubuntu/.ssh/cloud9.pem
  chown ubuntu:ubuntu /home/ubuntu/.ssh/cloud9.pem
  chmod 0400 /home/ubuntu/.ssh/cloud9.pem

  # Enable and start MongoDB
  systemctl enable mongod
  systemctl start mongod

  echo "User-data script completed"
  mongosh --version
  EOF
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_policy_attachment" "attach_s3" {
  name       = "ec2-s3-access"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_s3_read_access" {
  name = "ec2-s3-read-access"
  role = aws_iam_role.ec2_role.name
}

resource "aws_security_group" "mongo_sg" {

  ingress {
    from_port   = 22 
    to_port     = 22
    protocol    = "tcp"
   # cidr_blocks = ["${var.my_ip}/32"]
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

output "mongo_ips" {
  value = {
    node0 = "ec2-${replace(aws_instance.mongo_node[0].public_ip, ".", "-")}.us-west-1.compute.amazonaws.com"
    node1 = "ec2-${replace(aws_instance.mongo_node[1].public_ip, ".", "-")}.us-west-1.compute.amazonaws.com"
    node2 = "ec2-${replace(aws_instance.mongo_node[2].public_ip, ".", "-")}.us-west-1.compute.amazonaws.com"
  }
}
