{{ config(materialized='view') }}

select *
from {{ ref('modeled_vw_fct_investments') }}
