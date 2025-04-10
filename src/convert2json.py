import pandas as pd
from datetime import datetime as dt
import json

df = pd.read_csv("../data/train.csv")
df["Postal Code"] = df["Postal Code"].fillna(0)
#df = df.where(pd.notnull(df),None)
#convert Ship Date and Order Date to date type.
df['Order Date'] = pd.to_datetime(df['Order Date'], format='%d/%m/%Y').astype(str)
df['Ship Date'] = pd.to_datetime(df['Ship Date'], format='%d/%m/%Y').astype(str)
sales_json = df.to_dict(orient="records")
with open ("../data/train.json","w") as f:
    json.dump(sales_json,f,indent=2)

