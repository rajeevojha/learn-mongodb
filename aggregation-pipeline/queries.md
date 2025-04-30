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
============================================================================================
## Slightly complex queries
============================================================================================
## Find top 3 selling products per region
```
   db.orders.aggregate([{$group:{_id: {region:"$Region",product:"$Product ID"},totalSales:{$sum:"$Sales"}}},{$sort:{totalSales:-1}},{$limit:3}])
```
## For each Region + Category combination, calculate the average Sales.
```
   db.orders.aggregate([{$group:{_id:{region:"$Region",category: "$Category"},avgSales:{$avg:"$Sales"}}}])
```  
## Now add a sort step, sort by average sales
```
    db.orders.aggregate([{$group:{_id:{region:"$Region",category: "$Category"},avgSales:{$avg:"$Sales"}}},{$sort:{avgSales:1}}])
```
## For each State, find the top-selling product (based on total sales) and its corresponding total sales.
```
  db.orders.aggregate([
    {
        $group: {
            _id: {
                state: "$State", product: "$Product ID"
            }, totalSales: {
                $sum: "$Sales"
            }
        }
    },
    {
        $sort: {
            "_id.state": -1, totalSales: -1
        }
    },
    {
        $group: {
            _id: "$_id.state", topProduct: {
                $first: "$_id.product"
            }, totalSales: {
                $first: "$totalSales"
            }
        }
    }
])

```
## 	For each Region, bucket states into 2 groups: those with total sales above $1000 and below.
```
   db.orders.aggregate([
  // Step 1: Group by Region and State, and calculate total sales for each state
  {
    $group: {
      _id: { region: "$Region", state: "$State" },
      totalSales: { $sum: "$Sales" }
    }
  },
  // Step 2: Bucket states based on total sales
  {
    $bucket: {
      groupBy: "$totalSales", // Group by total sales value
      boundaries: [0, 5000, Infinity], // Define the ranges: [0, 1000) and [1000, Infinity)
      default: "Other", // For values outside the defined range, use "Other"
      output: {
        statesAbove1000: { $sum: { $cond: [{ $gte: ["$totalSales", 5000] }, 1, 0] } }, // Count states with total sales >= 5000
        statesBelow1000: { $sum: { $cond: [{ $lt: ["$totalSales", 5000] }, 1, 0] } }  // Count states with total sales < 5000
      }
    }
  }
])

```
## For each region, bucket states into 2 groups, those with total sales above $5000 and below. Make sure to include state name in the output
```
db.orders.aggregate([{$group:{_id:{region:"$Region",state:"$State"},totalSales: {$sum:"$Sales"}}},
   {
     $bucket:{
            groupBy: "$totalSales",
            boundaries:[0,5000,Infinity],
            default: "Others",
            output: {
               statesAbv5000:{$push: {$cond:[{$gte:["$totalSales", 5000]},"$_id","$$REMOVE"]}},
               statesBelow5000:{$push: {$cond:[{$lt:["$totalSales",5000]},"$_id","$$REMOVE"]}}
            }
         }
   }
])
```

## For each region, bucket states as above, include the sales amount too. Keep the regions together in the output
db.orders.aggregate([{$group:{_id:{region:"$Region",state:"$State"},totalSales: {$sum:"$Sales"}}},
...    {
...      $bucket:{
...             groupBy: "$totalSales",
...             boundaries:[0,5000,Infinity],
...             default: "Others",
...             output: {
...                statesAbv5000:{$push: {$cond:[{$gte:["$totalSales", 5000]},{_id: "$_id",sales:"$totalSales"},"$$REMOVE"]}},
...                statesBelow5000:{$push: {$cond:[{$lt:["$totalSales",5000]},{_id: "$_id",sales:"$totalSales"},"$$REMOVE"]}}
...             }
...          }
...    }
... ])

