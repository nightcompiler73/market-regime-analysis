import duckdb

con = duckdb.connect("data/market_data.duckdb")

count = con.execute("""
SELECT COUNT(*)
FROM spy_prices
""").fetchone()[0]

print(f"Rows loaded: {count}")

con.close()