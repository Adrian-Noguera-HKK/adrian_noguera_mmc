with 

source as (

    select * from {{ source('mmc', 'STG_FOREX') }}

),

renamed as (

    select
        meta_currency_base,
        meta_currency_quote,
        meta_interval,
        meta_symbol,
        meta_type,
        status,
        values_close,
        values_datetime,
        values_high,
        values_low,
        values_open

    from source

)

select * from renamed