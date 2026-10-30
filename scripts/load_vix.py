import yfinance as yf
import duckdb

print("Downloading VIX data...")

vix = yf.download(
    "^VIX",
    period="5y",
    auto_adjust=True
)

vix.columns = vix.columns.get_level_values(0)
vix = vix.reset_index()

print(vix.head())

con = duckdb.connect("data/market_data.duckdb")

con.register("vix_df", vix.reset_index())

con.execute("""
CREATE OR REPLACE TABLE vix_prices AS
SELECT *
FROM vix_df
""")

count = con.execute("""
SELECT COUNT(*)
FROM vix_prices
""").fetchone()[0]

print(f"Rows loaded: {count}")

con.close()
