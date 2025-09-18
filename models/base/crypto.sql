{{ config(materialized='table') }}

select *
from {{ source('raw','STG_CRYPTO') }}
