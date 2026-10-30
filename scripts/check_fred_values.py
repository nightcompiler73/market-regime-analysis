# scripts/check_fred_values.py

import duckdb

con = duckdb.connect("data/market_data.duckdb")

tables = [
    "cpi",
    "fed_funds_rate",
    "unemployment_rate",
    "treasury_10y",
    "recession_indicator"
]

for table in tables:
    print(f"\n=== {table} ===")

    try:
        result = con.execute(f"""
            select count(*)
            from {table}
            where value = '.'
        """).fetchone()[0]

        print(f"Rows with '.': {result}")

    except Exception as e:
        print(e)

con.close()