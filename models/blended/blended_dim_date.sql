{{ config(materialized='view') }}

with recursive
all_bounds as (
  select date(min(values_datetime)) as dmin, date(max(values_datetime)) as dmax from {{ ref('base_crypto') }}
  union all select date(min(values_datetime)), date(max(values_datetime)) from {{ ref('base_etfs') }}
  union all select date(min(values_datetime)), date(max(values_datetime)) from {{ ref('base_forex') }}
  union all select date(min(values_datetime)), date(max(values_datetime)) from {{ ref('base_stocks') }}
),
bounds as (
  select min(dmin) as dmin, max(dmax) as dmax from all_bounds
),
dates as (
  -- seed
  select dmin as date
  from bounds
  union all
  -- recurse forward one day at a time until dmax
  select dateadd(day, 1, d.date)
  from dates d
  join bounds b on d.date < b.dmax
)

select
  date,
  year(date)                        as year,
  substr(to_char(date,'YYYY'),3,2)  as short_year,
  month(date)                       as monthnumber,
  day(date)                         as day,
  monthname(date)                   as month,
  dayofweekiso(date)                as week_day,
  to_char(date,'YYYY-MM')           as year_month,          -- cast in modeled if needed
  quarter(date)                     as quarter,
  'Q'||to_char(date,'Q')            as quarter_year,
  dateadd(day,6,date_trunc('week',date)) as end_week,
  to_char(date,'YYYY')              as fy,
  to_number(to_char(date,'YYYYMMDD')) as datenumber,
  weekofyear(date)                  as week_number,
  quarter(date)                     as quarter_number,
  case when month(date) <= 6 then 1 else 2 end as semester_number,
  dayname(date)                     as day_name
from dates
