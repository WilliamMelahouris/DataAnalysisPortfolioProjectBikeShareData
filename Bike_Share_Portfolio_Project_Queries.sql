/*

Queries for Bike Share Data Analysis Project
Author: William Melahouris
Data source: https://divvy-tripdata.s3.amazonaws.com/index.html

This is the capstone project for the Google Data Analytics Professional Certificate
All Queries were written in Microsoft SQL Server Management Studio

*/

-- The first 9 queries focus on the past 12 months as a whole from
-- December 2020 through November 2021.

-- 1.

-- Combine all 12 months (all 12 tables) together.
-- We use SELECT INTO to create a new table called BikeShareDataCombined
-- which contains all the data from all 12 Excel files combined.

DROP TABLE IF EXISTS BikeShareDataCombined

SELECT * INTO BikeShareDataCombined
FROM (
-- December 2020
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202012-divvy-tripdata$']
UNION ALL
-- January 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202101-divvy-tripdata$']
UNION ALL
-- February 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202102-divvy-tripdata$']
UNION ALL
-- March 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202103-divvy-tripdata$']
UNION ALL
-- April 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202104-divvy-tripdata$']
UNION ALL
-- May 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202105-divvy-tripdata$']
UNION ALL
-- June 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202106-divvy-tripdata$']
UNION ALL
-- July 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202107-divvy-tripdata$']
UNION ALL
-- August 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202108-divvy-tripdata$']
UNION ALL
-- September 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202109-divvy-tripdata$']
UNION ALL
-- October 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202110-divvy-tripdata$']
UNION ALL
-- November 2021
SELECT *
FROM [BikeSharePortfolioProject].[dbo].['202111-divvy-tripdata$']
) AS MergedTables

-- Note: Had to use the ALTER TABLE code below in order to convert the data
-- type of some of the columns to nvarchar(255)

ALTER TABLE [BikeSharePortfolioProject].[dbo].['202111-divvy-tripdata$']
ALTER COLUMN start_station_id nvarchar(255)
ALTER TABLE [BikeSharePortfolioProject].[dbo].['202111-divvy-tripdata$']
ALTER COLUMN end_station_id nvarchar(255)

-- Now we have our combined data table to analyze
-- This table has 5,478,718 rows AKA rides over a period of 12 months 
-- (from December 2020 through November 2021)

SELECT COUNT(ride_id) AS total_num_rides
FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined

-- First, let's look at the past 12 months as a whole from 
-- December 2020 through November 2021

-- 2.

-- For the past 12 months (December 2020 through November 2021), get:
-- The total number of rides,
-- The total number of casual rides,
-- The total number of member rides,
-- The longest ride length

SELECT 
    -- Total number of rides
	COUNT(ride_id) AS total_num_rides,
	-- Total number of casual rides
	(SELECT COUNT(member_casual)
     FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual='member') AS total_casual_rides,
	-- Total number of member rides
	(SELECT COUNT(member_casual)
     FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual='casual') AS total_member_rides,
	-- Longest ride length
	ROUND(MAX(ride_length_mins),2) AS longest_ride_length_mins
FROM 
	BikeSharePortfolioProject.dbo.BikeShareDataCombined


-- 3.

-- Calculate the Mean, Median, and Mode of all the ride lengths 
-- from December 2020 through November 2021

SELECT 
	    /*
		   Mean
		*/
		(SELECT 
			ROUND(AVG(ride_length_mins),2) AS avg_ride_length_mins
		FROM 
			BikeSharePortfolioProject.dbo.BikeShareDataCombined) AS mean_ride_length_mins,
	   /*
	      Median
	   */
	   ((SELECT TOP 1 ride_length_x
		 FROM (
		 		 SELECT TOP 50 PERCENT ROUND(ride_length_mins,2) AS ride_length_x
				 FROM 
					 BikeSharePortfolioProject.dbo.BikeShareDataCombined 
				 ORDER BY ride_length_mins ASC
			  ) AS table_x
		 ORDER BY ride_length_x DESC) +
	    (SELECT TOP 1 ride_length_y
		 FROM (
				 SELECT TOP 50 PERCENT ROUND(ride_length_mins,2) AS ride_length_y
				 FROM 
				 	 BikeSharePortfolioProject.dbo.BikeShareDataCombined 
				 ORDER BY ride_length_mins DESC
		 ) AS table_y
		 ORDER BY ride_length_y ASC))/2 AS median_ride_length_mins,
		/*
		   Mode
		*/
	    (SELECT most_frequent_ride_length_mins
		 FROM (
		 SELECT TOP 1
		   ROUND(ride_length_mins,2) AS most_frequent_ride_length_mins, 
		   COUNT(ride_length_mins) AS num_occurances
		 FROM 
		   BikeSharePortfolioProject.dbo.BikeShareDataCombined
		 GROUP BY ride_length_mins
		 ORDER BY num_occurances DESC
		 ) AS tabletemp01) AS mode_ride_length_mins


