with trips_unioned as(
    select * 
    from `terraform-demo-485008`.`dbt_ny_taxi`.`int_trips_unioned`
),

dim_zones as(
    select * 
    from `terraform-demo-485008`.`dbt_ny_taxi`.`dim_zones`
    where borough != 'Unknown'
)

select 
    -- Trip details
    trips_unioned.trip_id,
    trips_unioned.vendor_id,
    trips_unioned.rate_code_id,
    trips_unioned.store_and_fwd_flag,
    trips_unioned.pickup_datetime,
    trips_unioned.dropoff_datetime,
    trips_unioned.passenger_count,
    trips_unioned.trip_distance,
    trips_unioned.trip_type,
    
    -- Fare details
    trips_unioned.fare_amount,
    trips_unioned.extra,
    trips_unioned.mta_tax,
    trips_unioned.tip_amount,
    trips_unioned.tolls_amount,
    trips_unioned.ehail_fee,
    trips_unioned.improvement_surcharge,
    trips_unioned.total_amount,
    trips_unioned.payment_type,
    trips_unioned.payment_type_description,
    trips_unioned.service_type,
    
    -- Pickup location (you had these but weren't selecting zone info)
    trips_unioned.pickup_location_id,
    pickup_zone.borough as pickup_borough,
    pickup_zone.zone as pickup_zone,
    pickup_zone.service_zone as pickup_service_zone,
    
    -- Dropoff location (you had these but weren't selecting zone info)
    trips_unioned.dropoff_location_id,
    droppoff_zone.borough as dropoff_borough,
    droppoff_zone.zone as dropoff_zone,
    droppoff_zone.service_zone as dropoff_service_zone

from trips_unioned
inner join dim_zones as pickup_zone
    on trips_unioned.pickup_location_id = pickup_zone.location_id
inner join dim_zones as droppoff_zone
    on trips_unioned.dropoff_location_id = droppoff_zone.location_id