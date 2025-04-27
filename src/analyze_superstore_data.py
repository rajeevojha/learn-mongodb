import pandas as pd
import json

# Load Superstore JSON data
#with open("~/superstore.json") as f:
#    data = [json.loads(line) for line in f]
#df = pd.DataFrame(data)

# Load superstore csv data
df = pd.read_csv("../data/train.csv")

# Basic overview
print("Dataset Info:")
print(df.info())
print("\nSample Data:")
print(df.head())

# Analyze potential shard keys
print("\nUnique Values and Cardinality:")
for col in ["Customer ID", "Region", "Product ID", "Order ID"]:
    unique_count = df[col].nunique()
    total_count = len(df)
    print(f"{col}: {unique_count} unique values ({unique_count/total_count*100:.2f}% cardinality)")

# Distribution of key fields
print("\nDistribution by Region:")
print(df["Region"].value_counts())
print("\nDistribution by Customer ID (Top 5):")
print(df["Customer ID"].value_counts().head())
print("\nDistribution by Product ID (Top 5):")
print(df["Product ID"].value_counts().head())

# Query pattern analysis
print("\nSales by Region:")
print(df.groupby("Region")["Sales"].sum().sort_values(ascending=False))
print("\nOrders per Customer (Top 5):")
print(df.groupby("Customer ID")["Order ID"].count().sort_values(ascending=False).head())

print("\nOrders per product (Top 5):")
print(df.groupby("Product ID")["Order ID"].count().sort_values(ascending=False).head())
