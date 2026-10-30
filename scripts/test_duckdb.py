import duckdb

con = duckdb.connect("data/market_data.duckdb")

con.execute("""
CREATE TABLE IF NOT EXISTS test_table (
    id INTEGER,
    message VARCHAR
)
""")

con.execute("""
INSERT INTO test_table
VALUES (1, 'Portfolio Project Started')
""")

result = con.execute(
    "SELECT * FROM test_table"
).fetchall()

print(result)

con.close()