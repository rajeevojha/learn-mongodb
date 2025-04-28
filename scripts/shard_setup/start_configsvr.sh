#!/bin/bash
mongod --configsvr --replSet configReplSet \
  --port 27019 \
  --dbpath $(pwd)/data/config1 \
  --bind_ip localhost \
  --fork --logpath $(pwd)/data/config1/configsvr.log

