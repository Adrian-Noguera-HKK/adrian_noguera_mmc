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

crypto_f as (
  select
    'Crypto'                               as investment,
    meta_type                              as investment_type,
    meta_symbol                            as symbol,
    meta_exchange                          as exchange,
    cast(values_datetime as timestamp_ntz) as dt,
    cast(values_open   as number(38,9))    as opening_price,
    cast(values_close  as number(38,9))    as closing_price,
    cast(values_high   as number(38,9))    as highest_price,
    cast(values_low    as number(38,9))    as lowest_price,
    null::number                           as volume
  from {{ ref('crypto') }}
),
etf_f as (
  select
    'ETF'                                  as investment,
    meta_type                              as investment_type,
    meta_symbol                            as symbol,
    meta_exchange                          as exchange,
    cast(values_datetime as timestamp_ntz) as dt,
    cast(values_open   as number(38,9))    as opening_price,
    cast(values_close  as number(38,9))    as closing_price,
    cast(values_high   as number(38,9))    as highest_price,
    cast(values_low    as number(38,9))    as lowest_price,
    cast(values_volume as number(38,0))    as volume
  from etfs_dedup
),
forex_f as (
  select
    'Forex'                                as investment,
    meta_type                              as investment_type,
    meta_symbol                            as symbol,
    null                                   as exchange,       -- forex has no exchange
    cast(values_datetime as timestamp_ntz) as dt,
    cast(values_open   as number(38,9))    as opening_price,
    cast(values_close  as number(38,9))    as closing_price,
    cast(values_high   as number(38,9))    as highest_price,
    cast(values_low    as number(38,9))    as lowest_price,
    null::number                           as volume
  from {{ ref('forex') }}
),
stock_f as (
  select
    'Stock'                                as investment,
    meta_type                              as investment_type,
    meta_symbol                            as symbol,
    meta_exchange                          as exchange,
    cast(values_datetime as timestamp_ntz) as dt,
    cast(values_open   as number(38,9))    as opening_price,
    cast(values_close  as number(38,9))    as closing_price,
    cast(values_high   as number(38,9))    as highest_price,
    cast(values_low    as number(38,9))    as lowest_price,
    cast(values_volume as number(38,0))    as volume
  from stocks_dedup
)

select * from crypto_f
union all
select * from etf_f
union all
select * from forex_f
union all
select * from stock_f