-- 4. 

-- Count the total number of rides for the 3 different rideable
-- types for the past 12 months.
-- We see that classic_bike is the most popular

SELECT DISTINCT rideable_type
FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined

SELECT rideable_type, COUNT(ride_id) AS total_num
FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
GROUP BY rideable_type
ORDER BY total_num DESC

-- 5.

-- Determine which rideable types were most and least popular among casual and member riders.
-- Classic bikes were most popular for both casual riders and member riders.
-- Docked bikes were not very popular for members, but were for casuals.

SELECT rideable_type, member_casual, COUNT(rideable_type) AS total_num
FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
GROUP BY rideable_type, member_casual
ORDER BY member_casual, total_num DESC


-- 6.

-- Determine which days of the week had the most rides for the past 12 months
-- for casual riders vs member riders
-- We see casual riders most frequently ride on the weekend
-- Member riders most frequently ride in the middle of the week

SELECT day_of_week, member_casual, COUNT(ride_id) AS num_rides
FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
GROUP BY day_of_week, member_casual
ORDER BY member_casual, num_rides DESC


-- 7.

-- Determine the average ride length for members and casual riders
-- We see that casual riders tend to ride longer than members

SELECT member_casual, AVG(ride_length_mins) AS average_ride_length
FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
GROUP BY member_casual
ORDER BY member_casual


-- 8.

-- Determine the top 30 most popular start stations for members and casuals.
-- The vast majority of rides did not start at a station, so we will label
-- these as <No Start Station>

DROP TABLE IF EXISTS TopMostPopularStartStations

SELECT * INTO TopMostPopularStartStations
FROM (
	 SELECT
		 CASE
			 WHEN start_station_name IS NULL THEN '<No Start Station>'
			 ELSE start_station_name
		 END AS start_station_name, 
		 member_casual, 
		 COUNT(ride_id) AS num_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 GROUP BY start_station_name, member_casual
) AS MostPopularStartStations
ORDER BY member_casual, num_rides DESC

-- Top 30 Start Stations for Casual Riders
SELECT TOP 30 * 
FROM TopMostPopularStartStations
WHERE member_casual = 'casual'
ORDER BY num_rides DESC

-- Top 30 Start Stations for Member Riders

SELECT TOP 30 * 
FROM TopMostPopularStartStations
WHERE member_casual = 'member'
ORDER BY num_rides DESC

-- 9.

-- Determine the top 30 most popular end stations for members and casuals.
-- The vast majority of rides did not end at a station, so we will label
-- these as <No End Station>

DROP TABLE IF EXISTS TopMostPopularEndStations

SELECT * INTO TopMostPopularEndStations
FROM (
	 SELECT
		 CASE
			 WHEN end_station_name IS NULL THEN '<No End Station>'
			 ELSE end_station_name
		 END AS end_station_name, 
		 member_casual, 
		 COUNT(ride_id) AS num_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 GROUP BY end_station_name, member_casual
) AS MostPopularEndStations
ORDER BY member_casual, num_rides DESC

-- Top 30 End Stations for Casual Riders
SELECT TOP 30 * 
FROM TopMostPopularEndStations
WHERE member_casual = 'casual'
ORDER BY num_rides DESC

-- Top 30 End Stations for Member Riders

SELECT TOP 30 * 
FROM TopMostPopularEndStations
WHERE member_casual = 'member'
ORDER BY num_rides DESC


