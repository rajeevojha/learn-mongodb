#!/bin/bash
exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
echo "Running user-data script..."
cat /etc/os-release | grep PRETTY_NAME
apt-get update
apt-get install -y gnupg curl unzip
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
# Add MongoDB repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg

apt-get update
apt-get install -y mongodb-org mongodb-mongosh
# Modify mongod.conf
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
sed -i 's/^#replication:/replication:/' /etc/mongod.conf
sed -i '/^replication:/a\  replSetName: "rs0"' /etc/mongod.conf
# dir listing
ls -l /home/ubuntu/tmp/
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

# Move key file
cp /tmp/cloud9.pem /home/ubuntu/.ssh/cloud9.pem
chown ubuntu:ubuntu /home/ubuntu/.ssh/cloud9.pem
chmod 0400 /home/ubuntu/.ssh/cloud9.pem

# Enable and start MongoDB
  systemctl enable mongod
  systemctl start mongod

sleep 30

echo "User-data script completed"
mongosh --version
