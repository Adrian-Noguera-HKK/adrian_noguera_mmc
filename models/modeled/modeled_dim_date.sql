{{ config(materialized='table') }}

with src as (
  select *
  from {{ ref('blended_dim_date') }}
)
select
  -- GOLD expects a string YYYYMMDD; keep as VARCHAR for parity
  to_char(date,'YYYYMMDD')                                                as date_sk,

  cast(date as date)                                                      as date,
  cast(year as number)                                                    as year,
  cast(short_year as number)                                              as short_year,
  cast(monthnumber as number)                                             as monthnumber,
  cast(day as number)                                                     as day,
  cast(month as varchar)                                                  as month,
  cast(week_day as number)                                                as week_day,

  -- GOLD.DIM_DT has YEAR_MONTH as NUMBER; convert from YYYY-MM to YYYYMM
  cast(to_number(replace(to_char(date,'YYYY-MM'),'-','')) as number)      as year_month,

  cast(to_char(date,'Q') as varchar)                                      as quarter,
  cast('Q'||to_char(date,'Q') as varchar)                                 as quarter_year,
  dateadd(day,6,date_trunc('week',date))                                  as end_week,
  to_char(date,'YYYY')                                                    as fy,

  cast(datenumber as number)                                              as datenumber,
  cast(week_number as number)                                             as week_number,
  cast(quarter_number as number)                                          as quarter_number,
  cast(semester_number as number)                                         as semester_number,
  cast(day_name as varchar)                                               as day_name
from src
