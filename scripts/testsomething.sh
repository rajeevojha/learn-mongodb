#!/bin/bash
  echo BEGIN
  sudo apt update
  sudo apt upgrade -y
  sudo apt install -y unzip
  echo END
echo "Starting user_data script" | tee -a user-data.log

{
  grep PRETTY_NAME /etc/os-release
  echo "Hello from user-data!"
  apt-get update
  ...
} 2>&1 | tee -a user-data.log
