/*
The goal is to provide actionable data-derived business insights using flight and airport data that will be useful in making 
investment decisions. The data was originally sourced from the Bureau of Transportation Statistics.
*/

-- setting the default schema to AirTraffic
USE AirTraffic;

/*
How many flights were there in 2018 and 2019 separately?
*/

SELECT YEAR(FlightDate) AS year, COUNT(*) AS total_flights
FROM flights
GROUP BY YEAR(FlightDate);
-- there were 3,218,653 flights in 2018 and 3,302,708 flights in 2019

/*
In total, how many flights were cancelled or departed late over both years?
*/

-- ensuring that Cancelled would be either 0 or 1
SELECT DISTINCT(Cancelled)
FROM flights;

-- finding the number of cancelled or delayed flights
SELECT COUNT(*) AS cancelled_or_delayed
FROM flights
WHERE DepDelay > 0 
	OR Cancelled = 1;
-- 2,633,237 flights were cancelled or delayed

/*
What is the number of flights that were cancelled broken down by the reason for cancellation?
*/

SELECT CancellationReason, COUNT(*) AS cancelled_flights
FROM flights
WHERE CancellationReason IS NOT NULL
GROUP BY CancellationReason;
/* 
50,225 flights were cancelled because of weather, 34,141 because of the carrier, 
7,962 because of the national air system, and 35 for security. 
*/

/*
For each month in 2019, what is the total number of flights and percentage of flights cancelled?
*/

SELECT MONTH(FlightDate) AS month, COUNT(*) AS total_flights, (SUM(Cancelled)/COUNT(*))*100 AS percentage_cancelled
FROM flights
WHERE YEAR(FlightDate)=2019
GROUP BY month
ORDER BY month;

/*
Firstly, it's clear that airline travel/revenue is cyclical. From the previous query we see that weather is at least one cause.
Overall, as the year progresses the number of cancelled flights decreases.
The first 6 months have around a 2% cancellation rate, the next 3 months around 1%, and the final 3 months below 1%.
Therefore it should be expected that airline revenue follows in the same pattern, increasing as the year goes along. 
*/

/*
Creating two new tables, one for each year showing the total miles traveled and number of flights broken down by airline.
*/

-- 2018
DROP TABLE flights_2018;

CREATE TABLE flights_2018 AS
SELECT AirlineName as airline, SUM(Distance) AS miles_traveled_2018, COUNT(*) AS flights_2018
FROM flights
WHERE YEAR(FlightDate)=2018
GROUP BY AirlineName;

-- 2019
DROP TABLE flights_2019;

CREATE TABLE flights_2019 AS
SELECT AirlineName as airline, SUM(Distance) AS miles_traveled_2019, COUNT(*) AS flights_2019
FROM flights
WHERE YEAR(FlightDate)=2019
GROUP BY AirlineName;

/*
Using the new tables, what is the year-over-year percent change in total flights and miles traveled for each airline?
*/

-- YoY % change for number of flights and total miles traveled
SELECT flights_2018.airline, 
	((flights_2019.flights_2019 - flights_2018.flights_2018) / flights_2018.flights_2018) * 100 AS YoY_percent_change_flights,
	((flights_2019.miles_traveled_2019 - flights_2018.miles_traveled_2018) / flights_2018.miles_traveled_2018) * 100 AS YoY_percent_change_miles
FROM flights_2018
JOIN flights_2019
ON flights_2018.airline = flights_2019.airline;

/*
Based on these results, it's clear that Delta Air Lines is experiencing the most growth in both total flights and total miles traveled. 
So far, it seems that this would be the best airline to invest in, based on this data. 
*/

/*
Another critical piece of information is what airports the three airlines utilize most commonly.
What are the 10 most popular destination airports overall? 
For this query I first join flights and airports then do the necessary aggregation.
*/

SELECT airports.AirportName, COUNT(*) AS ArrivingFlights
FROM flights
LEFT JOIN airports
ON airports.AirportID = flights.DestAirportID
GROUP BY airports.AirportName
ORDER BY ArrivingFlights DESC
LIMIT 10;

/*
For this query I use a subquery to aggregate and limit the flight data before joining with the airport information,
in order to optimize the runtime.
*/

SELECT airports.AirportName, destinations.ArrivingFlights
FROM 
	(SELECT DestAirportID, COUNT(*) AS ArrivingFlights
	FROM flights
	GROUP BY DestAirportID
	ORDER BY ArrivingFlights DESC
	LIMIT 10) AS destinations
LEFT JOIN airports
ON destinations.DestAirportID = airports.AirportID;

/*
This second query is faster because it cuts out all the unnecessary information before joining with the airports table.
The first query matches the airport name to every single destination ID of every single flight before narrowing down the 
information to the data we actually want to see. 
*/


/*
Since we don't have actual operating cost information available we need to infer a general overview of how each airline's costs 
compare by looking at data that reflects equipment and fuel costs.

Each plane has a unique tail number and the number of unique tail numbers for each airline should approximate how many planes 
the airline operates in total. 
*/

