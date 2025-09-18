{{ config(materialized='view') }}

with
etfs_dedup as (
  select *
  from (
    select t.*,
           row_number() over (
             partition by meta_symbol, meta_type, values_datetime
             order by values_datetime desc
           ) rn
    from {{ ref('etfs') }} t
  ) s
  where rn = 1
),
stocks_dedup as (
  select *
  from (
    select t.*,
           row_number() over (
             partition by meta_symbol, meta_type, values_datetime
             order by values_datetime desc
           ) rn
    from {{ ref('stocks') }} t
  ) s
  where rn = 1
),

crypto_t as (
  select distinct
    'Crypto'            as investment,
    meta_type           as investment_type,
    meta_symbol         as symbol,
    meta_exchange       as exchange,
    meta_currency_base  as currency,
    meta_currency_quote as currency_quote
  from {{ ref('crypto') }}
),
etf_t as (
  select distinct
    'ETF'               as investment,
    meta_type           as investment_type,
    meta_symbol         as symbol,
    meta_exchange       as exchange,
    null                as currency,
    null                as currency_quote
  from etfs_dedup
),
forex_t as (
  select distinct
    'Forex'             as investment,
    meta_type           as investment_type,
    meta_symbol         as symbol,
    null                as exchange,         -- forex has no exchange
    meta_currency_base  as currency,
    meta_currency_quote as currency_quote
  from {{ ref('forex') }}
),
stock_t as (
  select distinct
    'Stock'             as investment,
    meta_type           as investment_type,
    meta_symbol         as symbol,
    meta_exchange       as exchange,
    null                as currency,
    null                as currency_quote
  from stocks_dedup
),

unioned as (
  select * from crypto_t
  union distinct select * from etf_t
  union distinct select * from forex_t
  union distinct select * from stock_t
)

select investment, investment_type, symbol, exchange, currency, currency_quote
from unioned
