SELECT *
FROM Cyclistic..Trips_2022

/*
We're gonna add columns for the day of the week and months for each trip

*/
SELECT started_at,
CASE
WHEN DATEPART(WEEKDAY, started_at) = 1 THEN 'Sun'
    WHEN DATEPART(WEEKDAY, started_at) = 2 THEN 'Mon'
    WHEN DATEPART(WEEKDAY, started_at) = 3 THEN 'Tues'
    WHEN DATEPART(WEEKDAY, started_at) = 4 THEN 'Wed'
    WHEN DATEPART(WEEKDAY, started_at) = 5 THEN 'Thur'
    WHEN DATEPART(WEEKDAY, started_at) = 6 THEN 'Fri'
    ELSE 'Sat'
END AS day_of_week
FROM Cyclistic..Trips_2022

USE Cyclistic
GO

ALTER TABLE Trips_2022
ADD day_of_week nvarchar(50);

UPDATE Trips_2022
SET day_of_week = CASE
WHEN DATEPART(WEEKDAY, started_at) = 1 THEN 'Sun'
    WHEN DATEPART(WEEKDAY, started_at) = 2 THEN 'Mon'
    WHEN DATEPART(WEEKDAY, started_at) = 3 THEN 'Tues'
    WHEN DATEPART(WEEKDAY, started_at) = 4 THEN 'Wed'
    WHEN DATEPART(WEEKDAY, started_at) = 5 THEN 'Thur'
    WHEN DATEPART(WEEKDAY, started_at) = 6 THEN 'Fri'
    ELSE 'Sat'
	END

SELECT started_at,
CASE
WHEN DATEPART(MONTH, started_at) = 1 THEN 'Jan'
WHEN DATEPART(MONTH, started_at) = 2 THEN 'Feb'
WHEN DATEPART(MONTH, started_at) = 3 THEN 'Mar'
WHEN DATEPART(MONTH, started_at) = 4 THEN 'Apr'
WHEN DATEPART(MONTH, started_at) = 5 THEN 'May'
WHEN DATEPART(MONTH, started_at) = 6 THEN 'Jun'
WHEN DATEPART(MONTH, started_at) = 7 THEN 'Jul'
WHEN DATEPART(MONTH, started_at) = 8 THEN 'Aug'
WHEN DATEPART(MONTH, started_at) = 9 THEN 'Sep'
WHEN DATEPART(MONTH, started_at) = 10 THEN 'Oct'
WHEN DATEPART(MONTH, started_at) = 11 THEN 'Nov'
ELSE 'Dec'
END AS month
FROM Cyclistic..Trips_2022

ALTER TABLE Trips_2022
ADD month nvarchar(50)

UPDATE Trips_2021
SET month = CASE
WHEN DATEPART(MONTH, started_at) = 1 THEN 'Jan'
WHEN DATEPART(MONTH, started_at) = 2 THEN 'Feb'
WHEN DATEPART(MONTH, started_at) = 3 THEN 'Mar'
WHEN DATEPART(MONTH, started_at) = 4 THEN 'Apr'
WHEN DATEPART(MONTH, started_at) = 5 THEN 'May'
WHEN DATEPART(MONTH, started_at) = 6 THEN 'Jun'
WHEN DATEPART(MONTH, started_at) = 7 THEN 'Jul'
WHEN DATEPART(MONTH, started_at) = 8 THEN 'Aug'
WHEN DATEPART(MONTH, started_at) = 9 THEN 'Sep'
WHEN DATEPART(MONTH, started_at) = 10 THEN 'Oct'
WHEN DATEPART(MONTH, started_at) = 11 THEN 'Nov'
ELSE 'Dec'
END

/*
We proceed with the data analysis
*/

-- We change the docked_bike to classic_bike as they are the same bike type

UPDATE Trips_2022
SET rideable_type = 'classic_bike'
WHERE rideable_type = 'docked_bike'

-- Analysis --

-- amount of trips for each type of bike and member

SELECT rideable_type, member_casual, COUNT(*) AS amount_of_trips
FROM Cyclistic..Trips_2022
GROUP BY rideable_type, member_casual
ORDER BY member_casual, amount_of_trips DESC