SELECT AirlineName, COUNT(DISTINCT(Tail_Number)) AS Aircrafts
FROM flights
GROUP BY AirlineName;
-- American Airlines has 993 aircrafts, Delta Air Lines 988, and Southwest Airlines 754

/*
Similarly, the total miles traveled by each airline gives an idea of total fuel costs and the distance traveled per plane gives 
an approximation of equipment costs. 
*/

-- querying for the total miles (shown in millions), total aircrafts, and aircraft average distance per airline (shown in millions)
SELECT AirlineName, SUM(Distance) / 1000000 AS TotalMilesMil, COUNT(DISTINCT(Tail_Number)) AS Aircrafts, 
	SUM(Distance) / COUNT(DISTINCT(Tail_Number)) / 1000000 AS AircraftAverageDistanceMil
FROM flights
GROUP BY AirlineName;

/*
Southwest Airlines has the least number of aircrafts, over two hundred less than both of the other airlines, yet it travels the most
total miles, meaning that the average distance per aircraft is significantly higher than for the other airlines. This means that it has 
the highest fuel costs and the highest equipment costs per plane. However, this could just mean that it gets the most bang for its buck.
If the ratio of tickets sold to average equipment cost is highest then that could mean they have the highest profits as well.
Alternatively, if they are squeezing every last mile out of their planes and doing less maintenance that could mean higher rates of 
cancelled flights and lower customer satisfaction, ultimately leading to lower priced tickets compared to the competition and
less revenue. 

How do we know which strategy is more profitable? There's not quite enough data to say for sure, but given that Delta is experiencing
the most growth in total flights and total miles it seems that customers prefer that experience, and may be willing to pay more for it.
Coupled with the fact that Delta has almost as many planes as American, this data indicates that Delta will probably experience
the highest increase in revenue.
*/

/*
Next, we will look into on-time performance more granularly in relation to the time of departure. 
We can break up the departure times into four categories as follows:

Between 7 and 11 is morning;
between 12 and 16 is afternoon;
between 17 and 21 is evening;
all else if night.

What's the average departure delay for each time-of-day across the whole data set? 
*/

SELECT 
CASE
    WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
    WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
    WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
    ELSE "4-night"
END AS "time_of_day",
AVG(IF (DepDelay <= 0, 0, DepDelay)) AS avg_delay
FROM flights 
GROUP BY time_of_day
ORDER BY time_of_day;

/*
Morning and night both have the least average departure delay with about an 8 minute delay (night a little less delayed than morning).
The average delay for the afternoon almost doubles to under 14 minutes, and evening average delays are even higher at around 18 minutes.
This pattern makes sense if people tend to like departing during their regular waking hours but at less obtrusive times, like after work. 
The busier an aiport is the more likely there are to be delays. Another explanation is that delays accumulate throughout the day,
and so there are going to be more delays in the evening.
*/

/*
What's the average departure delay for each airport and time-of-day combination?
*/

SELECT airports.AirportName, flights.time_of_day, flights.delay
FROM airports
JOIN
	(SELECT OriginAirportID,
	CASE
		WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
		WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
		WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
		ELSE "4-night"
	END AS "time_of_day",
	AVG(IF (DepDelay <= 0, 0, DepDelay)) AS delay
	FROM flights 
	GROUP BY OriginAirportID, time_of_day
	ORDER BY time_of_day) AS flights
ON flights.OriginAirportID = airports.AirportID;
/*
Looking through some of the data, it seems the pattern holds across different airports - 
afternoon and evening flights have higher delays. The same explanations as before could apply.
*/

/*
What's the average departure delay for morning flights at airports with at least 10,000 flights?
*/

SELECT airports.AirportName, flights.avg_morn_delay
FROM airports
JOIN
	(SELECT OriginAirportID,
	AVG(IF (DepDelay <= 0, 0, DepDelay)) AS avg_morn_delay,
	COUNT(*) AS total_flights
	FROM flights 
	WHERE HOUR(CRSDepTime) >= 7 AND HOUR(CRSDepTime) <= 11
	GROUP BY OriginAirportID
	HAVING total_flights >= 10000) AS flights
ON flights.OriginAirportID = airports.AirportID
ORDER BY avg_morn_delay;
-- morning average delays range from 5 minutes to over 13

/*
What are the top-10 airports with the highest average morning delay? In what cities are these airports located?
*/

SELECT airports.AirportName, flights.avg_morn_delay, airports.City
FROM airports
JOIN
	(SELECT OriginAirportID,
	AVG(IF (DepDelay <= 0, 0, DepDelay)) AS avg_morn_delay,
	COUNT(*) AS total_flights
	FROM flights 
	WHERE HOUR(CRSDepTime) >= 7 AND HOUR(CRSDepTime) <= 11
	GROUP BY OriginAirportID
	HAVING total_flights >= 10000
	ORDER BY total_flights) AS flights
ON flights.OriginAirportID = airports.AirportID
ORDER BY avg_morn_delay DESC
LIMIT 10;
-- unsurprisingly the airports with the highest average morning delays are located in some of the biggest cities in the US 

/*
In total, it seems that Delta Airlines would be the best airline to invest in. They've experienced the highest growth amongst the three
airlines. 
*/
