{{ config(materialized='view') }}

select *
from {{ ref('modeled_fct_investments') }}
