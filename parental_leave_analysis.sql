---the leading industry in terms of parental leave in general---
SELECT industry, AVG(`Paid Maternity Leave`), AVG(`Paid Paternity Leave`), AVG(`Paid Maternity Leave`)+AVG(`Paid Paternity Leave`) AS total_paid_leave, AVG(`Paid Maternity Leave`) - AVG(`Paid Paternity Leave`) AS paid_leave_gap, AVG(`Unpaid Maternity Leave`), AVG(`Unpaid Paternity Leave`), AVG(`Unpaid Maternity Leave`)+AVG(`Unpaid Paternity Leave`) AS total_unpaid_leave, AVG(`Unpaid Maternity Leave`) - AVG(`Unpaid Paternity Leave`) AS unpaid_leave_gap
FROM parental_leave
GROUP BY industry
ORDER BY AVG(`Paid Maternity Leave`) DESC

----the leading 100 company in terms of parental leave in general---
---i want to count the number of the company in each industry---
SELECT Company, industry, sub_category, `Paid Maternity Leave`
FROM parental_leave
ORDER BY `Paid Maternity Leave` DESC LIMIT 100;

SELECT Company, industry, sub_category, `Paid Paternity Leave`
FROM parental_leave
ORDER BY `Paid Paternity Leave` DESC LIMIT 100;

----paternity leave vs. maternity leave---
---first, in general among the 1600 surveyed companies across multiple industries---
SELECT AVG(`Paid Maternity Leave`), AVG(`Paid Paternity Leave`), AVG(`Unpaid Maternity Leave`), AVG(`Unpaid Paternity Leave`) 
FROM parental_leave




