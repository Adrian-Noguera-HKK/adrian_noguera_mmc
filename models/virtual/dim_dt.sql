{{ config(materialized='view') }}

select
  date_sk,
  date,
  year,
  short_year,
  monthnumber,
  day,
  month,
  week_day,
  year_month,
  quarter,
  quarter_year,
  end_week,
  fy,
  datenumber,
  week_number,
  quarter_number,
  semester_number,
  day_name
from {{ ref('modeled_dim_date') }}
