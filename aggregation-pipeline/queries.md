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

{
  _id: ObjectId(...),
  region: "East",
  product: "Notebook",
  amount: 120
}

## Find Top-Selling Product per Region
> Expected output in following format.
> {
>   region: "East",
>   topProduct: "Notebook",
>   totalSales: 9000
> }
```
db.sales.aggregate([
  {
    $group: {
      _id: { region: "$region", product: "$product" },
      totalSales: { $sum: "$amount" }
    }
  },
  { $sort: { "_id.region": 1, totalSales: -1 } },
  {
    $group: {
      _id: "$_id.region",
      topProduct: { $first: "$_id.product" },
      totalSales: { $first: "$totalSales" }
    }
  },
  {
    $project: {
      _id: 0,
      region: "$_id",
      topProduct: 1,
      totalSales: 1
    }
  }
])
```
## some facet practice next
> consider the following document structure
>  {
>  _id: 1,
>  name: "Phone",
>  category: "Electronics",
>  price: 799,
>  rating: 4.5
> }
  Return bucketed price info, rating stats and category breakouts
```
db.product.aggregate([
  {
    $facet: {
      priceBucket: [
        {
          $bucket: {
            groupBy: "$price",
            boundaries: [0, 50, 100, 150, 200, 250, 300],
            default: "Other",
            output: {
              count: { $sum: 1 },
              avgPrice: { $avg: "$price" },
              minPrice: { $min: "$price" },
              maxPrice: { $max: "$price" },
            },
          },
        },
      ],
      ratingStats: [
        {
          $group: {
            _id: null,
            avgRating: { $avg: "$rating" },
            minRating: { $min: "$rating" },
            maxRating: { $max: "$rating" },
          },
        },
      ],
      categoryCount: [
        {
          $group: {
            _id: "$category",
            count: { $sum: 1 },
          },
        },
      ],
    },
  },
]);
```
## facet example 2
> Write a $facet query on a sales collection to return:
> Total sales per region
> Top 3 products by quantity sold
 


``` 
db.sales.aggregate([
  {
    $facet: {
      salesPerRegion: [
        { $group: { _id: "$region", salesPerReg: { $sum: "$amount" } } },
      ],
      top3Products: [
        { $group: { _id: "$product", totalSales: { $sum: "$amount" } } },
        { $sort: { totalSales: -1 } },
        { $limit: 3 },
      ],
    },
  },
]);

```
# conditional switch case 
{
  "_id": ObjectId("..."),
  "region": "East",
  "product": "iPhone",
  "amount": 1200,
  "customer": {
    "name": "John Doe",
    "tier": "Gold"
  }
}

> Create a new field called tierStatus with the following logic:
> If the customer's tier is "Gold" → return "Premium"
> If it's "Silver" → return "Standard"
> If it's missing or anything else → return "Basic"
 
```
db.orders.aggregate([
  {
    $project: {
      _id: 0,
      product: 1,
      tierStatus: {
        $switch: {
          $branches: [
            { case: { $eq: ["$customer.tier", "Gold"] }, then: "Premium" },
            { case: { $eq: ["$customer.tier", "Silver"] }, then: "Standard" },
          ],
          default: "Basic"
        },
      },
    },
  },
]);
```
## another example for switch
Write an aggregation query that:

> Projects product, amount, and a new field called discountRate.
> Based on the customer tier:
> "Gold" → 20%
> "Silver" → 10%
> "Bronze" → 5%
> Missing or any other → 0%
> Return the discount as a number: 0.2, 0.1, 0.05, or 0.0.
```
db.sales.aggregate([
  {
    $project: {
      _id: 0,
      product: 1,
      amount: 1,
      discountRate: {
        $switch: {
          branches: [
            { case: { $eq: ["$customer.tier", "Gold"] }, then: 0.2 },
            { case: { $eq: ["$customer.tier", "Silver"] }, then: 0.1 },
            { case: { $eq: ["$customer.tier", "Bronze"] }, then: 0.05 }
          ],
          default: 0.0
        }
      }
    }
  }
]);
```
