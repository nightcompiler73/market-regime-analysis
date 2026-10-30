import duckdb

con = duckdb.connect("data/market_data.duckdb")

con.execute("""
DROP TABLE IF EXISTS test_table
""")

tables = con.execute("""
SHOW TABLES
""").fetchall()

print(tables)

con.close()