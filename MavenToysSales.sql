----knowing how many stores they have across Mexico
SELECT count(DISTINCT store_id) 
FROM stores

---finding the sales performance of every retail store
SELECT s.store_id, ss.store_location, year(s.date) AS year, ROUND(SUM(CONVERT(SUBSTRING(p.product_price, 2), CHAR)* s.units)) AS revenue, SUM(s.units) AS sales_unit
FROM sales s
JOIN products p
ON p.product_id = s.product_id
JOIN stores ss
ON ss.store_id = s.store_id
GROUP BY s.store_id, ss.store_location, year(s.date)
ORDER BY s.store_id

----- Now i want to dig into the stock report to see the inventory status for each store  
-----finding the on-hand stock for each product of every store and which one is aging or needs to be replenished
SELECT store_id, product_id, stock_on_hand, sales_past_7days, stock_on_hand/sales_past_7days AS run_rate,
CASE 
WHEN stock_on_hand/sales_past_7days = 0 THEN "out of stock"
WHEN  stock_on_hand/sales_past_7days BETWEEN 0 AND 2 THEN "low inventory"
WHEN stock_on_hand/sales_past_7days > 10 THEN "aging stock"
ELSE stock_on_hand/sales_past_7days
END AS "inventroy status"
FROM (SELECT s.store_id, s.product_id, i.stock_on_hand, SUM(s.units) AS sales_past_7days
FROM sales s
JOIN inventory i
ON i.store_id = s.store_id
AND i.product_id = s.product_id
WHERE date >= (SELECT DATE_ADD(MAX(date), INTERVAL -6 DAY) FROM sales)

GROUP BY store_id, product_id, i.stock_on_hand
ORDER BY store_id, product_id) x
GROUP BY store_id, product_id, stock_on_hand

----follow up, i will calcualte the loss of revenue for each store due to the stockout issue 
WITH sales_table AS
(SELECT i.store_id, i.product_id, i.stock_on_hand, x.weekly_sales, ROUND(i.stock_on_hand/x.weekly_sales, 2) AS run_rate, x.avg_daily_sales
FROM (SELECT store_id, product_id, 
CASE
WHEN stock_on_hand = 0 THEN "out of stock"
ELSE stock_on_hand
END AS stock_on_hand
FROM inventory) i
JOIN (SELECT store_id, product_id, SUM(units) AS weekly_sales, SUM(units)/7 AS avg_daily_sales
FROM sales
WHERE date >= (SELECT DATE_ADD(MAX(date), INTERVAL -7 DAY) FROM sales)
GROUP BY store_id, product_id
ORDER BY store_id, product_id) x
ON i.store_id = x.store_id
AND i.product_id = x.product_id
GROUP BY i.store_id, i.product_id, i.stock_on_hand, x.weekly_sales, run_rate, x.avg_daily_sales)

SELECT s.store_id, s.stock_on_hand, SUM((s.avg_daily_sales*CONVERT(SUBSTRING(p.product_price, 2), CHAR))) AS loss_value
FROM sales_table s
JOIN products p
ON p.product_id = s.product_id
WHERE s.stock_on_hand = "out of stock"
GROUP BY s.store_id
ORDER BY s.store_id

-------finding the overall sales trend for the company from 2017-2018, I group the date by month
SELECT YEAR(s.date) AS year, MONTH(s.date) AS month, ROUND(SUM(CONVERT(SUBSTRING(p.product_price, 2), CHAR)* s.units)) AS revenue, ROUND(SUM((CONVERT(SUBSTRING(p.product_price, 2), CHAR)- CONVERT(SUBSTRING(p.product_cost, 2), CHAR))*s.units)) AS profit, SUM(s.units) AS sales_units
FROM sales s
JOIN products p
ON p.product_id = s.product_id
GROUP BY year, month

