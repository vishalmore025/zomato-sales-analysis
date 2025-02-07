select * from sheet1;
rename table sheet1 to zomato;
rename table sheet2 to country;

# Change DAteKey_opening to date data type
SET SQL_SAFE_UPDATES=0;
UPDATE zomato SET Datekey_Opening = REPLACE(Datekey_Opening, '_', '/') WHERE Datekey_Opening LIKE '%_%';
alter table zomato modify column Datekey_Opening date;

# Date Table
CREATE TABLE dateTable (
    DateKey DATE,
    years INT,
    months INT,
    day INT,
    monthname VARCHAR(20),
    quarter INT,
    yearmonth VARCHAR(50),
    weekday INT,
    dayname VARCHAR(20),
    quarters VARCHAR(2),
    Financial_months VARCHAR(5),
    financial_quarters VARCHAR(10)
);


INSERT INTO dateTable (DateKey, years, months, day, monthname, quarter, yearmonth, weekday, dayname, quarters, Financial_months, financial_quarters)
SELECT  distinct
    Datekey_Opening AS DateKey,
    YEAR(Datekey_Opening) AS years,
    MONTH(Datekey_Opening) AS months,
    DAY(Datekey_Opening) AS day,
    MONTHNAME(Datekey_Opening) AS monthname,
    QUARTER(Datekey_Opening) AS quarter,
    CONCAT(YEAR(Datekey_Opening), '-', MONTHNAME(Datekey_Opening)) AS yearmonth,
    WEEKDAY(Datekey_Opening) AS weekday,
    DAYNAME(Datekey_Opening) AS dayname,
    CASE 
        WHEN MONTHNAME(Datekey_Opening) IN ('January', 'February', 'March') THEN 'Q1'
        WHEN MONTHNAME(Datekey_Opening) IN ('April', 'May', 'June') THEN 'Q2'
        WHEN MONTHNAME(Datekey_Opening) IN ('July', 'August', 'September') THEN 'Q3'
        ELSE 'Q4'
    END AS quarters,
    CASE 
        WHEN MONTHNAME(Datekey_Opening) = 'January' THEN 'FM10' 
        WHEN MONTHNAME(Datekey_Opening) = 'February' THEN 'FM11'
        WHEN MONTHNAME(Datekey_Opening) = 'March' THEN 'FM12'
        WHEN MONTHNAME(Datekey_Opening) = 'April' THEN 'FM1'
        WHEN MONTHNAME(Datekey_Opening) = 'May' THEN 'FM2'
        WHEN MONTHNAME(Datekey_Opening) = 'June' THEN 'FM3'
        WHEN MONTHNAME(Datekey_Opening) = 'July' THEN 'FM4'
        WHEN MONTHNAME(Datekey_Opening) = 'August' THEN 'FM5'
        WHEN MONTHNAME(Datekey_Opening) = 'September' THEN 'FM6'
        WHEN MONTHNAME(Datekey_Opening) = 'October' THEN 'FM7'
        WHEN MONTHNAME(Datekey_Opening) = 'November' THEN 'FM8'
        WHEN MONTHNAME(Datekey_Opening) = 'December' THEN 'FM9'
    END AS Financial_months,
    CASE 
        WHEN MONTHNAME(Datekey_Opening) IN ('January', 'February', 'March') THEN 'FQ4'
        WHEN MONTHNAME(Datekey_Opening) IN ('April', 'May', 'June') THEN 'FQ1'
        WHEN MONTHNAME(Datekey_Opening) IN ('July', 'August', 'September') THEN 'FQ2'
        ELSE 'FQ3'
    END AS financial_quarters
FROM Zomato;
select * from datetable;

# No. Of Restaurants based on Cities
SELECT City, COUNT(RestaurantID) AS NumberOfRestaurants
FROM Zomato
GROUP BY City
ORDER BY NumberOfRestaurants DESC;

# No. of Restaurants based on countries
SELECT Country_name as Country ,count(RestaurantID) as No_of_Restaurants from zomato Z
left join country C on Z.Country_Code =C.CountryID
group by Country_name 
order by count(restaurantid) desc;

# No. of Restaurants based on year
select Years,count(restaurantid) as No_of_restaurants from datetable d
right join zomato z on d.datekey = z.datekey_opening
group by Years
order by years;

# No. of restaurants based on quarter
select Quarters as Quarter,count(restaurantid) as No_of_restaurants from datetable d
right join zomato z on d.datekey = z.datekey_opening
group by quarters
order by quarters;

