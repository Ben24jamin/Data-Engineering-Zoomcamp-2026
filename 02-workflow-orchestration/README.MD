QUESTION 1
128.3MiB

QUESTION 2
green_tripdata_2020-04.csv

QUESTION 3
SELECT COUNT(DISTINCT unique_row_id) 
FROM yellow_tripdata 
WHERE tpep_pickup_datetime >= '2020-01-01 00:00:00' 
  AND tpep_pickup_datetime < '2021-01-01 00:00:00';

24,635,261 answer
24,648,499 closest

QUESTION 4
SELECT COUNT(DISTINCT unique_row_id) 
FROM green_tripdata 
WHERE lpep_pickup_datetime >= '2020-01-01 00:00:00' 
  AND lpep_pickup_datetime < '2021-01-01 00:00:00';

1783353 answer
1,734,051 closest

QUESTION 5 
SELECT COUNT(DISTINCT unique_row_id) 
FROM yellow_tripdata 
WHERE tpep_pickup_datetime >= '2021-03-01 00:00:00' 
  AND tpep_pickup_datetime < '2021-03-31 00:00:00';

answer 1,857,856
closest 1,925,152

QUESTION 6
Add a timezone property set to America/New_York in the Schedule trigger configuration