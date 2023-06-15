---lets start with orders table---
----make order_id in the only form of number---
UPDATE orders
SET order_id = 
 CASE 
  WHEN LEFT(order_id, 2) = 'AA' THEN SUBSTRING(order_id, 3, LENGTH(order_id)-2) 
  WHEN LEFT(order_id, 1) = '_' THEN SUBSTRING(order_id, 2, LENGTH(order_id)-1)
  ELSE order_id
  END;

SELECT *
FROM orders
----separate date into year, month and day
ALTER TABLE orders
ADD COLUMN `Year` INTEGER,
ADD COLUMN `Month` INTEGER,
ADD COLUMN `Day` INTEGER;

    
UPDATE orders
SET Year = SUBSTRING(date, 1, 4),
    Month = SUBSTRING(date, 6, 2),
    Day = SUBSTRING(date, 9, 2);


SELECT order_id, date
FROM orders
WHERE date = ''

SELECT COUNT(order_id), COUNT(DISTINCT(order_id))
FROM orders

----to make sure repeated order_id are all deleted---
---there should only be 21350 order_id left---
---delete the value where there is no value at date----
DELETE FROM orders
WHERE date = ''

----delete duplicate rows, I created an empty temptable to do it---
SELECT order_id, COUNT(*) AS count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

CREATE TABLE TempTable AS
SELECT * FROM orders
WHERE 1=0;

INSERT INTO TempTable
SELECT DISTINCT * FROM orders;

DROP TABLE orders;

ALTER TABLE TempTable RENAME TO orders;

---now lets look at pizzas table---
---adjust the format of pizza_id---
UPDATE pizzas
SET pizza_id = CONCAT(pizza_type_id,'_', LOWER(size))

---change the price to pure number---
UPDATE pizzas
SET price = 
  CASE WHEN LEFT(price, 1) = '$' THEN SUBSTRING(price, 2, 4)
  ELSE price
  END;

 SELECT price
 FROM pizzas
