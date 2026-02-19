we needed more data so we created "gcs__bq_taxi_backfill.yml" for kestra

this is used to ingest all the relevant tripdata for the project
fhv 
yellow 
green tripdata is loaded in bucket and then merged into bq tables which we can load into dbt for transformation

Initially i found using the Parquets very problematic because of schema drift.

so instead we used the csv.


Given a dbt project with the following structure:

QUESTION 1
models/
├── staging/
│   ├── stg_green_tripdata.sql
│   └── stg_yellow_tripdata.sql
└── intermediate/
    └── int_trips_unioned.sql (depends on stg_green_tripdata & stg_yellow_tripdata)
If you run dbt run --select int_trips_unioned, what models will be built?

stg_green_tripdata, stg_yellow_tripdata, and int_trips_unioned (upstream dependencies)

Question 2. dbt Tests
You've configured a generic test like this in your schema.yml:

columns:
  - name: payment_type
    data_tests:
      - accepted_values:
          arguments:
            values: [1, 2, 3, 4, 5]
Your model fct_trips has been running successfully for months. A new value 6 now appears in the source data.

What happens when you run dbt test --select fct_trips?

dbt will fail the test, returning a non-zero exit code


Question 3. Counting Records in fct_monthly_zone_revenue
After running your dbt project, query the fct_monthly_zone_revenue model.
What is the count of records in the fct_monthly_zone_revenue model?

1,320,339

Question 4. Best Performing Zone for Green Taxis (2020)
Using the fct_monthly_zone_revenue table, find the pickup zone with the highest total revenue (revenue_monthly_total_amount) for Green taxi trips in 2020.

select  pickup_zone, total_revenue
from `terraform-demo-485008.dbt_ny_taxi.fct_monthly_zone_revenue`
where month between '2020-01-01' and '2020-12-31'
  and service_type = 'Green'
  order by total_revenue DESC

Which zone had the highest revenue?

East_Harlem_North



Question 5. Green Taxi Trip Counts (October 2019)
Using the fct_monthly_zone_revenue table, what is the total number of trips (total_monthly_trips) for Green taxis in October 2019?

select SUM(total_trips)
from `terraform-demo-485008.dbt_ny_taxi.fct_monthly_zone_revenue`
where month = '2019-10-01' 
  and service_type = 'Green'

  Output = 359,004

  Closest Answer = 350,891



Question 6. Build a Staging Model for FHV Data
Create a staging model for the For-Hire Vehicle (FHV) trip data for 2019.

Load the FHV trip data for 2019 into your data warehouse
Create a staging model stg_fhv_tripdata with these requirements:
Filter out records where dispatching_base_num IS NULL
Rename fields to match your project's naming conventions (e.g., PUlocationID → pickup_location_id)
What is the count of records in stg_fhv_tripdata?

my answer   
19312530 from dbt staged no duplicates and filtered by dates 
20101477 from kestra-bigquery merged data no(nulls) on dispatching_base_num

I couldnt find an answer close to the below ?

42,084,899
43,244,693
22,998,722
44,112,187



