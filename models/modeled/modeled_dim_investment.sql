{{ config(materialized='table') }}

with src as (
  select investment, investment_type
  from {{ ref('blended_dim_investment') }}
)
select
  md5(investment||'|'||coalesce(investment_type,'')) as investment_sk,
  cast(investment as varchar)                         as investment,
  cast(investment_type as varchar)                    as investment_type
from src
