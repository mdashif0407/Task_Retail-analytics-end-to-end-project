-- Creating Database
CREATE DATABASE retailshop;
USE retailshop;

-- Creating Table 
CREATE TABLE sales (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    description TEXT,
    quantity INT,
    invoice_date DATETIME,
    unit_price DECIMAL(10,2),
    customer_id VARCHAR(20),
    country VARCHAR(50),
    total_price DECIMAL(10,2),
    Month VARCHAR(10)
);
Select count(*) from sales;

-- Total Revenue
SELECT SUM(total_price) AS total_revenue
FROM sales;

-- Top 10 Best-Selling Products
SELECT description, SUM(quantity) AS total_sold
FROM sales
GROUP BY description
ORDER BY total_sold DESC
LIMIT 10;

-- Most Active Customers
SELECT customer_id, COUNT(DISTINCT invoice_no) AS total_invoices
FROM sales
GROUP BY customer_id
ORDER BY total_invoices DESC
LIMIT 10;

-- Monthly Sales Trend
SELECT Month, SUM(total_price) AS revenue
FROM sales
GROUP BY Month
ORDER BY Month;

-- Count most common products per invoice
SELECT stock_code, COUNT(DISTINCT invoice_no) AS invoice_count
FROM sales
GROUP BY stock_code
ORDER BY invoice_count DESC
LIMIT 20;

-- Top Countries by Number of Customers
SELECT country, COUNT(DISTINCT customer_id) AS unique_customers
FROM sales
GROUP BY country
ORDER BY unique_customers DESC;

-- Invoices With More Than 10 Items
SELECT invoice_no, SUM(quantity) AS total_items
FROM sales
GROUP BY invoice_no
HAVING total_items > 100
ORDER BY total_items DESC;

-- Products Sold in the Most Countries
SELECT description, COUNT(DISTINCT country) AS country_count
FROM sales
GROUP BY description
ORDER BY country_count DESC
LIMIT 20;

-- Daily Sales Count
SELECT DATE(invoice_date) AS sale_date,
       COUNT(*) AS total_rows
FROM sales
GROUP BY sale_date
ORDER BY sale_date;
                                                                                                    
-- Basket Table
CREATE TABLE basket AS
SELECT invoice_no,
       GROUP_CONCAT(stock_code ORDER BY stock_code SEPARATOR ',') AS items
FROM sales
GROUP BY invoice_no;

 SELECT * FROM basket;

-- Co-Occurrence Query
SELECT invoice_no, COUNT(stock_code) AS item_count
FROM sales
GROUP BY invoice_no
HAVING item_count > 1
ORDER BY item_count DESC
LIMIT 20;

-- Support / Confidence / Lift Query
-- Step 1: Support of Item A
SELECT COUNT(*) AS support_A
FROM sales
WHERE stock_code = '37444A';

-- Step 2: Support of Item B
SELECT COUNT(*) AS support_B
FROM sales
WHERE stock_code = '85099B';


-- Step 3: Support of BOTH (A & B in same invoice)
SELECT COUNT(*) AS support_A_B
FROM sales
WHERE invoice_no IN (
    SELECT invoice_no FROM sales WHERE stock_code = '37444A')
AND stock_code = '85099B';

-- Step 4: Confidence A → B
SELECT
    (SELECT COUNT(*) 
     FROM sales 
     WHERE invoice_no IN (
         SELECT invoice_no FROM sales WHERE stock_code = '37444A') AND stock_code = '85099B') /
    (SELECT COUNT(*) FROM sales WHERE stock_code = '37444A')
AS confidence_A_to_B;

-- Step 5: Lift
SELECT 
((SELECT COUNT(*) 
     FROM sales 
     WHERE invoice_no IN (
         SELECT invoice_no FROM sales WHERE stock_code = '37444A') AND stock_code = '85099B') /
    (SELECT COUNT(*) FROM sales WHERE stock_code = '37444A')) /
( (SELECT COUNT(*) FROM sales WHERE stock_code = '85099B') /
    (SELECT COUNT(*) FROM sales) )
AS lift_A_to_B;

-- Stock / Shelf Optimization
SELECT stock_code, description, SUM(quantity) AS total_sold
FROM sales
GROUP BY stock_code, description
ORDER BY total_sold DESC
LIMIT 20;

-- Promotion / Discount Analysis
SELECT stock_code, description,
       AVG(unit_price) AS avg_price,
       SUM(quantity) AS total_sold
FROM sales
GROUP BY stock_code, description
HAVING total_sold < 30
ORDER BY avg_price DESC
LIMIT 20;
