#!/bin/bash
mongos --configdb configReplSet/localhost:27019 \
  --bind_ip localhost \
  --port 27017 \
  --fork --logpath $(pwd)/data/mongos.log

