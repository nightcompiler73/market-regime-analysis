select
    cast(Date as date) as date,
    cast(Close as double) as vix_close
from vix_prices