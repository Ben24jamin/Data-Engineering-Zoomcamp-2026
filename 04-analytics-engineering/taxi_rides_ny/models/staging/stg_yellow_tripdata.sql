

with tripdata as (
    select *,
    row_number() over(partition by vendorid, tpep_pickup_datetime) as rn
    from {{ source('staging', 'yellow_tripdata') }}
    where vendorid is not null
),

renamed as (
    select
        -- identifiers (standardized naming for consistency across yellow/green)
        cast(vendorid as integer) as vendor_id,
        cast(ratecodeid as integer) as rate_code_id,
        cast(pulocationid as integer) as pickup_location_id,
        cast(dolocationid as integer) as dropoff_location_id,

        -- timestamps (standardized naming)
        cast(tpep_pickup_datetime as timestamp) as pickup_datetime,  -- tpep = Taxicab Passenger Enhancement Program (yellow taxis)
        cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,

        -- trip info
        store_and_fwd_flag,
        cast(passenger_count as integer) as passenger_count,
        cast(trip_distance as numeric) as trip_distance,
        cast(1 as integer) as trip_type,   --green cabs allow hailing=1 and e-hailing=2 so we cast an extra column for yellow to be unioned in future 

        -- payment info
        cast(fare_amount as numeric) as fare_amount,
        cast(extra as numeric) as extra,
        cast(mta_tax as numeric) as mta_tax,
        cast(tip_amount as numeric) as tip_amount,
        cast(tolls_amount as numeric) as tolls_amount,
        cast(0 as numeric) as ehail_fee, --here we also cast a column and give it a 0 value to match green taxis (yellow doesnt actually have e-hailing)
        cast(improvement_surcharge as numeric) as improvement_surcharge,
        cast(total_amount as numeric) as total_amount,
        cast(payment_type as integer) as payment_type,
        {{ get_payment_type_description('payment_type') }} as payment_type_description
    from tripdata
    where rn = 1
           )

select * from renamed

-- dbt build --select <model_name> --vars '{"is_test_run": true}'
{% if var('is_test_run', default =false) %}

    limit 100

{% endif %}

