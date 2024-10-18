SELECT * 
FROM world_layoff_ds.layoffs;

-- creating backup table for data cleaning 
CREATE TABLE world_layoff_ds.layoffs_staging 
LIKE world_layoff_ds.layoffs;

-- Inserting all the data into layoffs_staging
INSERT world_layoff_ds.layoffs_staging 
SELECT * FROM world_layoff_ds.layoffs;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove duplicates
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways


SELECT *
FROM world_layoff_ds.layoffs_staging 
;

SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		world_layoff_ds.layoffs_staging;
        
        
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, date) AS row_num
FROM world_layoff_ds.layoffs_staging 
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- WITH duplicate_cte AS
-- (
-- SELECT *,
-- ROW_NUMBER() OVER(
-- PARTITION BY company, location, 
-- industry, total_laid_off, percentage_laid_off, "date", stage,
-- country, funds_raised_millions) AS row_num
-- FROM  world_layoff_ds.layoffs_staging 
-- )
-- SELECT *
-- FROM duplicate_cte WHERE row_num > 1;

-- To verify the duplicates
-- important: replace with Cazoo, Hibob, Wildlife Studios, Yahoo to where
-- to verify the duplicates  
SELECT * 
FROM world_layoff_ds.layoffs_staging 
WHERE company = 'Casper'; 

SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		 world_layoff_ds.layoffs_staging 
) duplicates
WHERE 
	row_num > 1;

-- Creating table with extra column details using back-tick near number 1 in keyboard 
-- and the schema of the previous one
use world_layoff_ds;

DROP TABLE layoffs_staging2; #droping table

CREATE TABLE  world_layoff_ds.`layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row number` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, date, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging;

select * from layoffs_staging2;

select count(*) from layoffs_staging2;

-- To check last row number details
SELECT * 
FROM layoffs_staging2
ORDER BY `row number` DESC 
LIMIT 100;

select * FROM layoffs_staging2
WHERE `row number` >= 2;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM layoffs_staging2
WHERE `row number`> 1;

select * from layoffs_staging2;

select count(*) from layoffs_staging2;

-- checking whether the row number greater than 1 is there
select * FROM layoffs_staging2
WHERE `row number` >= 2;

-- found only row number 1 is there
SELECT * 
FROM layoffs_staging2
ORDER BY `row number` DESC 
LIMIT 100;

-- Standardize data
SELECT * 
FROM world_layoff_ds.layoffs_staging2;

-- updating the columns after the set configurations
-- SET SQL_SAFE_UPDATES = 0;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM world_layoff_ds.layoffs_staging2
ORDER BY industry;

SELECT *
FROM world_layoff_ds.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

#checking the company columns with rows
SELECT *
FROM world_layoff_ds.layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM world_layoff_ds.layoffs_staging2
WHERE company LIKE 'airbnb%';

-- we should set the blanks to nulls since those are typically easier to work with
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT industry
FROM world_layoff_ds.layoffs_staging2
ORDER BY industry;



# handling country ending with '.'

SELECT DISTINCT country, TRIM(country)
FROM world_layoff_ds.layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

#updating with the checked trailing command
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
where country like 'United States%';


SELECT DISTINCT country
FROM world_layoff_ds.layoffs_staging2
ORDER BY country;

-- Let's also fix the date columns:
SELECT date,  STR_TO_DATE(`date`, '%m/%d/%Y') as modified_date
FROM world_layoff_ds.layoffs_staging2;

-- we can use str to date to update this field
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT date modified_date
FROM world_layoff_ds.layoffs_staging2;

SELECT *
FROM world_layoff_ds.layoffs_staging2;

#Until now same data type meaning date with text data type (check in the schemas of MySQL work bench
#below alter helps to change the data type from text to date

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM world_layoff_ds.layoffs_staging2;

#Look at Null Values

SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT DISTINCT industry
FROM world_layoff_ds.layoffs_staging2
where industry is null or industry = '';

SELECT *
FROM world_layoff_ds.layoffs_staging2
where industry is null or industry = '';

SELECT * 
FROM layoffs_staging2 
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

UPDATE world_layoff_ds.layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging2 
WHERE company = 'Airbnb';

SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM world_layoff_ds.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoff_ds.layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN `row number`;

SELECT * 
FROM world_layoff_ds.layoffs_staging2;