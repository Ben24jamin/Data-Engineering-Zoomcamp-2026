with fhv_trips as(
    select
            -- identifiers
        dispatching_base_num,
        pickup_location_id,
        dropoff_location_id,
        affaliated_base_number,

        -- timestamps
        pickup_datetime,  
        dropoff_datetime,

        -- trip info
        sr_flag,
        'FHV' as service_type
    from {{ ref('stg_fhv_tripdata') }}
),

cleaned_and_enriched as(
select
-- Generate unique trip identifier (surrogate key pattern)
    {{ dbt_utils.generate_surrogate_key([
        'dispatching_base_num',
        'pickup_datetime',
        'pickup_location_id',
    ]) }} as trip_id,
    *
from fhv_trips)

-- Deduplicate: if multiple trips match (dispatching_base_num, second, location, service), keep first
select * from cleaned_and_enriched
qualify row_number() over(
    partition by dispatching_base_num, pickup_datetime, pickup_location_id, service_type
    order by dropoff_datetime
) = 1