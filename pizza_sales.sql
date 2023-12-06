-----first, i want to separate the date into year/month/date and add quarters on it----

ALTER TABLE orders
ADD COLUMN `Year` INTEGER,
ADD COLUMN `Month` INTEGER,
ADD COLUMN `Day` INTEGER,
ADD COLUMN `Quarter` INTEGER;

UPDATE orders
SET `Year` = YEAR(`date`),
    `Month` = MONTH(`date`),
    `Day` = DAY(`date`),
    `Quarter` = QUARTER(`date`);

SELECT *
FROM orders

---instead of inserting the value from orders to order_details, i created a new table to combine two tables. So that when value changes on either table,  i wont need to update the third table----
CREATE VIEW pizza_order
AS 
SELECT od.order_details_id, od.order_id, od.pizza_id, od.quantity, o.month, o.day, o.quarter, p.price
FROM order_details od
JOIN orders o ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id

SELECT *
FROM pizza_order
ORDER BY order_details_id ASC

----i want to add revenue column to see how much is earned per day---
ALTER VIEW pizza_order 
AS
SELECT od.order_details_id, od.order_id, od.pizza_id, pt.name, pt.category, od.quantity, o.month, o.day, o.quarter, CONCAT(date, ' ' , time) AS date_time, p.price, p.price*od.quantity AS revenue
FROM order_details od
JOIN orders o ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id


SELECT *
FROM pizza_order
ORDER BY order_details_id ASC


---find the average revenue, average pizza sold and average customer number per day by quarter---
---this is done by creating a table x that has the average revenue, average pizza sold and average customer number per day by month and further group them into quarter---

SELECT quarter, avg(average_revenue_per_day), avg(average_pizza_sold), avg(average_customer_num)
FROM (SELECT quarter,
    month,
    SUM(revenue) AS total_revenue,
    COUNT(DISTINCT month) AS total_months,
    SUM(revenue) / COUNT(DISTINCT month) / COUNT(DISTINCT day)AS average_revenue_per_day,
    SUM(quantity) / COUNT(DISTINCT month) / COUNT(DISTINCT day) AS average_pizza_sold,
    COUNT(order_id) / COUNT(DISTINCT month) / COUNT(DISTINCT day) AS average_customer_num
FROM
    pizza_order
GROUP BY
	quarter, month) x
GROUP BY quarter

---figuring out the sales of each piza category of every quarter/season, ----
SELECT Quarter, SUM(quantity) AS pizza_sold, SUM(revenue) AS revenue, category
FROM pizza_order
GROUP BY category, quarter
ORDER BY quarter, revenue DESC

---finding the five best-selling pizza every quarter by creating a CTE---
WITH RankPizza AS (

 SELECT name, category, SUM(quantity) AS total_quantity, quarter, SUM(revenue) AS total_rev, 
   ROW_NUMBER() OVER(PARTITION BY quarter ORDER BY SUM(quantity)DESC) AS row_num
FROM pizza_order
GROUP BY name, quarter, category)

SELECT row_num, category, name, total_quantity, quarter, total_rev
FROM RankPizza
WHERE row_num <= 5