## group customers into three part, small ,medium and large
``` 
db.orders.aggregate([
{$group:{_id:"$Customer ID",totalSales:{$sum:"$Sales"}}},
{$bucket:{
  groupBy: "$totalSales",
  boundaries:[0,1000,5000,Infinity],
  default: "Others",
  output:{
   small:{$push: {$cond:[{$lt:["$totalSales",1000]},{_id:"$_id",totalSales:"$totalSales"},"$$REMOVE"]}},
   medium:{$push:{$cond:[{$and:[{$gt:["$totalSales",1000]},{$lt:["$totalSales",5000]}]},{_id:"$_id",totalSales:"$totalSales"},"$$REMOVE"]}},
   large:{$push: {$cond:[{$gte:["$totalSales",5000]},{_id:"$_id",totalSales:"$totalSales"},"$$REMOVE"]}}
   }
 }
}])
```
in the above example, if say we also need the name of the customer, we have to start at the group stage itself and start carrying the customer name for the next output step.

{$group:{_id:"$Customer ID",totalSales:{$sum:"$Sales"},customerName:"$Customer Name"}},
and then during the output step include it as { _id: "$_id", name: "$customerName", totalSales: "$totalSales" },

## $bucket operator - less flexible, but very quick
useful in case no manipulation is requierd.
``` 
 db.orders.aggregate([
...   {
...     $group: {
...       _id: "$Customer ID",
...       totalSales: { $sum: "$Sales" }
...     }
...   },
...   {
...     $bucket: {
...       groupBy: "$totalSales",
...       boundaries: [0, 1000, 5000, Infinity],
...       default: "Others",
...       output: {
...         customers: {
...           $push: {
...             customerId: "$_id",
...             totalSales: "$totalSales"
...           }
...         }
...       }
...     }
...   }
... ])
...
```

## FACET Examples
- Running multiple pipelines in one go

## some more queries match->group->project->sort
``` 
assume a collection as 
  {
  "_id": ObjectId("..."),
  "region": "West",
  "category": "Furniture",
  "amount": 500,
  "status": "Completed"
}
Find average sale amount per category, but only where amount > 100. Show category and avgSale (rounded). Sort by avgSale descending.
db.sales.aggregate([
  // 1. Filter only documents where amount > 100
  { $match: { amount: { $gt: 100 } } },

  // 2. Group by category, calculate average amount
  {
    $group: {
      _id: "$category",
      avgSale: { $avg: "$amount" }
    }
  },

  // 3. Project category and rounded average sale
  {
    $project: {
      category: "$_id",
      avgSale: { $round: ["$avgSale", 0] },
      _id: 0
    }
  },

  // 4. Sort by average sale descending
  { $sort: { avgSale: -1 } }
])
```
> From the orders collection, write an aggregation that:
> Filters only orders where total Sales is greater than 500.
> Groups by Region, calculating total sales and average sales per region.
> Projects the region name and rounded average sales.
> Sorts the results by total sales (descending).
```
db.sales.aggregate([
  { 
    $match: { amount: { $gt: 100 } } 
  },
  { 
    $group: { 
      _id: "$region",
      totalSale: { $sum: "$amount" },
      avgSale: { $avg: "$amount" }
    } 
  },
  { 
    $project: { 
      _id: 0,
      region: "$_id",
      totalSale: 1,
      avgSale: { $round: ["$avgSale", 0] }
    } 
  },
  { 
    $sort: { totalSale: -1 } 
  }
])
```
> Write an aggregation on the sales collection to show, for each category:
> - Total number of sales (call it numSales)
> - Average amount (rounded to 2 decimal places)
> - Only include sales where amount > 50
> - Sort by numSales in descending order
```
db.sales.aggregate([
{ $match: {amount: {$gt:50}}
},
{ 
  $group:{
    _id:"$category",
    numSales:{$sum:1},
    avgAmt: {$avg:"$amount"}
  }
},
{
 $project:{
   _id: 0,
   category: "$_id",
   numSales:1,
   avgAmt:{$round:["$avgAmt",2]}
  }
},
{$sort: {numSales:-1}}
])
```
