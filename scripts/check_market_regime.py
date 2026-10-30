import duckdb

con = duckdb.connect("data/market_data.duckdb")

print(
    con.execute("""
    select *
    from fct_market_regime
    limit 5
    """).fetchall()
)

con.close()