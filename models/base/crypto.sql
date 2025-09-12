{{ config(materialized='table') }}

select *
from {{ source('mmc', 'CRYPTO') }}
