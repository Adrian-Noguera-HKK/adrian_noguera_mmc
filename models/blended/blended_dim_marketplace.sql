{{ config(materialized='view') }}

with exchanges as (
  select distinct meta_exchange as exchange from {{ ref('crypto') }}
  union distinct
  select distinct meta_exchange from {{ ref('etfs') }}
  union distinct
  select distinct meta_exchange from {{ ref('stocks') }}
)

select
  exchange,
  null::string as exchange_tz
from exchanges
