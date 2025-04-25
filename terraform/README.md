# Mongodb Provisioning - Terraform scripts
``` text
tf script 
- started 3 ec2 instances 
- installed mongodb on all of them
- edited the /etc/mongod.conf file to add the three mongodb into a replication set called rs0

## 04 23 2025
- code split
  - part 1 creates mongo nodes, brings in required files 
  - part 2 will create users, determine primary, upload a datafile 
## 04242025 s3 to the rescue
```text 
introduced aws s3 to all the nodes.
the uploads scp was running from the ec2 and not from my local machine, so the locally available datafile was not there.
One option could have been to upload the datafile along with other files we have been uploading, but that would be
waste of resurce. Every failure, you will need to uplaod the huge datafile again . Huge mean 5 mb :D
``` 
