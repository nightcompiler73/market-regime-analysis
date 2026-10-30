import duckdb

conn = duckdb.connect("data/market_data.duckdb")

# Fact table
conn.execute("""
COPY (
    SELECT *
    FROM fct_market_regime
)
TO 'exports/fct_market_regime.parquet'
(FORMAT PARQUET);
""")

# Date dimension
conn.execute("""
COPY (
    SELECT *
    FROM dim_date
)
TO 'exports/dim_date.parquet'
(FORMAT PARQUET);
""")

conn.close()

print("Parquet exports completed.")