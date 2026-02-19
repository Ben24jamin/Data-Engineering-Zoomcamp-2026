<<<<<<< HEAD
-- Dimension table for taxi technology vendors
-- Small static dimension defining vendor codes and their company names
--Uses the getVendordata macro

with trips as (
    select * from {{ ref('fct_taxi_trips') }}
),

vendors as (
    select distinct
        vendor_id,
        {{ get_vendor_data('vendor_id') }} as vendor_name
    from trips
)

=======
-- Dimension table for taxi technology vendors
-- Small static dimension defining vendor codes and their company names
--Uses the getVendordata macro

with trips as (
    select * from {{ ref('fct_taxi_trips') }}
),

vendors as (
    select distinct
        vendor_id,
        {{ get_vendor_data('vendor_id') }} as vendor_name
    from trips
)

>>>>>>> db4a91f1addeb41ed4f65f6eb013909de54e7bbe
select * from vendors