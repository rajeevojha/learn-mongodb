from flask import Flask, request, jsonify
from pymongo import MongoClient
import datetime

app = Flask(__name__)

# MongoDB connection
client = MongoClient("mongodb://localhost:27017/")
db = client["superstore"]
sales_collection = db["sales"]

# basic route, just get the count of records
@app.route("/",methods=["GET"])
def get_count():
    rec_count = sales_collection.count_documents({})
    return jsonify({"message": f"Connected to superstore.sales with {rec_count} documents"})

# find record given record id
@app.route("/orders/<order_id>",methods=["GET"])
def get_order(order_id):
    if order_id:
        order = sales_collection.find_one({"Order ID":order_id})
        if order:
             order["_id"] = str(order["_id"])
             return jsonify(order)
        return jsonify(jsonify({"error":"Order not found"})),404
    order = sales_collection.find({},{_id:1,"Order ID":1})
    return jsonify(str(order))

# Create a sales record
@app.route("/sales", methods=["POST"])
def create_sales():
    data = request.json
    sales = {
            "Row ID": data.get("Row ID"),
            "Order ID": data.get("Order ID"),
            "Order Date": data.get("Order Date"),
            "Ship Date": data.get("Ship Date"),
            "Ship Mode": data.get("Ship Mode"),
            "Customer ID": data.get("Customer ID"),
            "Customer Name": data.get("Customer Name"),
            "Segment": data.get("Segment"),
            "Country": data.get("Country"),
            "City": data.get("City"),
            "State": data.get("State"),
            "Postal Code": data.get("Postal Code"),
            "Region": data.get("Region"),
            "Product ID": data.get("Product ID"),
            "Category": data.get("Category"),
            "Sub-Category": data.get("Sub-Category"),
            "Product Name": data.get("Product Name"),
            "Sales": data.get("Sales")
    }
    result = saless_collection.insert_one(sales)
    return jsonify({"sales_id": str(result.inserted_id)}), 201

# List sales
@app.route("/sales", methods=["GET"])
def get_sales():
    status = request.args.get("status")
    query = {"status": status} if status else {}
    sales = list(sales_collection.find(query))
    print("count of sales is:", len(sales))
    for sale in sales:
        sale["_id"] = str(sale["_id"])  # Convert ObjectId to string
    return jsonify(sales)

if __name__ == "__main__":
    app.run(debug=True)
