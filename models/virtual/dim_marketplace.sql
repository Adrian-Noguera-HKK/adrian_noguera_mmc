{{ config(materialized='view') }}

select
  marketplace_sk as marketplace_sk,
  exchange       as exchange,
  exchange_tz    as exchange_tz
from {{ ref('modeled_dim_marketplace') }}
