{{ config(materialized='table') }}

with base as (
  select
    investment,
    investment_type,
    symbol,
    exchange,
    dt,
    opening_price,
    closing_price,
    highest_price,
    lowest_price,
    volume
  from {{ ref('blended_fct_investments') }}
),
keys as (
  select
    md5(investment||'|'||coalesce(investment_type,''))  as investment_sk,
    md5(coalesce(symbol,'')||'|'||coalesce(exchange,'')) as ticker_sk,
    md5(coalesce(exchange,''))                           as marketplace_sk,
    to_char(cast(dt as date),'YYYYMMDD')                 as date_sk,
    *
  from base
),
enriched as (
  select
    k.investment_sk,
    k.ticker_sk,
    k.marketplace_sk,
    k.date_sk,

    -- attributes per GOLD.FCT_INVESTMENTS
    cast(k.investment       as varchar)      as investment,
    cast(k.investment_type  as varchar)      as investment_type,
    cast(k.exchange         as varchar)      as exchange,
    cast(t.currency         as varchar)      as currency,
    cast(k.symbol           as varchar)      as symbol,
    cast(cast(k.dt as date) as date)         as date,

    cast(k.opening_price as number(38,5))    as opening_price,
    cast(k.closing_price as number(38,5))    as closing_price,
    cast(k.highest_price as number(38,5))    as highest_price,
    cast(k.lowest_price  as number(38,5))    as lowest_price,
    cast(k.volume as varchar)                as volume  -- GOLD stores volume as VARCHAR
  from keys k
  left join {{ ref('modeled_dim_ticker') }} t
    on t.ticker_sk = k.ticker_sk
)
select * from enriched
