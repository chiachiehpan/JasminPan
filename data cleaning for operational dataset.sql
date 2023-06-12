---rename table name---
RENAME TABLE data_cleaning.my_operational_data_operations TO operational_data;

---lets start from products
---to change all product_id to same form---
UPDATE products
SET product_id = 
 CASE 
  WHEN RIGHT(product_id, 1) = '-' THEN SUBSTRING(product_id, 4, LENGTH(product_id)-4) 
  ELSE SUBSTRING(product_id, 4, LENGTH(product_id)) 
  END;

SELECT product_id
FROM products

----change price to same format
UPDATE products
SET price = 
    CASE 
        WHEN LEFT(price, 1) = '$' THEN SUBSTRING(price, 2, LENGTH(price))
        ELSE price
    END;

SELECT price
FROM products

---combine same category with singular and plural name---
UPDATE products 
SET category = 'Toy'
WHERE category = 'Toys'

UPDATE products 
SET category = 'Electronic'
WHERE category = 'Electronics'

UPDATE products 
SET category = 'Sport'
WHERE category = 'Sports'

SELECT DISTINCT(category)
FROM products

----lets look at sales data---
---separate the date into year, month, day and time part

ALTER TABLE sales_data
ADD COLUMN `Year` INTEGER,
ADD COLUMN `Month` INTEGER,
ADD COLUMN `Day` INTEGER,
ADD COLUMN `Time` TIME;

UPDATE sales_data
SET `Year` = YEAR(`date`),
    `Month` = MONTH(`date`),
    `Day` = DAY(`date`),
    `Time` = TIME(`date`);

SELECT*
FROM sales_data

---to make the store start with capital letter
UPDATE sales_data
SET store = CONCAT(UPPER(LEFT(store,1)),
LOWER(RIGHT(store,LENGTH(store)-1)))

SELECT*
FROM sales_data

---fill the blank in quantity column by dividing revenue by price---
UPDATE sales_data s
JOIN products p ON s.product_id = p.product_id
SET s.quantity = 
   CASE
    WHEN s.quantity = '' THEN s.revenue / p.price
    ELSE s.quantity
    END;
---lets look at the shipping data----
---turn the error into TRUE or False when it has shipping record----
UPDATE shipping_data
SET error =
CASE 
 WHEN shipping_start = '' OR shipping_end = '' THEN  'TRUE'  
 ELSE 'FALSE'
 END;

---turn shipping_end to the same format as other columns---
UPDATE shipping_data
SET shipping_end =
  CONCAT(
    SUBSTRING(shipping_end, 7, 4),
    '-',
    SUBSTRING(shipping_end, 1, 2),
    '-',
    SUBSTRING(shipping_end, 4, 2),
    ' ',
    SUBSTRING(shipping_end, 12, 2),
    ':',
    SUBSTRING(shipping_end, 15, 2));



UPDATE shipping_data
 SET shipping_end =
 CASE WHEN shipping_end = '-- :' THEN ''
 ELSE shipping_end
 END;
 
---lets look at operational_data---
------separate the date into year, month, day and time part----
ALTER TABLE operational_data
ADD COLUMN `Year` INTEGER,
ADD COLUMN `Month` INTEGER,
ADD COLUMN `Day` INTEGER,
ADD COLUMN `Time` TIME;

UPDATE operational_data
SET `Year` = YEAR(STR_TO_DATE(date, '%m/%d/%Y %H:%i')),
    `Month` = MONTH(STR_TO_DATE(date, '%m/%d/%Y %H:%i')),
    `Day` = DAY(STR_TO_DATE(date, '%m/%d/%Y %H:%i')),
    `Time` = TIME(STR_TO_DATE(date, '%m/%d/%Y %H:%i'));

SELECT*
FROM operational_data

