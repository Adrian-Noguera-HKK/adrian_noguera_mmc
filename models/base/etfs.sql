with 

source as (

    select * from {{ source('mmc', 'STG_ETFS') }}

),

renamed as (

    select
        meta_currency,
        meta_exchange,
        meta_exchange_timezone,
        meta_interval,
        meta_mic_code,
        meta_symbol,
        meta_type,
        status,
        values_datetime,
        values_open,
        values_close,
        values_high,
        values_low,
        values_volume

    from source

)

select * from renamed