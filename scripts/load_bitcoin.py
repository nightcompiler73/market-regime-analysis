import yfinance as yf
import duckdb

print("Downloading Bitcoin data...")

btc = yf.download(
    "BTC-USD",
    period="5y",
    auto_adjust=True
)

btc.columns = btc.columns.get_level_values(0)
btc = btc.reset_index()

print(btc.head())

con = duckdb.connect("data/market_data.duckdb")

con.register("btc_df", btc.reset_index())

con.execute("""
CREATE OR REPLACE TABLE bitcoin_prices AS
SELECT *
FROM btc_df
""")

count = con.execute("""
SELECT COUNT(*)
FROM bitcoin_prices
""").fetchone()[0]

print(f"Rows loaded: {count}")

con.close()