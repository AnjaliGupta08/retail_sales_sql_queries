SELECT *
FROM retail;

-- first thing we want to do is create a staging table. 
-- This is the one we will work in and clean the data. We want a table with the raw data in case something happens.

CREATE TABLE retail_staging
LIKE retail;

INSERT retail_staging
SELECT *
FROM retail;

SELECT *
FROM retail_staging;

ALTER TABLE retail_staging
RENAME COLUMN ï»¿transactions_id TO transaction_id;

ALTER TABLE retail_staging
RENAME COLUMN quantiy TO quantity;

-- Let's also fix the date columns

SELECT CAST(sale_date AS DATE) 
FROM retail;

UPDATE retail_staging
SET sale_date = CAST(sale_date AS DATE) ;


ALTER TABLE retail_staging
MODIFY sale_time time;

                                          -- Checking For Duplicates

SELECT  sale_date, sale_time, customer_id, gender, age, category, quantiy, price_per_unit, cogs, total_sale,COUNT(*) AS cnt
FROM retail_staging
GROUP BY  sale_date, sale_time, customer_id, gender, age, category, quantiy, price_per_unit, cogs, total_sale
HAVING cnt>1;
-- There is no duplicates

					                         -- EDA
                                           
SELECT *
FROM retail_staging;

# TOTAL REVENUE

SELECT SUM(total_sale) AS TotalRevenue
FROM retail_staging;

# MONTHLY REVENUE TREND

SELECT MONTHNAME(sale_date) AS month , SUM( total_sale) AS MonthlyRevenue
FROM retail_staging
GROUP BY month
ORDER BY month;

# TOP 10 CUSTOMER BY REVENUE

SELECT customer_id,sum(total_sale) AS CustomerRevenue 
FROM retail_staging
GROUP BY customer_id
ORDER BY CustomerRevenue  DESC
LIMIT 10;

# REVENUE BY CATEGORY

SELECT category,sum(total_sale) AS CategoryRevenue 
FROM retail_staging
GROUP BY category
ORDER BY  CategoryRevenue  DESC;

# QUANTITY SOLD BY CATEGORY

SELECT category,sum(quantity) AS TotalQuantitySold 
FROM retail_staging
GROUP BY category
ORDER BY  TotalQuantitySold  DESC;

SELECT *
FROM retail_staging;

# DAILY REVENUE ( Recent 30 days)

SELECT sale_date,sum(total_sale) AS DailyRevenue
FROM retail_staging
GROUP BY Sale_date
ORDER BY  sale_date DESC
LIMIT 30;

# TOP BEST SELLING CATEGORY BY QUANTITY

SELECT category,sum(quantity) AS TotalQuantity
FROM retail_staging
GROUP BY Category
ORDER BY  TotalQuantity DESC;

# REVENUE BY GENDER

SELECT gender,sum(total_sale) AS Revenue
FROM retail_staging
GROUP BY gender;

# AGE GROUP REVENUE DISTRIBUTION

SELECT 
CASE 
WHEN age<20 THEN 'Under 20'
WHEN age BETWEEN 20 AND 29 THEN '20-29'
WHEN age BETWEEN 30 AND 39 THEN '30-39'
WHEN age BETWEEN 40 AND 49 THEN '40-49'
WHEN age>=50 THEN '50+'
END AS AgeGroup,
sum(total_sale) AS Revenue
FROM retail_staging
GROUP BY AgeGroup
ORDER BY Revenue DESC;

# TOP 5 CUSTOMER BY REVENUE ( Most valuable customer)

SELECT customer_id , sum(total_sale) AS Revenue
FROM retail_staging
GROUP BY customer_id
ORDER BY Revenue DESC
LIMIT 5;

# MONTHLY CUSTOMER COUNTS

SELECT monthname(sale_date) AS `Month`, COUNT( DISTINCT customer_id) AS TotalDistinctCustomer
FROM retail_staging
GROUP BY `Month`;


# MONTHLY NEW CUSTOMER COUNT


SELECT DATE_FORMAT(first_purchase_date, '%Y-%m') AS FirstPurchaseMonth,
  COUNT(first_purchase_date) AS NewCustomers
FROM (
  SELECT customer_id, MIN(sale_date) AS first_purchase_date
  FROM retail
  GROUP BY customer_id
) AS FirstPurchase
GROUP BY FirstPurchaseMonth
ORDER BY FirstPurchaseMonth;

SELECT
  CASE
    WHEN age < 20 THEN 'Under 20'
    WHEN age BETWEEN 20 AND 29 THEN '20-29'
    WHEN age BETWEEN 30 AND 39 THEN '30-39'
    WHEN age BETWEEN 40 AND 49 THEN '40-49'
    ELSE '50+'
  END AS AgeGroup,
  COUNT(DISTINCT customer_id) AS CustomerCount
FROM retail
GROUP BY AgeGroup
ORDER BY AgeGroup;








