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

crypto_f as (
  select
    'Crypto'         as investment,
    meta_type        as investment_type,
    meta_symbol      as symbol,
    meta_exchange    as exchange,
    values_datetime  as dt,
    values_open      as opening_price,
    values_close     as closing_price,
    values_high      as highest_price,
    values_low       as lowest_price,
    null             as volume
  from {{ ref('base_crypto') }}
),
etf_f as (
  select
    'ETF'            as investment,
    meta_type        as investment_type,
    meta_symbol      as symbol,
    meta_exchange    as exchange,
    values_datetime  as dt,
    values_open      as opening_price,
    values_close     as closing_price,
    values_high      as highest_price,
    values_low       as lowest_price,
    values_volume    as volume
  from etfs_dedup
),
forex_f as (
  select
    'Forex'          as investment,
    meta_type        as investment_type,
    meta_symbol      as symbol,
    null             as exchange,
    values_datetime  as dt,
    values_open      as opening_price,
    values_close     as closing_price,
    values_high      as highest_price,
    values_low       as lowest_price,
    null             as volume
  from {{ ref('base_forex') }}
),
stock_f as (
  select
    'Stock'          as investment,
    meta_type        as investment_type,
    meta_symbol      as symbol,
    meta_exchange    as exchange,
    values_datetime  as dt,
    values_open      as opening_price,
    values_close     as closing_price,
    values_high      as highest_price,
    values_low       as lowest_price,
    values_volume    as volume
  from stocks_dedup
)

select * from crypto_f
union all select * from etf_f
union all select * from forex_f
union all select * from stock_f
