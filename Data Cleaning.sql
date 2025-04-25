
-- Data Cleaning on MySQL


-- Create a duplicate table for cleaning -----------------------------------------------------------

CREATE TABLE `layoffs_data_cleaning` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Removing duplicate data ------------------------------------------------------------------------

INSERT INTO layoffs_data_cleaning
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs;

DELETE 
FROM layoffs_data_cleaning where row_num > 1;


-- Deleting unused columnn ------------------------------------------------------------------------

ALTER TABLE layoffs_data_cleaning
DROP COLUMN row_num;


-- Standardizing data ----------------------------------------------------------------------------

UPDATE layoffs_data_cleaning
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_data_cleaning
ORDER BY 1;

SELECT * 
FROM layoffs_data_cleaning
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_data_cleaning 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_data_cleaning
ORDER BY 1;


UPDATE layoffs_data_cleaning
SET country = TRIM(TRAILING '.' FROM country);

ALTER TABLE layoffs_data_cleaning
MODIFY COLUMN `date` DATE;


-- Populating data ----------------------------------------------------------------------------

SELECT * 
FROM layoffs_data_cleaning
WHERE industry IS NULL
OR industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_data_cleaning t1
JOIN layoffs_data_cleaning t2
          ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = 'None')
AND t2.industry IS NOT NULL;

UPDATE layoffs_data_cleaning t1
JOIN layoffs_data_cleaning t2
          ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


-- Deleting records that can't be used in analysis ------------------------------------------------------

DELETE
FROM layoffs_data_cleaning
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