-- amount of trips for each month

SELECT member_casual, month, COUNT(*) AS trips_per_month
FROM Cyclistic..Trips_2022
GROUP BY member_casual, month
ORDER BY trips_per_month DESC

-- ammount of trips per day

SELECT member_casual, day_of_week, COUNT(*) AS trips_per_day
FROM Cyclistic..Trips_2022
GROUP BY member_casual, day_of_week
ORDER BY trips_per_day DESC

-- ammount of trips per hour

SELECT member_casual, DATEPART(HOUR, started_at) AS hour_of_day, COUNT(*) AS trips_per_hour
FROM Cyclistic..Trips_2022
GROUP BY member_casual, DATEPART(HOUR, started_at)
ORDER BY trips_per_hour DESC

-- average length of trip per day

SELECT member_casual, 
       DATENAME(WEEKDAY, started_at) AS day_of_week, 
       ROUND(AVG(trip_duration), 0) AS avg_trip_duration
       --AVG(AVG(trip_duration)) OVER (PARTITION BY member_casual) AS combined_avg_ride_time
FROM Cyclistic..Trips_2022
GROUP BY member_casual, DATENAME(WEEKDAY, started_at)

-- total of minutes per member

SELECT member_casual, SUM(trip_duration) AS total_minutes
       --AVG(AVG(trip_duration)) OVER (PARTITION BY member_casual) AS combined_avg_ride_time
FROM Cyclistic..Trips_2022
GROUP BY member_casual

-- top 10 start station for casuals
SELECT TOP 10 member_casual = 'casual',
start_station_name, 
ROUND(AVG(start_lat),4) AS start_lat,
ROUND(AVG(start_lng),4) AS start_lng,
COUNT(*) AS num_trips
FROM Cyclistic..Trips_2022
WHERE member_casual = 'casual' and start_station_name <> 'Electric Lock'
GROUP BY start_station_name
ORDER BY num_trips DESC

-- top 10 end station for casuals

SELECT TOP 10 member_casual = 'casual',
end_station_name, 
ROUND(AVG(end_lat),4) AS end_lat,
ROUND(AVG(end_lng),4) AS end_lng,
COUNT(*) AS num_trips
FROM Cyclistic..Trips_2022
WHERE member_casual = 'casual' and start_station_name <> 'Electric Lock'
GROUP BY end_station_name
ORDER BY num_trips DESC

-- top 10 start station for members
SELECT TOP 10 member_casual = 'member',
start_station_name, 
ROUND(AVG(start_lat),4) AS start_lat,
ROUND(AVG(start_lng),4) AS start_lng,
COUNT(*) AS num_trips
FROM Cyclistic..Trips_2022
WHERE member_casual = 'member' and start_station_name <> 'Electric Lock'
GROUP BY start_station_name
ORDER BY num_trips DESC

-- top 10 end station for members

SELECT TOP 10 member_casual = 'member',
end_station_name, 
ROUND(AVG(end_lat),4) AS end_lat,
ROUND(AVG(end_lng),4) AS end_lng,
COUNT(*) AS num_trips
FROM Cyclistic..Trips_2022
WHERE member_casual = 'member' and start_station_name <> 'Electric Lock'
GROUP BY end_station_name
ORDER BY num_trips DESC

-- top 10 ending bike location for casuals

SELECT TOP 10 member_casual = 'casual',
ROUND(AVG(end_lat),4) AS end_lat,
ROUND(AVG(end_lng),4) AS end_lng,
COUNT(*) AS num_trips
FROM Cyclistic..Trips_2022
WHERE member_casual = 'casual' and end_station_name = 'Electric Lock'
GROUP BY end_lat, end_lng
ORDER BY num_trips DESC

-- top 10 ending bike location for members

SELECT TOP 10 member_casual = 'member',
ROUND(AVG(end_lat),4) AS end_lat,
ROUND(AVG(end_lng),4) AS end_lng,
COUNT(*) AS num_trips
FROM Cyclistic..Trips_2022
WHERE member_casual = 'member' and end_station_name = 'Electric Lock'
GROUP BY end_lat, end_lng
ORDER BY num_trips DESC