-- The remaining queries focus on each month as well as the
-- days of the week within each month

-- 10.

-- Get the total number of rides for each month.
-- We see the months with the most rides are all
-- between May and October.

SELECT year, month, COUNT(ride_id) AS total_num_rides
FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
GROUP BY year, month
ORDER BY total_num_rides DESC


-- 11.

-- For each (December 2020 through November 2021), get:
-- The total number of rides,
-- The total number of casual rides,
-- The total number of member rides,
-- The longest ride length

SELECT 
	a.year, 
	a.month, 
	a.total_num_rides, 
	b.total_num_casual_rides, 
	c.total_num_member_rides,
	d.longest_ride_length_mins
FROM 
	(SELECT year, month, COUNT(ride_id) AS total_num_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 GROUP BY year, month) AS a
JOIN 
	(SELECT year, month, COUNT(ride_id) AS total_num_casual_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'casual'
	 GROUP BY year, month) AS b
ON 
	a.year = b.year AND a.month = b.month
JOIN 
	(SELECT year, month, COUNT(ride_id) AS total_num_member_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'member'
	 GROUP BY year, month) AS c
ON 
	b.year = c.year AND b.month = c.month
JOIN
	(SELECT year, month, ROUND(MAX(ride_length_mins),2) AS longest_ride_length_mins
     FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 GROUP BY year, month) AS d
ON 
	c.year = d.year AND c.month = d.month
ORDER BY a.year, MONTH(a.month + ' 1 2021')


-- 12.

-- Calculate the mean and mode of all the ride lengths for each month

DROP TABLE IF EXISTS RideLengthFreqTable

-- Tells us how many rides there were for each given ride length
-- for each month
SELECT * INTO RideLengthFreqTable
FROM (
SELECT year, month, ROUND(ride_length_mins,2) AS ride_length_mins, COUNT(ride_length_mins) AS frequency
FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
GROUP BY year, month, ride_length_mins
) AS RideLengthFreqTable

SELECT *
FROM RideLengthFreqTable
ORDER BY year, MONTH(month + ' 1 2021'), frequency DESC

-- Tells us what the most frequent ride length in minutes was for a given month
SELECT year, month, MAX(frequency) AS highest_frequency
FROM RideLengthFreqTable
GROUP BY year, month

-- Do an INNER JOIN to determine the ride lengths with the highest
-- frequency in a given month. This is basically the mode of each
-- month.
-- It turns out that for every month, the most frequent ride length
-- was in fact 6 minutes. So the mode was 6 minutes for each month.

DROP TABLE IF EXISTS ModeTable

SELECT * INTO ModeTable
FROM
(
SELECT 
	a.year,
	a.month,
	a.ride_length_mins AS mode_ride_length_mins
FROM 
	RideLengthFreqTable AS a
JOIN 
	(SELECT year, month, MAX(frequency) AS highest_frequency
	 FROM RideLengthFreqTable
	 GROUP BY year, month) AS b
ON
	a.year = b.year AND a.month = b.month AND a.frequency = b.highest_frequency
) AS ModeTable

SELECT * FROM ModeTable

-- Now we combine everything together to get the mean and 
-- the mode ride length in minutes for each month
SELECT 
	a.year, 
	a.month, 
	a.mean_ride_length_mins, 
	b.mode_ride_length_mins
FROM 
	(SELECT year, month, ROUND(AVG(ride_length_mins),2) AS mean_ride_length_mins
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 GROUP BY year, month) AS a
JOIN 
	ModeTable AS b
ON
    a.year = b.year AND a.month = b.month


-- 13.

-- Calculate the average ride time on each day of the week for each month
-- for casual riders and member riders

SELECT
	a.year,
	a.month,
	a.day_of_week,
	a.casual_average_ride_length_mins,
	b.member_average_ride_length_mins
FROM
	(SELECT year, month, day_of_week, ROUND(AVG(ride_length_mins),2) AS casual_average_ride_length_mins
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'casual'
	 GROUP BY year, month, day_of_week) AS a
JOIN
	(SELECT year, month, day_of_week, ROUND(AVG(ride_length_mins),2) AS member_average_ride_length_mins
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'member'
	 GROUP BY year, month, day_of_week) AS b
