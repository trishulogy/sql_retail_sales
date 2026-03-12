-- 1. DATABASE & TABLE SETUP --

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantiy INT, -- Note: Spelled 'quantiy' as per source schema
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

-- 2. DATA CLEANING --

-- Identify records with missing values
SELECT * FROM retail_sales
WHERE 
    transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL 
    OR gender IS NULL OR category IS NULL OR quantiy IS NULL 
    OR cogs IS NULL OR total_sale IS NULL;

-- Remove records with missing values
DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL 
    OR gender IS NULL OR category IS NULL OR quantiy IS NULL 
    OR cogs IS NULL OR total_sale IS NULL;

-- 3. DATA EXPLORATION --

-- Total transaction count
SELECT COUNT(*) AS total_records FROM retail_sales;

-- Total unique customers
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers FROM retail_sales;

-- List unique product categories
SELECT DISTINCT category FROM retail_sales;

-- 4. DATA ANALYSIS & BUSINESS PROBLEMS --

-- Q.1: Retrieve all columns for sales made on '2022-11-05'
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2: Retrieve transactions for 'Clothing' category with quantity >= 4 in Nov-2022
SELECT * FROM retail_sales
WHERE category = 'Clothing'
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND quantiy >= 4;

-- Q.3: Calculate total sales and number of orders for each category
SELECT 
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

-- Q.4: Find the average age of customers who purchased from the 'Beauty' category
SELECT 
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q.5: Find all transactions where the total sale is greater than 1000
SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- Q.6: Find the total number of transactions made by each gender in each category
SELECT 
    category,
    gender,
    COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category ASC;

-- Q.7: Calculate average monthly sales and find the best-selling month for each year
SELECT 
    year,
    month,
    avg_sale
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM sale_date) 
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY 1, 2
) AS t1
WHERE rank = 1;

-- Q.8: Find the top 5 customers based on the highest total sales
SELECT 
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q.9: Find the number of unique customers who purchased items from each category
SELECT 
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

-- Q.10: Categorize orders by shift (Morning, Afternoon, Evening)
WITH hourly_sale AS (
    SELECT *, 
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;

-- END OF PROJECT --