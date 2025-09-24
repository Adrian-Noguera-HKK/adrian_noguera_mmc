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
    from {{ ref('base_etfs') }} t
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
    from {{ ref('base_stocks') }} t
  ) s
  where rn = 1
),

crypto_t as (
  select distinct
    'Crypto'            as investment,
    meta_type           as investment_type,
    meta_symbol         as symbol,
    meta_exchange       as exchange,
    split_part(meta_symbol,'/',1) as currency,
    split_part(meta_symbol,'/',2) as currency_quote
  from {{ ref('base_crypto') }}
),
etf_t as (
  select distinct
    'ETF'               as investment,
    meta_type           as investment_type,
    meta_symbol         as symbol,
    meta_exchange       as exchange,
    meta_currency       as currency,
    null                as currency_quote
  from etfs_dedup
),
stock_t as (
  select distinct
    'Stock'             as investment,
    meta_type           as investment_type,
    meta_symbol         as symbol,
    meta_exchange       as exchange,
    meta_currency       as currency,
    null                as currency_quote
  from stocks_dedup
),
forex_t as (
  select distinct
    'Forex'             as investment,
    meta_type           as investment_type,
    meta_symbol         as symbol,
    null                as exchange,
    split_part(meta_symbol,'/',1) as currency,
    split_part(meta_symbol,'/',2) as currency_quote
  from {{ ref('base_forex') }}
),

unioned as (
  select * from crypto_t
  union distinct select * from etf_t
  union distinct select * from stock_t
  union distinct select * from forex_t
)

select investment, investment_type, symbol, exchange, currency, currency_quote
from unioned
