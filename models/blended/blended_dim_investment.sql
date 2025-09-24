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
crypto_inv as (
  select distinct 'Crypto' as investment, meta_type as investment_type
  from {{ ref('base_crypto') }}
),
forex_inv as (
  select distinct 'Forex' as investment, meta_type as investment_type
  from {{ ref('base_forex') }}
),
etf_inv as (
  select distinct 'ETF' as investment, meta_type as investment_type
  from etfs_dedup
),
stock_inv as (
  select distinct 'Stock' as investment, meta_type as investment_type
  from stocks_dedup
)

select * from crypto_inv
union distinct select * from forex_inv
union distinct select * from etf_inv
union distinct select * from stock_inv
