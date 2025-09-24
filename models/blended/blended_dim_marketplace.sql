{{ config(materialized='view') }}

with crypto_ex as (
  select distinct meta_exchange as exchange, cast(null as varchar) as exchange_tz
  from {{ ref('base_crypto') }}
),
etfs_ex as (
  select distinct meta_exchange as exchange, meta_exchange_timezone as exchange_tz
  from {{ ref('base_etfs') }}
),
stocks_ex as (
  select distinct meta_exchange as exchange, meta_exchange_timezone as exchange_tz
  from {{ ref('base_stocks') }}
),
unioned as (
  select * from crypto_ex
  union all
  select * from etfs_ex
  union all
  select * from stocks_ex
)
select
  exchange,
  max(exchange_tz) as exchange_tz
from unioned
group by exchange
