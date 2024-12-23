---create the table
CREATE TABLE walmart
(
	invoice_id	BIGINT PRIMARY KEY,
	branch TEXT,
	city TEXT,
	category TEXT,
	unit_price FLOAT,
	quantity FLOAT,
	date TEXT,
	time TEXT,
	payment_method	TEXT,
	rating FLOAT ,
	profit_margin FLOAT
);

select count(*) from walmart;

select
	payment_method,
	count(*)
from walmart
group by payment_method

--business problems
Q1 find different paymentmethod and numbero transations,numberofqtysale

SELECT
	payment_method,
	COUNT(*) asno_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

--project question #2
--Identify the highest_rated category in each branch, displaying the branch ,displaying the branch, category
--Avg rating
SELECT *
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1 

--Q3 identify the busiest day for each branch based on number of transactions
SELECT *
FROM
(SELECT
	branch,
	TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
	COUNT(*) as no_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
WHERE rank = 1

--Q4 Calculate the total quantity of items sold per payment method. list payment_method and total_quantity.

SELECT 
	payment_method,
	--count(*) as no_payments,
	sum(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

--Q5 determine the avg, min, and rating of category for each city.
--list the city ,avg_rating,min_rating, and max_rating.

select
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as min_rating,
	AVG(rating) as avg_rating
from walmart
GROUP BY 1,2 

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.
SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
WITH cte 
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1

-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices
SELECT
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC

-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == lastYEAR_rev-cURRENTYEAR_rev/lastyear_rev*100
SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5
