{{ config(materialized='table') }}

select
  md5(coalesce(exchange,'')) as marketplace_sk,
  cast(exchange as varchar)  as exchange,
  cast(exchange_tz as varchar) as exchange_tz
from {{ ref('blended_dim_marketplace') }}
