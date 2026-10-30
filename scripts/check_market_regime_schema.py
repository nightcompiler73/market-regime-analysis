import duckdb

con = duckdb.connect("data/market_data.duckdb")

result = con.execute("""
DESCRIBE fct_market_regime
""").fetchall()

for row in result:
    print(row)

con.close()