{{ config(materialized='view') }}

select
  ticker_sk            as ticker_sk,
  currency             as currency,
  currency_quote       as currency_quote,
  currency_name        as currency_name,
  currency_quote_name  as currency_quote_name,
  symbol               as symbol,
  etf_symbol_desc      as etf_symbol_desc,
  grics_clsfctn        as grics_clsfctn
from {{ ref('modeled_dim_ticker') }}