---break it down to product category 
SELECT YEAR(s.date) AS year, MONTH(s.date) AS month, p.product_category, ROUND(SUM(CONVERT(SUBSTRING(p.product_price, 2), CHAR)* s.units)) AS revenue, ROUND(SUM((CONVERT(SUBSTRING(p.product_price, 2), CHAR)- CONVERT(SUBSTRING(p.product_cost, 2), CHAR))*s.units)) AS profit, SUM(s.units) AS sales_unit
FROM sales s
JOIN products p
ON p.product_id = s.product_id
GROUP BY year, month, p.product_category

----finding the QoQ for each store location
SELECT stores.store_location, x.quarter, ROUND(AVG((y.revenue- x.revenue)/x.revenue), 3)*100 AS QoQ
FROM (SELECT ss.store_id, YEAR(s.date) AS year, QUARTER(s.date) AS quarter, ROUND(SUM(CONVERT(SUBSTRING(p.product_price, 2), CHAR)* s.units)) AS revenue
FROM sales s
JOIN products p
ON p.product_id = s.product_id
JOIN stores ss
ON s.store_id = ss.store_id
WHERE YEAR(s.date) = 2017
GROUP BY ss.store_id, year, quarter) AS x
JOIN (SELECT ss.store_id, YEAR(s.date) AS year, QUARTER(s.date) AS quarter, ROUND(SUM(CONVERT(SUBSTRING(p.product_price, 2), CHAR)* s.units)) AS revenue
FROM sales s
JOIN products p
ON p.product_id = s.product_id
JOIN stores ss
ON s.store_id = ss.store_id
WHERE YEAR(s.date) = 2018
GROUP BY ss.store_id, year, quarter) AS y
ON x.store_id = y.store_id
AND x.quarter = y.quarter
JOIN stores
ON stores.store_id = x.store_id
GROUP BY stores.store_location, x.quarter

----finding revenue/avg revenue/profit/sales unit of all store location 
SELECT x.store_location, year, quarter,SUM(revenue) AS revenue, SUM(profit) AS profit, SUM(total_sales_units) AS total_sales_units, ROUND(AVG(x.revenue)) AS avg_sales_revenue
FROM
(SELECT s.store_id, ss.store_location, YEAR(s.date) AS year, QUARTER(s.date) AS quarter, ROUND(SUM(CONVERT(SUBSTRING(p.product_price, 2), CHAR)* s.units)) AS revenue, ROUND(SUM((CONVERT(SUBSTRING(p.product_price, 2), CHAR)- CONVERT(SUBSTRING(p.product_cost, 2), CHAR))*s.units))AS profit, SUM(s.units) AS total_sales_units
FROM sales s
JOIN products p
ON s.product_id = p.product_id
JOIN stores ss
ON ss.store_id = s.store_id
GROUP BY s.store_id, ss.store_location, year, quarter) AS x
GROUP BY x.store_location, year, quarter

---finding the most profitable product category for each store location by year
---i create a temp table to get the profit/revenue/sales unit of each product category for all store location
WITH temp_table AS (

SELECT ss.store_location, p.product_category, year(s.date) AS year, ROUND(SUM(CONVERT(SUBSTRING(p.product_price, 2), CHAR)* s.units)) AS revenue, ROUND(SUM((CONVERT(SUBSTRING(p.product_price, 2), CHAR)- CONVERT(SUBSTRING(p.product_cost, 2), CHAR))*s.units))AS profit, SUM(s.units) AS sales 
FROM sales s
JOIN products p
ON p.product_id = s.product_id
JOIN stores ss
ON s.store_id = ss.store_id
GROUP BY p.product_category, ss.store_location, year
ORDER BY ss.store_location, year)

SELECT t.store_location, t.product_category, t.year, t.profit
FROM temp_table t
JOIN ( SELECT store_location, year, MAX(profit) AS profit
FROM temp_table
GROUP BY store_location, year) x
ON t.profit = x.profit
GROUP BY t.store_location, t.product_category, t.year
