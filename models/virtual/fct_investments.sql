{{ config(materialized='view') }}

select
  investment_sk,
  ticker_sk,
  marketplace_sk,
  date_sk,
  investment,
  investment_type,
  exchange,
  currency,
  symbol,
  date,
  opening_price,
  closing_price,
  highest_price,
  lowest_price,
  volume
from {{ ref('modeled_fct_investments') }}
