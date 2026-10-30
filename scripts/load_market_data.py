import yfinance as yf
import duckdb

print("Downloading SPY data...")

spy = yf.download(
    "SPY",
    period="5y",
    auto_adjust=True
)

# Flatten MultiIndex columns
spy.columns = spy.columns.get_level_values(0)

spy = spy.reset_index()

print(spy.head())

con = duckdb.connect("data/market_data.duckdb")

con.register("spy_df", spy)

con.execute("""
CREATE OR REPLACE TABLE spy_prices AS
SELECT *
FROM spy_df
""")

count = con.execute("""
SELECT COUNT(*)
FROM spy_prices
""").fetchone()[0]

print(f"Rows loaded: {count}")

con.close()