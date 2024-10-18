-- Data After cleaning
-- Exploratory Data Analysis (EDA)
SELECT * FROM world_layoff_ds.layoffs_staging2;

-- laid-off : Total Count, Maximum and minimum details 
SELECT count(*) FROM world_layoff_ds.layoffs_staging2;
SELECT max(total_laid_off) FROM world_layoff_ds.layoffs_staging2;
SELECT max(total_laid_off), max(percentage_laid_off) FROM world_layoff_ds.layoffs_staging2;

-- when percent not null
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoff_ds.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

# 1 refers to 100 percent of employees laid off
SELECT * FROM world_layoff_ds.layoffs_staging2 where percentage_laid_off = 1 ;

SELECT *
FROM world_layoff_ds.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- laid-off by maximum funded company
SELECT *
FROM world_layoff_ds.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, total_laid_off
FROM world_layoff_ds.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;

-- laid-off by company
SELECT company, SUM(total_laid_off)
FROM world_layoff_ds.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- laid-off by location
SELECT location, SUM(total_laid_off)
FROM world_layoff_ds.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- laid-off by country
SELECT country, SUM(total_laid_off)
FROM world_layoff_ds.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- laid-off by Year
SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoff_ds.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;

SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoff_ds.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoff_ds.layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- laid-off details based on industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2 where date IS NULL;

select substring(`date`, 6, 2) as `Month`, sum(total_laid_off)
from layoffs_staging2
group by `Month`;

SELECT SUBSTRING(`date`, 1, 7) AS MONTH, 
       SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1 ASC;


-- Rolling Total of Layoffs Per Month
-- Rolling Total is CTE and it is temporary table 
-- and if any other operation other than selecting all the columns means need to execution along with below CTE main query 
-- using CTE
with Rolling_Total as 
(
SELECT SUBSTRING(date,1,7) as `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY `Month`
ORDER BY 1 ASC
)

-- select * from Rolling_Total;
-- below query need to run along with CTE above query or else the table does not exit error will come

select `Month`, total_off,
SUM(total_off) OVER(ORDER BY `Month`) AS rolling_total from Rolling_Total;


-- SET SQL_SAFE_UPDATES = 0;

SELECT company, total_laid_off, `date`
FROM layoffs_staging2
GROUP BY company; 

SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company 
ORDER BY 2 DESC;

SELECT company, `date`, SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company, `date`;

SELECT company, year(`date`), SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company, year(`date`)
order by 2;

SELECT company, year(`date`), SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company, year(`date`)
order by 2 desc;

SELECT company, year(`date`), SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company, year(`date`)
order by 3 desc;

WITH Company_Year AS
(
SELECT company, YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(date)
)
SELECT * 
FROM Company_Year;

-- in another way
-- WITH Company_Year (company, years, total_laid_off) AS
-- (
-- SELECT company, YEAR(date), SUM(total_laid_off)
-- FROM layoffs_staging2
-- GROUP BY company, YEAR(date)
-- )
-- SELECT * 
-- FROM Company_Year;
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(date)
)

SELECT 
  *, 
  DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking 
FROM Company_Year;

#To handle the NULL in the result, run CTE along with below query
# also CTE has two tables which uses previous table information

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
-- before another table name added
-- SELECT *,
-- DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
-- FROM Company_Year
-- WHERE years IS NOT NULL
-- ORDER BY Ranking ASC;
,
 company_year_rank as
 (
SELECT 
  *, 
  DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking 
FROM Company_Year
WHERE years IS NOT NULL 
)


-- ranking results not ordered by ranking 
select * from  company_year_rank where Ranking <=5;



