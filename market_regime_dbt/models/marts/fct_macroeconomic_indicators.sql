select
    c.date,
    c.cpi_value,
    f.fed_funds_rate,
    u.unemployment_rate,
    t.treasury_10y,
    r.recession_flag

from {{ ref('stg_cpi') }} c

left join {{ ref('stg_fed_funds_rate') }} f
    on c.date = f.date

left join {{ ref('stg_unemployment_rate') }} u
    on c.date = u.date

left join {{ ref('stg_treasury_10y') }} t
    on c.date = t.date

left join {{ ref('stg_recession_indicator') }} r
    on c.date = r.date