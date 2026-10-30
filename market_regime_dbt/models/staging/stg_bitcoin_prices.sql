select
    cast(Date as date) as date,
    cast(Close as double) as bitcoin_close,
    cast(Volume as bigint) as volume
from bitcoin_prices