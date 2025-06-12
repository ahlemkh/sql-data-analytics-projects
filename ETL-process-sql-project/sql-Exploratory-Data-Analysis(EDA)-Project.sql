-- SQL Exploratory Data Analysis (EDA) Project

-- 1. Database Exploration
-- Retrieve metadata to understand the available tables and their structures

SELECT * 
FROM information_schema.tables 
WHERE table_schema = 'datawarehouseanalytics';

-- Explore column information for each key table
SELECT * 
FROM information_schema.columns 
WHERE table_schema = 'datawarehouseanalytics' 
AND table_name = 'products';

SELECT * 
FROM information_schema.columns 
WHERE table_schema = 'datawarehouseanalytics' 
AND table_name = 'dim_customers';

SELECT * 
FROM information_schema.columns 
WHERE table_schema = 'datawarehouseanalytics' 
AND table_name = 'sales';


-- 2. Dimension Exploration

-- Identify all customer countries represented in the dataset (5 distinct countries)
SELECT DISTINCT country 
FROM dim_customers;

-- Get all available product categories and subcategories
SELECT DISTINCT category, subcategory 
FROM products
ORDER BY 1;

-- Explore granularity by listing all products along with their category and subcategory
SELECT DISTINCT category, subcategory, product_name 
FROM products
ORDER BY 1, 2, 3;


-- 3. Date Exploration

-- Analyze customer birthdates to understand age demographics
-- Observations: 1916–1986 birth range → age range from 38 to 109 years
SELECT 
  MIN(birthdate) AS oldest_birth_date,
  TIMESTAMPDIFF(YEAR, MIN(birthdate), NOW()) AS oldest_age,
  MAX(birthdate) AS youngest_birth_date,
  TIMESTAMPDIFF(YEAR, MAX(birthdate), NOW()) AS youngest_age
FROM dim_customers;

-- Explore the timeframe of customer creation
-- Customers were added between 2025 and 2026
SELECT MIN(create_date), MAX(create_date) 
FROM dim_customers;

-- Understand the product availability period (start selling)
-- Product selling started between 2003 and 2013
SELECT MIN(start_date), MAX(start_date) 
FROM products;

-- Clean invalid order date records
UPDATE sales 
SET order_date = NULL 
WHERE order_date = '';

-- Analyze order, shipping, and due date ranges
-- Orders placed between 2010 and 2014
SELECT 
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  TIMESTAMPDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years
FROM sales;

-- Shipping dates: 2011–2014
SELECT MIN(shipping_date), MAX(shipping_date) 
FROM sales;

-- Due dates: 2011–2014
SELECT MIN(due_date), MAX(due_date) 
FROM sales;


-- 4. Measures Exploration

-- Calculate key metrics of the business

-- Total revenue from all sales: 29,356,250
SELECT SUM(sales_amount) AS total_sales 
FROM sales;

-- Total quantity of items sold: 60,423
SELECT SUM(quantity) AS total_quantity 
FROM sales;

-- Average selling price across all sales
SELECT AVG(price) AS avg_price 
FROM sales;

-- Total number of unique orders: 60,398
SELECT COUNT(DISTINCT order_number) AS total_orders 
FROM sales;

-- Total number of distinct products: 295
SELECT COUNT(product_number) AS total_products 
FROM products;

-- Total number of customers: 18,484
SELECT COUNT(customer_number) AS total_customers 
FROM dim_customers;

-- Number of customers who placed at least one order: 18,484
SELECT COUNT(DISTINCT customer_key) AS total_customers 
FROM sales;

-- Generate a summary report of all key business metrics
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM sales
UNION ALL
SELECT 'Total Products', COUNT(product_number) FROM products
UNION ALL
SELECT 'Total Customers', COUNT(customer_number) FROM dim_customers
UNION ALL
SELECT 'Customers with Orders', COUNT(DISTINCT customer_key) FROM sales;


-- 5. Magnitude Analysis

-- Total number of customers by country (descending order)
SELECT country, COUNT(customer_key) AS total_customers  
FROM dim_customers
GROUP BY country
ORDER BY 2 DESC;

-- Total customers by gender
-- The distribution is nearly balanced (male vs. female)
SELECT gender, COUNT(customer_key) AS total_customers  
FROM dim_customers
GROUP BY gender
ORDER BY 2 DESC;

-- Product count per category
-- Top categories by count: Components and Bikes
SELECT category, COUNT(product_key) AS total_products
FROM products
GROUP BY category
ORDER BY 2 DESC;

-- Average product cost by category
-- Bikes are the most expensive; Accessories the least
SELECT category, AVG(cost) AS average_cost 
FROM products
GROUP BY category
ORDER BY 2 ASC;

-- Total revenue generated per product category
-- Bikes contribute the highest revenue
SELECT p.category, SUM(s.sales_amount) AS total_revenue
FROM sales s
LEFT JOIN products p ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY 2 DESC;

-- Total revenue per customer
SELECT c.customer_key, c.first_name, c.last_name, SUM(s.sales_amount) AS total_revenue
FROM sales s
LEFT JOIN dim_customers c ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- Distribution of sold items across countries
SELECT c.country, SUM(s.quantity) AS total_sold_items
FROM sales s
LEFT JOIN dim_customers c ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY 2 DESC;


-- 6. Ranking Analysis

-- Top 5 products by total revenue (all are bikes)
SELECT p.product_name AS product, SUM(s.sales_amount) AS total_revenue
FROM sales s
LEFT JOIN products p ON s.product_key = p.product_key
GROUP BY product
ORDER BY 2 DESC
LIMIT 5;

-- Top 5 revenue-generating products per category
SELECT * FROM (
  SELECT p.category, p.product_name AS product, SUM(s.sales_amount) AS total_revenue,
         ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY SUM(s.sales_amount) DESC) AS rank_product
  FROM sales s
  LEFT JOIN products p ON s.product_key = p.product_key
  GROUP BY p.product_name, p.category
) AS ranked_table
WHERE rank_product <= 5;

-- Lowest 5 performing products in terms of revenue
SELECT p.product_name AS product, SUM(s.sales_amount) AS total_revenue
FROM sales s
LEFT JOIN products p ON s.product_key = p.product_key
GROUP BY product
ORDER BY 2 ASC
LIMIT 5;

-- Top 5 customers by total revenue
SELECT c.customer_key, c.first_name, c.last_name, SUM(s.sales_amount) AS total_revenue
FROM sales s
LEFT JOIN dim_customers c ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC
LIMIT 5;
