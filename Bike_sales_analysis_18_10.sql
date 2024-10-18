-- creating database
create database bike_sales;

use bike_sales;

SELECT * FROM bike_sales.addresses;

SELECT * FROM businesspartners;

-- modify the column name 
-- ALTER TABLE addresses
-- RENAME COLUMN `ï»¿ADDRESSID` TO ADDRESSID;


-- total number of products for each product category
SELECT PRODCATEGORYID, COUNT(*) as total_no FROM bike_sales.products
group by PRODCATEGORYID;

-- top 5 most expensive products.
SELECT PRODUCTID, PRICE FROM products
ORDER BY PRICE DESC
LIMIT 5;
-- product count
SELECT count(*) FROM products;

-- all products that belong to the 'Mountain Bike' category
SELECT * FROM products p
LEFT JOIN productcategorytext pt
ON p.PRODCATEGORYID=pt.PRODCATEGORYID
WHERE SHORT_DESCR LIKE 'Mountain Bike'
;

-- total gross amount for each sales order.
SELECT SALESORDERID,SUM(GROSSAMOUNT) AS total_gross_amount 
FROM salesorders
GROUP BY SALESORDERID
ORDER BY total_gross_amount DESC;

-- total sales amount (gross) for each product category
SELECT p.PRODCATEGORYID, SUM((s.GROSSAMOUNT)) AS GROSS 
FROM salesorders s
LEFT JOIN products p
ON s.PARTNERID=p.SUPPLIER_PARTNERID
GROUP BY PRODCATEGORYID;

-- find the total number of products on each product categories
#select * from products;
SELECT PRODCATEGORYID, COUNT(*) as total_no
FROM products
GROUP BY PRODCATEGORYID;

-- calculate the total gross amount for each sales order
SELECT SALESORDERID, SUM(GROSSAMOUNT) as total_gross_amount
FROM salesorders
GROUP BY SALESORDERID
ORDER BY total_gross_amount;

-- Trend in sales over different fiscal year
-- Note: NET Amount is after tax reduction from the Gross amount

select * from salesorders;
-- problem with fiscalyearperiod datatype, actually in int
-- select Year(FISCALYEARPERIOD) from salesorders

-- practicing to separate the year
select substring(FISCALYEARPERIOD,1, 4) `year` from salesorders;
select left(FISCALYEARPERIOD, 4) `year` from salesorders;
select CONCAT(LEFT(FISCALYEARPERIOD, 4), '-', MID(FISCALYEARPERIOD, 5, 3)) from salesorders;
select STR_TO_DATE(CONCAT(LEFT(FISCALYEARPERIOD, 4), '-', MID(FISCALYEARPERIOD, 5, 3)), '%Y-%j') `year` from salesorders;

-- Trend in sales over different fiscal year periods
-- before updating checking the FISCALYEARPERIOD column
select * from salesorders;
# if we want to use year, the column mostly to be date data type if we are having other like 'int' or 'text'
# we need to alter or update follwed by alter  

-- updating 
UPDATE salesorders
SET FISCALYEARPERIOD = STR_TO_DATE(CONCAT(LEFT(FISCALYEARPERIOD, 4), '-', MID(FISCALYEARPERIOD, 5, 3)), '%Y-%j');

select * from salesorders;

# altering data type into date after updating the column values
ALTER TABLE salesorders
MODIFY COLUMN FISCALYEARPERIOD DATE;

# if we want to use year, the column mostly to be date data type if we are having other like 'int' or 'text'
# we need to alter or update follwed by alter  
select * from salesorders;

-- substring & left need index numbers where year can find if in the required format
select substring(FISCALYEARPERIOD,1, 4) `year` from salesorders;

select year(FISCALYEARPERIOD) `year`, sum(NETAMOUNT) 
from salesorders group by `year`;

-- same results as above based on column number
select year(FISCALYEARPERIOD) `year`, sum(NETAMOUNT) 
from salesorders group by 1;

-- Rolling total using CTE (with clause)
WITH ROLLING_TOTAL AS (
SELECT YEAR(FISCALYEARPERIOD) AS `YEAR`,SUM(GROSSAMOUNT) AS total_sales 
FROM salesorders
GROUP BY `YEAR`
ORDER BY total_sales DESC)
-- select * from ROLLING_TOTAL;
SELECT *, SUM(total_sales) OVER(ORDER BY total_sales DESC) AS rolling_totalsales FROM ROLLING_TOTAL;

-- How many business partners are there for each partner role?
SELECT PARTNERROLE, COUNT(*) AS no_of_partners FROM businesspartners
GROUP BY PARTNERROLE ;

