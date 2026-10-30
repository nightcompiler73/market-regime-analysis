import yfinance as yf
import duckdb

print("Downloading Ethereum data...")

eth = yf.download(
    "ETH-USD",
    period="5y",
    auto_adjust=True
)

eth.columns = eth.columns.get_level_values(0)
eth = eth.reset_index()

print(eth.head())

con = duckdb.connect("data/market_data.duckdb")

con.register("eth_df", eth.reset_index())

con.execute("""
CREATE OR REPLACE TABLE ethereum_prices AS
SELECT *
FROM eth_df
""")

count = con.execute("""
SELECT COUNT(*)
FROM ethereum_prices
""").fetchone()[0]

print(f"Rows loaded: {count}")

con.close()