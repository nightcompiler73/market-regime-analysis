with dates as (

    select *
    from generate_series(
        date '2021-01-01',
        current_date,
        interval 1 day
    ) as t(date)

)

select
    date,

    year(date) as year,

    quarter(date) as quarter,

    month(date) as month_number,

    strftime(date, '%B') as month_name,

    strftime(date, '%b') as month_short,

    strftime(date, '%Y-%m') as year_month,

    strftime(date, '%b %Y') as year_month_label,

    year(date) * 100 + month(date) as year_month_sort,

    concat('Q', quarter(date), ' ', year(date))
        as quarter_label,

    year(date) * 10 + quarter(date)
        as quarter_sort,

    concat(
        year(date),
        '-Q',
        quarter(date)
    ) as year_quarter,

    case
        when date = last_day(date)
        then true
        else false
    end as is_month_end,

    case
        when date = last_day(date)
            and month(date) in (3, 6, 9, 12)
        then true
        else false
    end as is_quarter_end,

    case
        when month(date) = 12
            and day(date) = 31
        then true
        else false
    end as is_year_end

from dates
