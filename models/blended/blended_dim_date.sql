{{ config(materialized='view') }}
{% set fy_start_month = var('fiscal_year_start_month', 1) %}
with base_dates as (
    select cast(values_datetime as date) as dt from {{ ref('stocks') }}
    union all
    select cast(values_datetime as date) from {{ ref('etfs') }}
    union all
    select cast(values_datetime as date) from {{ ref('forex') }}
    union all
    select cast(values_datetime as date) from {{ ref('crypto') }}
),
normalized as (
    select distinct dt as date
    from base_dates
    where date is not null
),
calc as (
    select
        date as "DATE",
        year(date)                                   as "YEAR",
        lpad(mod(year(date), 100)::string, 2, '0')   as "SHORT_YEAR",
        month(date)                                  as "MONTHNUMBER",
        day(date)                                    as "DAY",
        monthname(date)                              as "MONTH",
        dayofweek(date)                           as "WEEK_DAY",
        to_varchar(date, 'YYYYMM')                  as "YEAR_MONTH",
        concat('Qrt ', quarter(date)) as "QUARTER",
        concat('Q', quarter(date), ' ', year(date)) as "QUARTER_YEAR",
        concat('FY', lpad(mod(year(date), 100)::string, 2, '0')) as "FY",
        to_number(to_varchar(date, 'YYYYMMDD'))      as "DATENUMBER",
        weekofyear(date)                             as "WEEK_NUMBER",
        quarter(date)                                as "QUARTER_NUMBER",
        case when month(date) <= 6 then 1 else 2 end as "SEMESTER_NUMBER",
        dayname(date)                                as "DAY_NAME"
    from normalized
)
select * from calc