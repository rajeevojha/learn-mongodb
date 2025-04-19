#!/bin/bash


# from root
#cd ~/learn-mongodb  # adjust path if different

# Create folders and their README-style .md files
declare -A folders_and_docs=(
  ["dba-ops"]="user-access-roles.md"
  ["security"]="ssl-setup.md"
  ["aggregation-pipeline"]="queries.md"
  ["replica-set"]="config.md"
  ["sharding"]="config.md"
  ["backups-and-recovery"]="ops-manager-notes.md"
)

for folder in "${!folders_and_docs[@]}"; do
  mkdir -p "$folder"
  touch "$folder/${folders_and_docs[$folder]}"
done
#==================================================
#cd ~/learn-mongodb  # adjust path if needed

# Declare folders and their respective .md file names and content
#declare -A md_map
#md_map["dba-ops"]="user-access-roles.md|# MongoDB DBA Operations – User & Access Roles\n\nThis document contains examples and notes on:\n- Creating MongoDB users\n- Granting roles\n- Managing authentication"
#md_map["security"]="ssl-setup.md|# MongoDB Security – SSL/TLS Setup\n\nCovers:\n- Generating certificates\n- Enabling TLS for MongoDB\n- Self-signed vs third-party certs"
#md_map["aggregation-pipeline"]="queries.md|# Aggregation Pipeline – Example Queries\n\nThis file will contain:\n- Sample pipelines on collections\n- Grouping, filtering, sorting\n- Real-world data processing"
#md_map["replica-set"]="config.md|# Replica Set Configuration\n\nIncludes:\n- Initializing a replica set\n- rs.initiate(), rs.status()\n- Adding/removing members"
#md_map["sharding"]="config.md|# Sharded Cluster Configuration\n\nIncludes:\n- Setting up config servers\n- Choosing shard keys\n- Testing shard splits and routing"
#md_map["backups-and-recovery"]="ops-manager-notes.md|# Backups & Recovery using Ops Manager\n\nThis document includes:\n- Ops Manager setup for PITR\n- Snapshots and restores\n- Migration notes"
#
## Loop through and create folders and files
#for folder in "${!md_map[@]}"; do
#  mkdir -p "$folder"
#  
#  IFS='|' read -r filename content <<< "${md_map[$folder]}"
#  
#  # Write the content to the file
#  echo -e "$content" > "$folder/$filename"
#done
#
