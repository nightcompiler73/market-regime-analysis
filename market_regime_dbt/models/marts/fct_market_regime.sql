with joined_data as (

    select
        m.date,
        m.spy_close,
        m.bitcoin_close,
        m.ethereum_close,
        m.vix_close,

        last_value(e.cpi_value ignore nulls)
        over (
            order by m.date
            rows between unbounded preceding and current row
        ) as cpi_value,

        last_value(e.fed_funds_rate ignore nulls)
        over (
            order by m.date
            rows between unbounded preceding and current row
        ) as fed_funds_rate,

        last_value(e.unemployment_rate ignore nulls)
        over (
            order by m.date
            rows between unbounded preceding and current row
        ) as unemployment_rate,

        last_value(e.treasury_10y ignore nulls)
        over (
            order by m.date
            rows between unbounded preceding and current row
        ) as treasury_10y,

        last_value(e.recession_flag ignore nulls)
        over (
            order by m.date
            rows between unbounded preceding and current row
        ) as recession_flag

    from {{ ref('fct_market_prices') }} m

    left join {{ ref('fct_macroeconomic_indicators') }} e
        on m.date = e.date

),

returns as (

    select

        *,

        (
            spy_close /
            lag(spy_close) over (
                order by date
            )
        ) - 1 as spy_daily_return,

        (
            bitcoin_close /
            lag(bitcoin_close) over (
                order by date
            )
        ) - 1 as bitcoin_daily_return,

        (
            ethereum_close /
            lag(ethereum_close) over (
                order by date
            )
        ) - 1 as ethereum_daily_return,

        (
            spy_close /
            lag(spy_close, 30) over (
                order by date
            )
        ) - 1 as spy_return_30d,

        (
            bitcoin_close /
            lag(bitcoin_close, 30) over (
                order by date
            )
        ) - 1 as bitcoin_return_30d,

        (
            ethereum_close /
            lag(ethereum_close, 30) over (
                order by date
            )
        ) - 1 as ethereum_return_30d,

        (
            spy_close /
            lag(spy_close, 90) over (
                order by date
            )
        ) - 1 as spy_return_90d,

        (
            bitcoin_close /
            lag(bitcoin_close, 90) over (
                order by date
            )
        ) - 1 as bitcoin_return_90d,

        (
            ethereum_close /
            lag(ethereum_close, 90) over (
                order by date
            )
        ) - 1 as ethereum_return_90d,

        (
            vix_close /
            lag(vix_close) over (
                order by date
            )
        ) - 1 as vix_daily_return,

        (
            vix_close /
            lag(vix_close, 30) over (
                order by date
            )
        ) - 1 as vix_change_30d,
        
            cpi_value -
            lag(cpi_value, 365) over (
                order by date
            ) as cpi_change_12m,


           fed_funds_rate -
lag(fed_funds_rate, 365) over (
    order by date
) as fed_funds_change_12m,

    from joined_data
),



analytics as (

    select

        *,

        stddev_samp(spy_daily_return) over (
            order by date
            rows between 89 preceding and current row
        ) as spy_volatility_90d,

        stddev_samp(bitcoin_daily_return) over (
            order by date
            rows between 89 preceding and current row
        ) as bitcoin_volatility_90d

    from returns
),

correlations as (

    select

        *,

        corr(
            spy_daily_return,
            bitcoin_daily_return
        ) over (
            order by date
            rows between 89 preceding and current row
        ) as rolling_spy_btc_corr_90d,
        corr(
            spy_daily_return,
            vix_daily_return
        ) over (
            order by date
            rows between 89 preceding and current row
        ) as rolling_spy_vix_corr_90d,
        corr(
            bitcoin_daily_return,
            vix_daily_return
        ) over (
            order by date
            rows between 89 preceding and current row
        ) as rolling_btc_vix_corr_90d

    from analytics

)

select

    date,

    spy_close,
    bitcoin_close,
    ethereum_close,
    vix_close,
    vix_daily_return,

    vix_change_30d,

    spy_daily_return,
    spy_return_30d,
    spy_return_90d,
    spy_volatility_90d,
    rolling_spy_vix_corr_90d,

    bitcoin_daily_return,
    bitcoin_return_30d,
    bitcoin_return_90d,
    bitcoin_volatility_90d,
    rolling_spy_btc_corr_90d,
    rolling_btc_vix_corr_90d,

    ethereum_daily_return,
    ethereum_return_30d,
    ethereum_return_90d,

    cpi_change_12m,
    fed_funds_change_12m,

    case when spy_return_90d > 0 then 1 else 0 end
    as spy_regime_flag,

    case when bitcoin_return_90d > 0 then 1 else 0 end
    as bitcoin_regime_flag,

    case when vix_change_30d < 0 then 1 else 0 end
    as vix_regime_flag,

    case when cpi_change_12m < 0 then 1 else 0 end
    as cpi_regime_flag,

    case when fed_funds_change_12m < 0 then 1 else 0 end
    as fed_regime_flag,

    case
        when vix_close >= 30 then 'High Volatility'
        when vix_close >= 20 then 'Moderate Volatility'
        else 'Low Volatility'
    end as volatility_regime,

    cpi_value,

    case
        when cpi_value >= 300 then 'High Inflation'
        else 'Normal Inflation'
    end as inflation_regime,

    fed_funds_rate,

    case
        when fed_funds_rate >= 5 then 'High Rate Environment'
        when fed_funds_rate >= 2 then 'Moderate Rate Environment'
        else 'Low Rate Environment'
    end as rate_regime,

    unemployment_rate,
    treasury_10y,
    recession_flag,

    case
        when recession_flag = 1 then 'Recession'
        else 'Expansion'
    end as economic_regime,

(
            case when spy_return_90d > 0 then 1 else 0 end
            +
            case when bitcoin_return_90d > 0 then 1 else 0 end
            +
            case when vix_change_30d < 0 then 1 else 0 end
            +
            case when cpi_change_12m < 0 then 1 else 0 end
            +
            case when fed_funds_change_12m < 0 then 1 else 0 end
)
    as market_regime_score,

case

    when (
        case when spy_return_90d > 0 then 1 else 0 end
        +
        case when bitcoin_return_90d > 0 then 1 else 0 end
        +
        case when vix_change_30d < 0 then 1 else 0 end
        +
        case when cpi_change_12m < 0 then 1 else 0 end
        +
        case when fed_funds_change_12m < 0 then 1 else 0 end
    ) >= 4
    then 'Risk On'

    when (
        case when spy_return_90d > 0 then 1 else 0 end
        +
        case when bitcoin_return_90d > 0 then 1 else 0 end
        +
        case when vix_change_30d < 0 then 1 else 0 end
        +
        case when cpi_change_12m < 0 then 1 else 0 end
        +
        case when fed_funds_change_12m < 0 then 1 else 0 end
    ) >= 2
    then 'Neutral'

    else 'Risk Off'

end as market_regime

from correlations