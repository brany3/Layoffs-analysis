-- Data cleaning Project

-- Data Cleaning Tasks

SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2.Standardize the Data
-- 3.Null values or blank values
-- 4.Remove Unnecessary Rows or Columns

-- Create a new table: Duplicate original dataset
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Inserting the data into the new table
INSERT INTO layoffs_staging
SELECT* FROM layoffs;

-- Checking the data inserted
SELECT * FROM layoffs_staging;

-- 1. Remove Duplicates

-- Identifying duplicate records
SELECT *, ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,country,funds_raised_millions) as row_num
FROM layoffs_staging;

WITH duplicate_cte AS(SELECT *, ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,country,funds_raised_millions) as row_num
FROM layoffs_staging)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

SELECT * FROM layoffs_staging
WHERE company='casper';

-- Creating another table duplicating original dataset to work with
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Checking the data
SELECT* FROM layoffs_staging2;


INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,country,funds_raised_millions) as row_num
FROM layoffs_staging;

-- Removing duplicate records
DELETE FROM layoffs_staging2
WHERE row_num >1;

SET SQL_SAFE_UPDATES = 0;

-- Confirming removal of duplicate records
SELECT* FROM layoffs_staging2
WHERE company= 'casper';

-- checking the data
SELECT* FROM layoffs_staging2;



-- 2.Standardizing Data

-- Standardizing company names by trimming extra spaces
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Removing extra spaces from company names by updating the table
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Checking all unique industries in the dataset
SELECT DISTINCT(industry) 
FROM layoffs_staging2;

-- Updating industries starting with 'Crypto' to just 'Crypto'
UPDATE layoffs_staging2
SET industry= 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Remove extra spaces from country names by updating the table
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM Country)
WHERE country LIKE 'United states%';

-- Converting the date column to the correct date format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Updating the date column to the correct date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modifying the date column to a proper date data type after conversion
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 


-- 3. Null or Blank Values

-- Checking records where both total_laid_off and percentage_laid_off are both NULL
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Checking records where industry column is NULL or has Blank values
SELECT * 
FROM layoffs_staging2
WHERE INDUSTRY IS NULL
OR industry = '';

-- Change empty 'industry' values to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry='';

-- Check records where the company is 'Airbnb'
SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company= t2.company
AND t1.location= t2.location
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL;

-- Update missing industry values by copying from another row with the same company and location
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company= t2.company
AND t1.location= t2.location
SET t1.industry= t2.industry
 WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT*
FROM layoffs_staging2
WHERE company LIKE 'Bally%';


-- 4.Remove unnecessary Rows or Columns

-- Finding rows where both total_laid_off and percentage_laid_off are NULL
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Deleting rows where both total_laid_off and percentage_laid_off are NULL
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Dropping the row_num column since it's no longer needed 
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Checking records after cleaning
SELECT * 
FROM layoffs_staging2;










