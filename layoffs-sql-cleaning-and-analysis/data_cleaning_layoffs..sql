-- SQL Project - Data Cleaning
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022


-- Step 1: Identify duplicate rows using row_number over key columns
WITH cte_row_num AS (
  SELECT *, 
         ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
							stage, country, funds_raised_millions) AS row_num
  FROM layoffs_staging
)
SELECT * 
FROM cte_row_num 
WHERE row_num > 1;

-- Step 2: Create a new table including row numbers to allow safe deletion of duplicates
CREATE TABLE `layoffs_staging2` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` TEXT,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_number` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 3: Populate the new table with data and computed row numbers
INSERT INTO layoffs_staging2
SELECT *, 
       ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

-- Step 4: Remove duplicate entries (keeping only the first occurrence)
DELETE FROM layoffs_staging2 
WHERE row_num > 1;


-- Step 5: Standardize company names by trimming extra whitespace
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET company = TRIM(company);


-- Step 6: Normalize industry values - unifying variations of 'Crypto' to a single value
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';


-- Step 7: Clean up country names - remove trailing periods (e.g. "United States.")
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);


-- Step 8: Format the `date` column properly and change the data type
-- Convert date from string to MySQL DATE format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter column type to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Step 9: Handle NULL and blank values in the `industry` column
SELECT DISTINCT industry
FROM layoffs_staging2;

-- Identify records where `industry` is NULL or blank
SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';

-- Convert blank values to NULL for consistency
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill in missing industry values where possible using matching company and location
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
  ON t1.company = t2.company AND t1.location = t2.location 
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 
  ON t1.company = t2.company AND t1.location = t2.location 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- Step 10: Remove rows with completely missing layoff data (cannot be recovered)
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
  
-- The NULL values in `total_laid_off`, `percentage_laid_off`, and `funds_raised_millions` appear valid and consistent with the dataset.
-- I’ve decided to keep them as NULL, as this facilitates accurate handling and aggregation during exploratory data analysis (EDA).


-- Step 11: Final cleanup - remove the helper column `row_number`
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
