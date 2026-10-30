import os
import requests
import pandas as pd
import duckdb
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("FRED_API_KEY")

url = (
    "https://api.stlouisfed.org/fred/series/observations"
    "?series_id=GS10"
    f"&api_key={API_KEY}"
    "&file_type=json"
)
response = requests.get(url)

data = response.json()["observations"]

df = pd.DataFrame(data)

df["date"] = pd.to_datetime(df["date"])

print(df.head())

con = duckdb.connect("data/market_data.duckdb")

con.register("treasury_10y_df", df)

con.execute("""
CREATE OR REPLACE TABLE treasury_10y AS
SELECT *
FROM treasury_10y_df
""")

count = con.execute("""
SELECT COUNT(*)
FROM treasury_10y
""").fetchone()[0]

print(f"Rows loaded: {count}")

con.close()