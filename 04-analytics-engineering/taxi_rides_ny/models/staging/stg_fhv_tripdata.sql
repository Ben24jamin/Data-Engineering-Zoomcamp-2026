<<<<<<< HEAD
with source as (
    select *
    from {{ source('raw', 'fhv_tripdata') }}
),

renamed as (
    select
        -- identifiers
        cast(dispatching_base_num as string) as dispatching_base_num,
        cast(PULocationID as integer) as pickup_location_id,
        cast(DOLocationID as integer) as dropoff_location_id,
        cast(Affiliated_base_number as string) as affaliated_base_number,

        -- timestamps
        cast(pickup_datetime as timestamp) as pickup_datetime,  
        cast(dropoff_datetime as timestamp) as dropoff_datetime,

        -- trip info
        sr_flag
    from source
        -- Filter out records with null dispatching_base_num (data quality requirement)
    where dispatching_base_num IS NOT NULL
    
           )

select * from renamed
=======
with source as (
    select *
    from {{ source('raw', 'fhv_tripdata') }}
),

renamed as (
    select
        -- identifiers
        cast(dispatching_base_num as string) as dispatching_base_num,
        cast(PULocationID as integer) as pickup_location_id,
        cast(DOLocationID as integer) as dropoff_location_id,
        cast(Affiliated_base_number as string) as affaliated_base_number,

        -- timestamps
        cast(pickup_datetime as timestamp) as pickup_datetime,  
        cast(dropoff_datetime as timestamp) as dropoff_datetime,

        -- trip info
        sr_flag
    from source
        -- Filter out records with null dispatching_base_num (data quality requirement)
    where dispatching_base_num IS NOT NULL
    
           )

select * from renamed
>>>>>>> db4a91f1addeb41ed4f65f6eb013909de54e7bbe
where pickup_datetime >= '2019-01-01' and pickup_datetime <= '2019-12-31'