# No. of restaurants based on Months

select Monthname as Month,count(restaurantid) as No_of_restaurants from datetable d
right join zomato z on d.datekey = z.datekey_opening
group by monthname,months
order by months;

# No. of Restaurants based on average ratings
SELECT 
    CASE 
        WHEN Rating < 1.5 THEN '⭐'
        WHEN Rating < 2.5 THEN '⭐⭐'
        WHEN Rating < 3.5 THEN '⭐⭐⭐'
        WHEN Rating < 4.5 THEN '⭐⭐⭐⭐'
        ELSE '⭐⭐⭐⭐⭐'
    END AS AvgRatings,
    COUNT(*) AS NumberOfRestaurants
FROM Zomato
GROUP BY Avgratings
ORDER BY count(*) desc;

# No. of restaurants based on Price bucket
SELECT 
    CASE 
        WHEN Average_Cost_for_two_in_USD <= 10 THEN '0-10'
        WHEN Average_Cost_for_two_in_USD <= 25 THEN '11-25'
        WHEN Average_Cost_for_two_in_USD <= 50 THEN '26-50'
        WHEN Average_Cost_for_two_in_USD <= 100 THEN '51-100'
        WHEN Average_Cost_for_two_in_USD <= 150 THEN '101-150'
        WHEN Average_Cost_for_two_in_USD <= 250 THEN '151-250'
        ELSE 'Above 250'
    END AS Price_Bucket,
    COUNT(*) AS Number_of_Restaurants
FROM (
    SELECT 
        CASE 
            WHEN z.Currency = '	Indian Rupees(Rs.)	 ' THEN z.Average_Cost_for_two * 0.012 
            WHEN z.Currency = '	dollar($)	 ' THEN z.Average_Cost_for_two * 1 
            WHEN z.Currency = '	Pounds(Œ£)	 ' THEN z.Average_Cost_for_two * 1.38 
            WHEN z.Currency = '	NewZealand($)	 ' THEN z.Average_Cost_for_two * 0.67 
            WHEN z.Currency = '	Emirati Diram(AED)	 ' THEN z.Average_Cost_for_two * 0.27
            WHEN z.Currency = '	Brazilian Real(R$)	 ' THEN z.Average_Cost_for_two * 0.2
            WHEN z.Currency = '	Turkish Lira(TL)	 ' THEN z.Average_Cost_for_two * 0.036 
            WHEN z.Currency = '	Qatari Rial(QR)	 ' THEN z.Average_Cost_for_two * 0.27
            WHEN z.Currency = '	Rand(R)	 ' THEN z.Average_Cost_for_two * 0.067
            WHEN z.Currency = '	Botswana Pula(P)	 ' THEN z.Average_Cost_for_two * 0.075
            WHEN z.Currency = '	Sri Lankan Rupee(LKR)	 ' THEN z.Average_Cost_for_two * 0.0027
            WHEN z.Currency = '	Indonesian Rupiah(IDR)	 ' THEN z.Average_Cost_for_two * 0.000065
        END AS Average_Cost_for_two_in_USD
    FROM 
        zomato z
) AS currency_conversion
WHERE 
    Average_Cost_for_two_in_USD IS NOT NULL
GROUP BY 
    Price_Bucket
ORDER BY 
    number_of_restaurants desc;

# Percentage of Resturants based on Has_online_delivery
SELECT 
    has_online_delivery,
    CONCAT(ROUND(COUNT(has_online_delivery) / (SELECT COUNT(*) FROM zomato) * 100), "%") AS percentage 
FROM 
    zomato 
WHERE 
    has_online_delivery = '	Yes	 '
GROUP BY 
    has_online_delivery;
    
# Percentage of Resturants based on Has_Table_booking
SELECT 
    Has_Table_booking,
    CONCAT(ROUND(COUNT(Has_Table_booking) / (SELECT COUNT(*) FROM zomato) * 100), "%") AS percentage 
FROM 
    zomato 
WHERE 
    Has_Table_booking = '	Yes	 '
GROUP BY 
    Has_Table_booking;

# No. of Restaurants
select 
count(restaurantid) as No_of_restaurants
from zomato;

# No. of Cities
select
count(distinctrow(city)) as No_of_cities
from zomato;

# No. of Countries
select
count(distinctrow(country_code)) as No_of_Countries
from zomato;

# No. of cuisines
select count(distinct(value)) as No_of_cuisines
from cuisines;


    
   






   


    
    


  
    


 







