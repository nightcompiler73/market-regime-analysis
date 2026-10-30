select
    cast(date as date) as date,
        case
        when value = '.' then null
        else cast(value as double)
    end as cpi_value,
    cast(realtime_start as date) as realtime_start,
    cast(realtime_end as date) as realtime_end
from cpi