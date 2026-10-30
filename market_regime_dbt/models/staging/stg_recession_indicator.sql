select
    cast(date as date) as date,
    cast(value as integer) as recession_flag
from recession_indicator