ON 
	a.year = b.year AND a.month = b.month AND a.day_of_week = b.day_of_week
ORDER BY
	a.year, 
	MONTH(a.month + ' 1, 2021'), 
	CASE 
		WHEN a.day_of_week = 'Sunday' THEN 1
		WHEN a.day_of_week = 'Monday' THEN 2
		WHEN a.day_of_week = 'Tuesday' THEN 3
		WHEN a.day_of_week = 'Wednesday' THEN 4
		WHEN a.day_of_week = 'Thursday' THEN 5
		WHEN a.day_of_week = 'Friday' THEN 6
		ELSE 7
	END



-- 14.

-- Determine the total number of rides for each day of the week for
-- each month for casual riders and member riders

SELECT
	a.year, a.month, a.day_of_week, a.num_casual_rides, b.num_member_rides
FROM
	(SELECT year, month, day_of_week, COUNT(ride_id) AS num_casual_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'casual'
	 GROUP BY year, month, day_of_week) AS a
JOIN
	(SELECT year, month, day_of_week, COUNT(ride_id) AS num_member_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'member'
	 GROUP BY year, month, day_of_week) AS b
ON 
	a.year = b.year AND a.month = b.month AND a.day_of_week = b.day_of_week
ORDER BY 
	year, 
	MONTH(a.month + ' 1, 2021'),
    CASE 
		WHEN a.day_of_week = 'Sunday' THEN 1
		WHEN a.day_of_week = 'Monday' THEN 2
		WHEN a.day_of_week = 'Tuesday' THEN 3
		WHEN a.day_of_week = 'Wednesday' THEN 4
		WHEN a.day_of_week = 'Thursday' THEN 5
		WHEN a.day_of_week = 'Friday' THEN 6
		ELSE 7
	END


-- 15.

-- Calculate the percentage of casual riders vs member riders
-- for each month

SELECT
	a.year, 
	a.month, 
	a.total_rides, 
	b.total_casual_rides,
	c.total_member_rides,
	ROUND((CAST(b.total_casual_rides AS float) / total_rides)*100,3) AS percent_casual_rides,
	ROUND((CAST(c.total_member_rides AS float) / total_rides)*100,3) AS percent_member_rides
FROM
	(SELECT year, month, COUNT(ride_id) AS total_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 GROUP BY year, month) AS a
JOIN
	(SELECT year, month, COUNT(ride_id) AS total_casual_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'casual'
	 GROUP BY year, month) AS b
ON
	a.year = b.year AND a.month = b.month
JOIN
	(SELECT year, month, COUNT(ride_id) AS total_member_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'member'
	 GROUP BY year, month) AS c
ON
	b.year = c.year AND b.month = c.month
ORDER BY
	a.year,
	MONTH(a.month + ' 1, 2021')


-- 16.

-- Calculate the percentage of casual riders vs member riders
-- for each weekday of each month

SELECT
	a.year,
	a.month, 
	a.day_of_week, 
	c.num_rides, 
	a.num_casual_rides, 
	b.num_member_rides,
	ROUND((CAST(a.num_casual_rides AS float) / c.num_rides)*100,3) AS percent_casual_rides,
	ROUND((CAST(b.num_member_rides AS float) / c.num_rides)*100,3) AS percent_member_rides
FROM
	(SELECT year, month, day_of_week, COUNT(ride_id) AS num_casual_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'casual'
	 GROUP BY year, month, day_of_week) AS a
JOIN
	(SELECT year, month, day_of_week, COUNT(ride_id) AS num_member_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'member'
	 GROUP BY year, month, day_of_week) AS b
ON 
	a.year = b.year AND a.month = b.month AND a.day_of_week = b.day_of_week
JOIN
	(SELECT year, month, day_of_week, COUNT(ride_id) AS num_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 GROUP BY year, month, day_of_week) AS c
ON
	b.year = c.year AND b.month = c.month AND b.day_of_week = c.day_of_week
