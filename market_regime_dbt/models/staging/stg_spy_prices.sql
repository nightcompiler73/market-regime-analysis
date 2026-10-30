select
    cast(Date as date) as date,
    cast(Close as double) as spy_close,
    cast(Volume as bigint) as volume
from spy_prices
