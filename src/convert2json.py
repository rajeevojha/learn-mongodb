import pandas as pd
import json

df = pd.read_csv("../data/train.csv")
df["Postal Code"] = df["Postal Code"].fillna(0)
sales_json = df.to_dict(orient="records")
with open ("../data/train.json","w") as f:
    json.dump(sales_json,f)
