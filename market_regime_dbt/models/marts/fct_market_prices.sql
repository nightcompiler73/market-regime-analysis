select
    s.date,
    s.spy_close,
    b.bitcoin_close,
    e.ethereum_close,
    v.vix_close

from {{ ref('stg_spy_prices') }} s

left join {{ ref('stg_bitcoin_prices') }} b
    on s.date = b.date

left join {{ ref('stg_ethereum_prices') }} e
    on s.date = e.date

left join {{ ref('stg_vix_prices') }} v
    on s.date = v.date