ORDER BY 
	year, 
	MONTH(a.month + ' 1, 2021'),
    CASE 
		WHEN a.day_of_week = 'Sunday' THEN 1
		WHEN a.day_of_week = 'Monday' THEN 2
		WHEN a.day_of_week = 'Tuesday' THEN 3
		WHEN a.day_of_week = 'Wednesday' THEN 4
		WHEN a.day_of_week = 'Thursday' THEN 5
		WHEN a.day_of_week = 'Friday' THEN 6
		ELSE 7
	END


-- 17.

-- Calculate the most popular rideable types for casual riders
-- and member riders for each month

DROP TABLE IF EXISTS NumRideablesTable

SELECT * INTO NumRideablesTable
FROM
(
SELECT year, month, rideable_type, member_casual, COUNT(ride_id) AS num_rideables
FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
GROUP BY year, month, rideable_type, member_casual
) AS NumRideablesTable

SELECT 
	a.year, 
	a.month, 
	a.rideable_type, 
	a.total_casual_riders, 
	b.total_member_riders,
	(a.total_casual_riders + b.total_member_riders) AS total_riders
FROM
	(SELECT year, month, rideable_type, num_rideables AS total_casual_riders
	 FROM NumRideablesTable
	 WHERE member_casual = 'casual') AS a
JOIN
	(SELECT year, month, rideable_type, num_rideables AS total_member_riders
	 FROM NumRideablesTable
	 WHERE member_casual = 'member') AS b
ON
	a.year = b.year AND a.month = b.month AND a.rideable_type = b.rideable_type
ORDER BY
	a.year,
	MONTH(a.month + ' 1, 2021')
	

-- 18.

-- Calculate the percentage of rideable types for casual riders
-- and member riders for each month

SELECT 
	a.year, 
	a.month, 
	a.rideable_type, 
	ROUND((CAST(a.total_casual_riders AS float) / (a.total_casual_riders + b.total_member_riders))*100,3) AS percent_casual_rides,
	ROUND((CAST(b.total_member_riders AS float) / (a.total_casual_riders + b.total_member_riders))*100,3) AS percent_member_rides,
	(a.total_casual_riders + b.total_member_riders) AS total_riders,
	a.total_casual_riders, 
	b.total_member_riders
FROM
	(SELECT year, month, rideable_type, num_rideables AS total_casual_riders
	 FROM NumRideablesTable
	 WHERE member_casual = 'casual') AS a
JOIN
	(SELECT year, month, rideable_type, num_rideables AS total_member_riders
	 FROM NumRideablesTable
	 WHERE member_casual = 'member') AS b
ON
	a.year = b.year AND a.month = b.month AND a.rideable_type = b.rideable_type
ORDER BY
	a.year,
	MONTH(a.month + ' 1, 2021')


-- 19.

-- Calculate the percentage of rideable types for casual riders
-- and member riders for each weekday of each month

SELECT
	a.year, 
	a.month, 
	a.day_of_week, 
	ROUND((CAST(a.num_casual_rides AS float) / (a.num_casual_rides + b.num_member_rides))*100,3) AS percent_casual_rides,
	ROUND((CAST(b.num_member_rides AS float) / (a.num_casual_rides + b.num_member_rides))*100,3) AS percent_member_rides,
	(a.num_casual_rides + b.num_member_rides) as total_rides,
	a.num_casual_rides, 
	b.num_member_rides
FROM
	(SELECT year, month, day_of_week, COUNT(ride_id) AS num_casual_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'casual'
	 GROUP BY year, month, day_of_week) AS a
JOIN
	(SELECT year, month, day_of_week, COUNT(ride_id) AS num_member_rides
	 FROM BikeSharePortfolioProject.dbo.BikeShareDataCombined
	 WHERE member_casual = 'member'
	 GROUP BY year, month, day_of_week) AS b
ON 
	a.year = b.year AND a.month = b.month AND a.day_of_week = b.day_of_week
ORDER BY 
	year, 
	MONTH(a.month + ' 1, 2021'),
    CASE 
		WHEN a.day_of_week = 'Sunday' THEN 1
		WHEN a.day_of_week = 'Monday' THEN 2
		WHEN a.day_of_week = 'Tuesday' THEN 3
		WHEN a.day_of_week = 'Wednesday' THEN 4
		WHEN a.day_of_week = 'Thursday' THEN 5
		WHEN a.day_of_week = 'Friday' THEN 6
		ELSE 7
	END