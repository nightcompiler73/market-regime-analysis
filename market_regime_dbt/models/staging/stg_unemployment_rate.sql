select
    cast(date as date) as date,
       case
        when value = '.' then null
        else cast(value as double)
    end as unemployment_rate
from unemployment_rate