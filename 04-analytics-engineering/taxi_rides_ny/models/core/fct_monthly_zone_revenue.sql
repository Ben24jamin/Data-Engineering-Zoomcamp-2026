-- models/core/fct_monthly_zone_revenue.sql
{{
    config(
        materialized='table',
        partition_by={
            "field": "month",
            "data_type": "date",
            "granularity": "month"
        },
        cluster_by=["service_type", "pickup_service_zone", "pickup_borough"]
    )
}}

select
    -- Simple month date (YYYY-MM-01)
    date_trunc(pickup_datetime, month) as month,
    
    -- Service type (Green vs Yellow)
    service_type,
    
    -- Pickup zone details
    pickup_location_id,
    pickup_borough,
    pickup_zone,
    pickup_service_zone,
    
    -- Dropoff zone details
    dropoff_location_id,
    dropoff_borough,
    dropoff_zone,
    dropoff_service_zone,
    
    -- Key metrics
    count(trip_id) as total_trips,
    sum(total_amount) as total_revenue,
    avg(total_amount) as avg_revenue_per_trip
    
from {{ ref('dim_taxi_trips') }}
group by 
    date_trunc(pickup_datetime, month),
    service_type,
    pickup_location_id,
    pickup_borough,
    pickup_zone,
    pickup_service_zone,
    dropoff_location_id,
    dropoff_borough,
    dropoff_zone,
    dropoff_service_zone

