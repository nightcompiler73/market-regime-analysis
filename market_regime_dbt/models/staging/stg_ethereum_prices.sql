select
    cast(Date as date) as date,
    cast(Close as double) as ethereum_close,
    cast(Volume as bigint) as volume
from ethereum_prices