# Data-Engineering-Zoomcamp-2026 Commands to spin up pgadmin 
Data Engineering Zoomcamp 2026
# 1. Build all services
docker-compose build

# 2. Start db and pgadmin in background
docker-compose up -d postgres pgadmin

# 3. Wait for database to be ready (or check health status)
docker-compose logs postgres pgadmin

# 4. Run ingest service once (with --rm to remove after)
docker-compose run --rm ingest

# 5. Login in to pgadmin and add server which you have provisioned

Question 3
-- SELECT COUNT(*)
-- FROM green_taxi_data
-- WHERE trip_distance <= 1.00  AND trip_distance IS NOT NULL 

Question 4
-- SELECT lpep_pickup_datetime
-- FROM green_taxi_data
-- WHERE trip_distance < 100
-- ORDER BY trip_distance DESC
-- LIMIT (1)

Question 5
WITH loczone AS(SELECT 
--     "PULocationID",
--     SUM(trip_distance) as total_distance
-- FROM green_taxi_data
-- WHERE DATE(lpep_pickup_datetime) = '2025-11-18'::date
-- GROUP BY "PULocationID"
-- ORDER BY total_distance DESC
-- LIMIT 1)
-- SELECT "Zone"
-- FROM loczone
-- JOIN taxi_lookup_zones ON "PULocationID" = "LocationID"

Question 6
-- With pickuptoptip AS(
-- SELECT "DOLocationID", "PULocationID" , MAX(tip_amount) as top_tip
-- FROM green_taxi_data
-- WHERE "PULocationID" = 74
-- GROUP BY "DOLocationID", "PULocationID"
-- ORDER BY top_tip DESC
-- LIMIT (1))
-- SELECT "Zone"
-- FROM pickuptoptip
-- JOIN taxi_lookup_zones ON "LocationID" = "DOLocationID"