{{ config(materialized='table') }}

with src as (
  select investment, investment_type, symbol, exchange, currency, currency_quote
  from {{ ref('blended_dim_ticker') }}
)
select
  md5(coalesce(symbol,'')||'|'||coalesce(exchange,'')) as ticker_sk,

  cast(currency       as varchar) as currency,
  cast(currency_quote as varchar) as currency_quote,

  -- human-friendly currency names (extend as needed)
  case upper(currency)
    when 'USD' then 'US Dollar'
    when 'EUR' then 'Euro'
    when 'GBP' then 'British Pound'
    when 'JPY' then 'Japanese Yen'
    when 'BTC' then 'Bitcoin'
    when 'ETH' then 'Ether'
    else null
  end as currency_name,
  case upper(currency_quote)
    when 'USD' then 'US Dollar'
    when 'EUR' then 'Euro'
    when 'GBP' then 'British Pound'
    when 'JPY' then 'Japanese Yen'
    when 'BTC' then 'Bitcoin'
    when 'ETH' then 'Ether'
    else null
  end as currency_quote_name,

  cast(symbol as varchar) as symbol,
  cast(null as varchar)   as etf_symbol_desc,  -- placeholder for future enrichment
  cast(null as varchar)   as grics_clsfctn     -- placeholder for future enrichment
from src
