from flask import Flask, request, jsonify
from pymongo import MongoClient
import datetime

app = Flask(__name__)

# MongoDB connection
client = MongoClient("mongodb://localhost:27017/")
db = client["superstore"]
saless_collection = db["sales"]

# Create a sales
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

# List saless
@app.route("/sales", methods=["GET"])
def get_saless():
    status = request.args.get("status")
    query = {"status": status} if status else {}
    saless = list(saless_collection.find(query))
    for sales in saless:
        sales["_id"] = str(sales["_id"])  # Convert ObjectId to string
    return jsonify(saless)

if __name__ == "__main__":
    app.run(debug=True)
