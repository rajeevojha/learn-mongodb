mongoimport --host localhost --port 27017 \
  --db superstore --collection orders \
  --type csv --headerline \
  --file $(pwd)/dataset/superstore.csv

