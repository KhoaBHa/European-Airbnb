SELECT *
FROM [Europe Airbnb]
/*Note for a few columns:
--Shared room: If the room in Airbnb is shared by anyone
--Private room: If the stay has private room available
--Multiple rooms: If the Airbnb has multiple rooms (2-4 rooms)
--Business: If the business has more than 4 offers
*/
					--DATA CLEANSING
--***Check for any outliers in each column
	--Check City Column
SELECT City
FROM [Europe Airbnb]
GROUP BY City

	--Check Day Column
SELECT Day
FROM [Europe Airbnb]
GROUP BY Day

	--Check [Room Type] Column
SELECT [Room Type]
FROM [Europe Airbnb]
GROUP BY [Room Type]

	--Check [Shared Room] Column
SELECT [Shared Room]
FROM [Europe Airbnb]
GROUP BY [Shared Room]

	--Check [Private Room] Column
SELECT [Private Room]
FROM [Europe Airbnb]
GROUP BY [Private Room]

	--Check Superhost Column
SELECT Superhost
FROM [Europe Airbnb]
GROUP BY Superhost

	--Check [Multiple Rooms] Column
SELECT [Multiple Rooms]
FROM [Europe Airbnb]
GROUP BY [Multiple Rooms]

	--Check Business Column
SELECT Business
FROM [Europe Airbnb]
GROUP BY Business


					--DATA EXPLORATION
--Create a view for data exploration and data visualization
	--DROP VIEW IF EXISTS EU_Airbnb
CREATE VIEW EU_Airbnb AS
SELECT [City]
      ,ROUND([Price], 0) as Price
      ,[Day]
      ,[Room Type]
      ,[Shared Room]
      ,[Private Room]
      ,[Person Capacity]
      ,[Superhost]
      ,[Multiple Rooms]
      ,[Business]
      ,[Cleanliness Rating]
      ,[Guest Satisfaction]
      ,[Bedrooms]
      ,ROUND([City Center (km)],2) as Distance_To_City_Center
      ,ROUND([Metro Distance (km)], 2) as Metro_Distance
    --,[Attraction Index]
      ,ROUND([Normalised Attraction Index], 2) as Normalised_Attraction_Index
    --,[Restraunt Index]
      ,ROUND([Normalised Restraunt Index], 2) as Normalised_Restaurant_Index
FROM [Portfolios].[dbo].[Europe Airbnb]

SELECT *
FROM EU_Airbnb

--***Maximum price in each city
SELECT City, MAX(Price) as maximum_price
FROM EU_Airbnb
GROUP BY City
ORDER BY City

--***Average price in each city
SELECT City, ROUND(AVG(Price), 0) as average_price
FROM EU_Airbnb
GROUP BY City
ORDER BY City

--***Percentage of multiple-room airbnb in each city (also applicable for Shared/Private Room, Person Capacity, Superhost, Multiple Rooms, Business)
SELECT num.City, num.number_of_multiple_rooms, den.total_number_of_rooms,
	--Convert the 2 numbers, then take a division between them, and round the results to 2 decimal places.
	ROUND(CONVERT(float, num.number_of_multiple_rooms)/CONVERT(float, den.total_number_of_rooms)*100, 2) as percentage_of_multiple_room
FROM
	(SELECT City, [Multiple Rooms], COUNT([Multiple Rooms]) as number_of_multiple_rooms --Calculate the numerator (number of multiple rooms)
	FROM EU_Airbnb
	GROUP BY City, [Multiple Rooms]
	HAVING [Multiple Rooms] = 1) num
JOIN
	(SELECT City, COUNT([Multiple Rooms]) as total_number_of_rooms --Calculate the denominator (total number of rooms)
	FROM EU_Airbnb
	GROUP BY City) den
ON num.City = den.City
ORDER BY num.City
	
--***Average guest satisfaction score for each city
SELECT City, ROUND(AVG([Guest Satisfaction]), 1) as Average_Satisfaction_Score
FROM EU_Airbnb
GROUP BY City
ORDER BY City

--***Most popular bedroom type in each city
WITH CTE_popular_bedroom AS (
	SELECT 
		a.City, a.Bedrooms, a.Number_of_bedrooms, 
		--Assign ranking to each bedroom type in each city by numbers of bedrooms. Rank 1 means the highest number of bedrooms.
		RANK() OVER (PARTITION BY City ORDER BY a.Number_of_bedrooms desc) as bedroom_ranking
	FROM 
		(SELECT City, Bedrooms, COUNT(*) as Number_of_bedrooms --Caluclate the number of rooms for each bedroom type for each city
		FROM EU_Airbnb
		GROUP BY City, Bedrooms) a)

SELECT City, Bedrooms, Number_of_bedrooms --Select the most popular bedroom type.
FROM CTE_popular_bedroom
WHERE bedroom_ranking = 1 --Replace the number to find the second most popular, the least popular bedroom type