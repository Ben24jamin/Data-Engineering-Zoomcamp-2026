<<<<<<< HEAD
-- Union green and yellow taxi data into a single dataset
-- Demonstrates how to combine data from multiple sources with slightly different schemas

with green_trips as (
    select
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        trip_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        ehail_fee,
        improvement_surcharge,
        total_amount,
        payment_type,
        'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
),

yellow_trips as (
    select
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        cast(1 as integer) as trip_type,  -- Yellow taxis only do street-hail (code 1)
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        cast(0 as numeric) as ehail_fee,  -- Yellow taxis don't have ehail_fee
        improvement_surcharge,
        total_amount,
        payment_type,
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
),

trips_unioned as (
    select * from green_trips
    union all
    select * from yellow_trips
)

select
    {{ dbt_utils.generate_surrogate_key([
        'vendor_id',
        'pickup_datetime',
        'pickup_location_id',
    ]) }} as trip_id,
    *
=======
-- Union green and yellow taxi data into a single dataset
-- Demonstrates how to combine data from multiple sources with slightly different schemas

with green_trips as (
    select
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        trip_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        ehail_fee,
        improvement_surcharge,
        total_amount,
        payment_type,
        'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
),

yellow_trips as (
    select
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        cast(1 as integer) as trip_type,  -- Yellow taxis only do street-hail (code 1)
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        cast(0 as numeric) as ehail_fee,  -- Yellow taxis don't have ehail_fee
        improvement_surcharge,
        total_amount,
        payment_type,
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
),

trips_unioned as (
    select * from green_trips
    union all
    select * from yellow_trips
)

select
    {{ dbt_utils.generate_surrogate_key([
        'vendor_id',
        'pickup_datetime',
        'pickup_location_id',
    ]) }} as trip_id,
    *
>>>>>>> db4a91f1addeb41ed4f65f6eb013909de54e7bbe
from trips_unioned