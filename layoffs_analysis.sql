-- Exploratory Data Analysis

SELECT * 
FROM layoffs_staging2;

-- Calculating maximum total of layoffs and the highest percentage of layoffs across companies
SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Analysing companies where entire workforce was laid off(100% layoffs)
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Calculating the total number of layoffs for each company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY company
ORDER BY 2 DESC;

-- Checking for the time period (earliest and latest) of layoffs in the dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Calculating the total number of employee layoffs by industry, from highest to lowest
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY industry
ORDER BY 2 DESC;

-- Calculating the total number of employeee layoffs by country, from highest to lowest
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY country
ORDER BY 2 DESC;

-- Calculating the total number of layofffs by year, from highest to lowest 
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Calculating the total number of layoffs by stage, from highest to lowest
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY stage
ORDER BY 2 DESC;

-- Calculating sum of employee layoffs by month
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2 
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

-- Calculating rolling total of employee layoffs by month 
WITH rolling_total AS (SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_Off
FROM layoffs_staging2 
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC)
SELECT `month`, total_off,SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM rolling_total;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Calculating the total number of layoffs by company and year, from highest to lowest
SELECT company,YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Analysing employee layoffs by company and the year of layoffs, ranked by total layoffs from highest to lowest, and showing the top 5 companies per year
WITH Company_year(company, years, total_laid_off)  AS (SELECT company,YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC), Company_year_rank AS(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_year
WHERE years IS NOT NULL)
SELECT *
FROM Company_year_rank
WHERE ranking<=5;



