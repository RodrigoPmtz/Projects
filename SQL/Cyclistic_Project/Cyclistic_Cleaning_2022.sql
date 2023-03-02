--First, we will create a new table with all the columns we have in our raw data and its data type

USE
Cyclistic
GO
CREATE TABLE Trips_2022
(
ride_id nvarchar(50),
rideable_type nvarchar(50),
started_at datetime2,
ended_at datetime2,
start_station_name nvarchar(100),
start_station_id nvarchar(50),
end_station_name nvarchar(100),
end_station_id nvarchar(50),
start_lat float,
start_lng float,
end_lat float,
end_lng float,
member_casual nvarchar(50)
)

-- Then we will union the 12 monthly data into the already created table consisting of all the bike trips of 2022

INSERT INTO Trips_2022
SELECT *
FROM Cyclistic..[tripdata-01]
UNION
SELECT *
FROM Cyclistic..[tripdata-02]
UNION
SELECT *
FROM Cyclistic..[tripdata-03]
UNION
SELECT *
FROM Cyclistic..[tripdata-04]
UNION
SELECT *
FROM Cyclistic..[tripdata-05]
UNION
SELECT *
FROM Cyclistic..[tripdata-06]
UNION
SELECT *
FROM Cyclistic..[tripdata-07]
UNION
SELECT *
FROM Cyclistic..[tripdata-08]
UNION
SELECT *
FROM Cyclistic..[tripdata-09]
UNION
SELECT *
FROM Cyclistic..[tripdata-10]
UNION
SELECT *
FROM Cyclistic..[tripdata-11]
UNION
SELECT *
FROM Cyclistic..[tripdata-12]

--Check if the UNION worked

SELECT *
FROM Cyclistic..Trips_2022 

-- We have 5,667,717 rows

-- Cleaning --

/* ride_id
Check length combinations
Check all values are unique as ride_id is our primary key
We are not cleaning this column due all the values are unique
*/
SELECT LEN(ride_id), COUNT(ride_id)
FROM Cyclistic..Trips_2022
GROUP BY LEN(ride_id)

SELECT COUNT(DISTINCT(ride_id))
FROM Cyclistic..Trips_2022

/* rideable_type
Check the types (electric, classic, docked)
Count the number of trips for each type of bike
*/

SELECT DISTINCT(rideable_type)
FROM Cyclistic..Trips_2022

SELECT rideable_type, COUNT(rideable_type) as trips_for_each_type
FROM Cyclistic..Trips_2022
GROUP BY rideable_type

/* started_at & ended_at
We just want trips longer than 1 minute and shorter than one day
We delete the ones that not meet this condition (deleted trips: 170,620) we now should have 5,497,097 rows
We create a new column with the trip duration, this will help us later with our analysis
*/

SELECT *
FROM Cyclistic..Trips_2022
WHERE DATEDIFF(MINUTE, started_at, ended_at) <= 1 OR DATEDIFF(MINUTE, started_at, ended_at) >= 1440

DELETE FROM Cyclistic..Trips_2022
WHERE DATEDIFF(MINUTE, started_at, ended_at) <= 1 OR DATEDIFF(MINUTE, started_at, ended_at) >= 1440

ALTER TABLE Trips_2022
ADD trip_duration float;

UPDATE Trips_2022
SET trip_duration = DATEDIFF(MINUTE, started_at, ended_at)

/* station_name's
Check for naming inconsistencies
Remove leading and trailing spaces
*/

SELECT start_station_name, count(*)
FROM Cyclistic..Trips_2022
GROUP BY start_station_name
ORDER BY start_station_name

SELECT end_station_name, count(*)
FROM Cyclistic..Trips_2022
GROUP BY end_station_name
ORDER BY end_station_name

UPDATE Trips_2022
SET start_station_name = LTRIM(RTRIM(start_station_name))

/* trips per rideable_type
Check nulls per rideable type
Electric trips do not have to start or end at a station (inferred due the large amount of trips for this kind of trip)
Classic/docked will always start and end their trip in a station
We remove classic/docked trips without start/end station name
Change the null station names to 'Electric Lock' for electric bike trips
*/

SELECT rideable_type, COUNT(*) as trip_each_type
FROM Cyclistic..Trips_2022
WHERE start_station_name IS NULL AND start_station_id IS NULL OR end_station_name IS NULL AND end_station_id is NULL
GROUP BY rideable_type

DELETE FROM Cyclistic..Trips_2022
WHERE (start_station_name is NULL and start_station_id is null and rideable_type = 'classic_bike') 
OR (end_station_name is null and end_station_id is null and rideable_type = 'classic_bike')

DELETE FROM Cyclistic..Trips_2022
WHERE (start_station_name is NULL and start_station_id is null and rideable_type = 'docked_bike') 
OR (end_station_name is null and end_station_id is null and rideable_type = 'docked_bike')

UPDATE Trips_2022
SET start_station_name = 'Electric Lock'
WHERE start_station_name IS NULL AND start_station_id IS NULL OR end_station_name IS NULL AND end_station_id is NULL

UPDATE Trips_2022
SET end_station_name = 'Electric Lock'
WHERE start_station_name IS NULL AND start_station_id IS NULL OR end_station_name IS NULL AND end_station_id is NULL

/* station_id's
Check length combinations, as they do not offer any use to our analysis, we ignore them
*/

SELECT LEN(start_station_id), COUNT(start_station_id)
FROM Cyclistic..Trips_2022
GROUP BY LEN(start_station_id)

SELECT LEN(end_station_id), COUNT(end_station_id)
FROM Cyclistic..Trips_2022
GROUP BY LEN(end_station_id)

/* Check NULLs for latitude and longitude
We remove these NULLs
*/

SELECT *
FROM Cyclistic..Trips_2022
WHERE start_lat is null or start_lng is null or end_lat is null or end_lng is null

DELETE FROM Trips_2022
WHERE start_lat is null or start_lng is null or end_lat is null or end_lng is null

/* member_casual
Check for distinct values, we should only have 2
We have member and casual (as we wanted to)
*/

SELECT DISTINCT(member_casual)
FROM Cyclistic..Trips_2022

-- We finished the cleaning phase
