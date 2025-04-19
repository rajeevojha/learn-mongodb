# install mongosh

Code Summary: Installing and Connecting to the MongoDB Shell
The following code demonstrates how to install and use mongosh in a Linux environment.

> Update apt and install gnupg. Then add the MongoDB public GPG key to the system.
> apt update 
> apt install <code>gnupg</code>
> wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add - 

## Create a list file for MongoDB.
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod

## Check that mongosh is installed.
mongosh --version

## Exit mongosh.
exit

Connect to Your Atlas Cluster by Using mongosh
The following code demonstrates how to connect to your MongoDB Atlas cluster by using mongosh.

Run the mongosh command followed by your connection string.
mongosh "mongodb+srv://<username>:<password>@<cluster_name>.example.mongodb.net"
Alternatively, you can log in by providing the username and password as a command line argument with -u and -p.

mongosh -u exampleuser -p examplepass "mongodb+srv://myatlasclusteredu.example.mongodb.net"

After connecting to the Atlas cluster, run db.hello(), which provides some information about the role of the mongod instance you are connected to.
db.hello()

Finally, run the exit command inside mongosh to go back to the terminal.
exit
