
MODULE 3 HOMEWORK
#
in order to encode your GCP creds download the json and name it service-account.json then run the below

echo SECRET_GCP_SERVICE_ACCOUNT=$(cat service-account.json | base64 -w 0) >> .env_encoded

now you have to add this "env_file: .env_encoded" to the docker-compose file between "user:.." and "command:..."

restart docker

execute the "create_kv.yaml" in kestra

you will now see your key values in KV Store

you can now execute "initialise_gcp_bq.yaml" to actually start up the bucket and bigquery table

only load the parquet files of yellow-taxitripdata to your bucket using  kestra, i ran "gcs_taxi.yaml" which is just a modified version of postgres_taxi

to create an external table (just a view of the parquet files from the gcs bucket) run the bellow

CREATE OR REPLACE EXTERNAL TABLE `terraform-demo-485008.20260129_ny_taxi_gcp_dataset.yellow_tripdata_external`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://20260129-ny-taxi-gcp-bucket/*.parquet']
);

now to have this table in BigQuery Itself run the below

CREATE OR REPLACE TABLE `terraform-demo-485008.20260129_ny_taxi_gcp_dataset.yellow_tripdata`
AS
SELECT * FROM `terraform-demo-485008.20260129_ny_taxi_gcp_dataset.yellow_tripdata_external`;


Question 1:
What is count of records for the 2024 Yellow Taxi Data?

SELECT COUNT(*) FROM `20260129_ny_taxi_gcp_dataset.yellow_tripdata`;

20332093

Question 2:
Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?

SELECT COUNT(DISTINCT PULocationID) FROM `20260129_ny_taxi_gcp_dataset.yellow_tripdata`; = 155.12 mB
SELECT COUNT(DISTINCT PULocationID) FROM `20260129_ny_taxi_gcp_dataset.yellow_tripdata_external`; = 0mB

0 MB for the External Table and 155.12 MB for the Materialized Table

Question 3:
Write a query to retrieve the PULocationID from the table (not the external table) in BigQuery. Now write a query to retrieve the PULocationID and DOLocationID on the same table. Why are the estimated number of Bytes different?

BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.

Question 4:
How many records have a fare_amount of 0?

SELECT COUNT(fare_amount) FROM `20260129_ny_taxi_gcp_dataset.yellow_tripdata` WHERE  fare_amount = 0 ;

8333

Question 5:
What is the best strategy to make an optimized table in Big Query if your query will always filter based on tpep_dropoff_datetime and order the results by VendorID (Create a new table with this strategy)

CREATE TABLE `20260129_ny_taxi_gcp_dataset.yellow_tripdata_optimized`
PARTITION BY DATE_TRUNC(tpep_dropoff_datetime, MONTH) #Check that it does this well 
CLUSTER BY VendorID 
AS SELECT * FROM `20260129_ny_taxi_gcp_dataset.yellow_tripdata`;

Partition by tpep_dropoff_datetime cluster by VendorID
took 2.27GB

Question 6:
Write a query to retrieve the distinct VendorIDs between tpep_dropoff_datetime 2024-03-01 and 2024-03-15 (inclusive)

Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. What are these values?

SELECT DISTINCT(VendorID)
FROM `20260129_ny_taxi_gcp_dataset.yellow_tripdata`
WHERE tpep_dropoff_datetime BETWEEN "2024-03-01" AND "2024-03-15"  310.24 MB when run.

SELECT DISTINCT(VendorID)
FROM `20260129_ny_taxi_gcp_dataset.yellow_tripdata_optimized`
WHERE tpep_dropoff_datetime BETWEEN "2024-03-01" AND "2024-03-15" 54.68 MB when run.

310.24 MB for non-partitioned table and 26.84 MB for the partitioned table

Question 7:
Where is the data stored in the External Table you created?

GCP Bucket

Question 8:
It is best practice in Big Query to always cluster your data:

FALSE

Question 9:
No Points: Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read? Why?

0MB Caching