-- Which products contribute the most to revenue when the billing status is 'Complete'?
-- solution:
-- here three tables involved and billing status is in salesorders 
select * from products; 
select * from productcategorytext; 
select * from salesorders; 
select count(*) from salesorders; -- totally 334 salesorders
select count(*) from salesorders where  BILLINGSTATUS='C'; -- totally 312 completed billing status
SELECT p.PRODUCTID,pt.SHORT_DESCR AS product_name,ROUND(SUM(NETAMOUNT),2) AS total_revenue FROM salesorders s 
LEFT JOIN products p 
ON s.PARTNERID=p.SUPPLIER_PARTNERID
LEFT JOIN productcategorytext pt
ON p.PRODCATEGORYID=pt.PRODCATEGORYID
-- GROUP BY p.PRODUCTID, product_name;
WHERE BILLINGSTATUS='C'
-- GROUP BY p.PRODUCTID, product_name;
GROUP BY p.PRODUCTID, product_name
ORDER BY total_revenue DESC;

-- Find the number of employees for each sex.
SELECT SEX,COUNT(*) no_employee 
FROM employees
GROUP BY sex; -- Male: 10 ; Female: 4

-- List the employees who have 'W' in their first name 
SELECT EMPLOYEEID, CONCAT(NAME_FIRST, " ", NAME_LAST) AS full_name FROM employees
WHERE NAME_FIRST LIKE '%W%'; # totally 2

-- List the top 5 employees who have created the most sales orders.
SELECT e.EMPLOYEEID, CONCAT(NAME_FIRST, " ", NAME_LAST) AS full_name, COUNT(s.SALESORDERID) AS sales_count FROM employees e
LEFT JOIN salesorders s
ON e.EMPLOYEEID=s.CREATEDBY
GROUP BY EMPLOYEEID, full_name
ORDER BY sales_count DESC
LIMIT 5;

-- top-selling product within each category along with its total sales amount.
-- part1
select * from products p left join productcategories pc
on p.PRODCATEGORYID=pc.PRODCATEGORYID;

-- part2
SELECT 
    P.PRODUCTID, 
    pc.PRODCATEGORYID, 
    P.CURRENCY,
    SUM(P.PRICE * soi.QUANTITY) TotalSalesAmount
FROM products p 
LEFT JOIN productcategories pc ON P.PRODCATEGORYID = pc.PRODCATEGORYID
LEFT JOIN salesorderitems soi ON soi.PRODUCTID = P.PRODUCTID
GROUP BY P.PRODUCTID, pc.PRODCATEGORYID, P.CURRENCY;

with top_selling as (SELECT 
    P.PRODUCTID, 
    pc.PRODCATEGORYID, 
    P.CURRENCY,
    SUM(P.PRICE * soi.QUANTITY) TotalSalesAmount
FROM products p 
LEFT JOIN productcategories pc ON P.PRODCATEGORYID = pc.PRODCATEGORYID
LEFT JOIN salesorderitems soi ON soi.PRODUCTID = P.PRODUCTID
GROUP BY P.PRODUCTID, pc.PRODCATEGORYID, P.CURRENCY), 

-- select * from top_selling;
top_ranking_sales as (
select * , rank() over(partition by PRODCATEGORYID order by TotalSalesAmount desc) sales_ranking 
from top_selling)
select PRODUCTID, PRODCATEGORYID, CURRENCY, TotalSalesAmount from top_ranking_sales where sales_ranking =1;


-- part3
SELECT  p.PRODUCTID, p.PRODCATEGORYID, p.CURRENCY,p.PRICE, pct.SHORT_DESCR, SUM(soi.QUANTITY * p.PRICE) AS TotalSalesAmount
FROM products p INNER JOIN productcategories pc
on p.PRODCATEGORYID=pc.PRODCATEGORYID
INNER JOIN salesorderitems soi
on soi.PRODUCTID=p.PRODUCTID
INNER JOIN productcategorytext pct
ON p.PRODCATEGORYID=pct.PRODCATEGORYID
GROUP BY p.PRODUCTID, p.PRODCATEGORYID, p.CURRENCY, p.PRICE, pct.SHORT_DESCR;

-- top-selling product within each category along with its total sales amount.
-- part6
WITH TOP_SELLING AS (
SELECT  p.PRODUCTID,
    p.PRODCATEGORYID,
    p.CURRENCY,
    p.PRICE,
    pct.SHORT_DESCR,
    SUM(soi.QUANTITY * p.PRICE) AS TotalSalesAmount
    FROM products p INNER JOIN productcategories pc
on p.PRODCATEGORYID=pc.PRODCATEGORYID
INNER JOIN salesorderitems soi
on soi.PRODUCTID=p.PRODUCTID
INNER JOIN productcategorytext pct
ON p.PRODCATEGORYID=pct.PRODCATEGORYID
GROUP BY p.PRODUCTID,
    p.PRODCATEGORYID,
    p.CURRENCY,
    p.PRICE,
    pct.SHORT_DESCR), TOP_SELLING_PRODUCT AS (
SELECT *, RANK() OVER(PARTITION BY PRODCATEGORYID ORDER BY TotalSalesAmount DESC) as sales_ranking   
FROM TOP_SELLING )
SELECT PRODUCTID,SHORT_DESCR AS PRODUCT_NAME, TotalSalesAmount FROM TOP_SELLING_PRODUCT
WHERE sales_ranking=1;


