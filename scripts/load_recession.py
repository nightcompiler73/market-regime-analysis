import os
import requests
import pandas as pd
import duckdb
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("FRED_API_KEY")

url = (
    "https://api.stlouisfed.org/fred/series/observations"
    "?series_id=USREC"
    f"&api_key={API_KEY}"
    "&file_type=json"
)

response = requests.get(url)

data = response.json()["observations"]

df = pd.DataFrame(data)

df["date"] = pd.to_datetime(df["date"])

print(df.head())

con = duckdb.connect("data/market_data.duckdb")

con.register("recession_df", df)

con.execute("""
CREATE OR REPLACE TABLE recession_indicator AS
SELECT *
FROM recession_df
""")

count = con.execute("""
SELECT COUNT(*)
FROM recession_indicator
""").fetchone()[0]

print(f"Rows loaded: {count}")

con.close()