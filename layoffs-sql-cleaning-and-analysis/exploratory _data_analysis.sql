SELECT * FROM layoffs_staging2;

-- Explore the maximum number of layoffs in a single record
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

-- Check the date range of the dataset to understand the time coverage
-- Note: 2020–2023 includes the COVID-19 pandemic period
SELECT MAX(`date`), MIN(`date`)
FROM layoffs_staging2;

-- Analyze total layoffs by year
-- Observing peak layoffs in 2020, likely due to the onset of the COVID-19 crisis
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`);

-- Aggregate total layoffs by country
-- The United States appears to be the most affected based on total layoff counts
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Examine layoffs by industry
-- Consumer and retail sectors show the highest layoff numbers
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry 
ORDER BY 2 DESC;

-- Identify companies with the highest total layoffs
-- Large tech firms such as Amazon, Google, Meta, and Salesforce lead in layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Break down layoffs by company stage (e.g., post-IPO, Series B/C/D)
-- Later-stage companies experienced the largest number of layoffs
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Determine the highest percentage of workforce laid off in any single case
SELECT MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Identify companies that laid off 100% of their workforce
SELECT company 
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- Investigate funding levels of companies that laid off 100% of staff
-- This helps assess whether high funding protected against full layoffs
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Calculate monthly rolling total of layoffs
-- Helps visualize trends over time; notable rise seen in 2022
WITH rolling_total AS (
  SELECT SUBSTRING(`date`, 1, 7) AS `month`, 
         SUM(total_laid_off) AS total_off
  FROM layoffs_staging2 
  WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
  GROUP BY `month`
  ORDER BY 1
)
SELECT `month`, total_off, 
       SUM(total_off) OVER (ORDER BY `month`) AS rolling_sum
FROM rolling_total;

-- Identify the top 5 companies by layoffs for each year
-- Useful to highlight which firms had the most significant workforce reductions annually
WITH company_year (company, years, total_laid_off) AS (
  SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_off
  FROM layoffs_staging2
  WHERE YEAR(`date`) IS NOT NULL AND total_laid_off IS NOT NULL
  GROUP BY company, YEAR(`date`)
),
company_years_ranking AS (
  SELECT *, 
         DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM company_year
)
SELECT *  
FROM company_years_ranking
WHERE ranking <= 5;
