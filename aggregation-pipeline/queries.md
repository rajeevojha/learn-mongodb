# Aggregation Pipeline – Example Queries

This file will contain:
- Sample pipelines on collections
- Grouping, filtering, sorting
- Real-world data processing

## total number of documents
   ```code
   db.orders.aggregate([{
             $group: {
                       _id: null, 
                     count: {
                             $count:{} 
                            }
                     }
                   }])
    ```

## total number of orders by customers
    ```
    db.orders.aggregate([{$group: {_id: "$Customer ID", count: {$count:{}}}}])
    ```

## total number of customers
    ```
    db.orders.aggregate([{$group: {_id: "$Customer ID"}},{$count : "total customers"}])
    ```

## total sales by category
    ```
    db.orders.aggregate([{$group: {_id: "$Category",totalSales:{$sum:"$Sales"}}}])
    ```

## top 5 customers by total sales
    ```
   db.orders.aggregate([{$group : {_id: "$Customer ID","total Sales": {$sum : "$Sales"}}},{$sort:{"total Sales":-1}},{$limit:5}])
   ```

## Average discount per region
   ```
   db.orders.aggregate([{$group: {_id:"$Region",avg:{$avg:"$Discount"}}}])
   ```

## For every state find the max order
   ```
   db.orders.aggregate([{$group: {_id: "$State", maxOrder: {$max: "$Sales"}}}])
   ```
=================================================================================================
## Slightly complex queries
================================================================================================
## Find top 3 selling products per region

