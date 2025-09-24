{{ config(materialized='view') }}

select
  investment_sk as investment_sk,
  investment     as investment,
  investment_type as investment_type
from {{ ref('modeled_dim_investment') }}
