-- DISCORD USER Michaela S.#9290

-- Tabulka 1

/* payroll-rok
 * payroll-průměrná mzda za rok
 * payroll-odvětví
 * price-produkt
 * price-rok
 * price-průměrná cena za rok
 * price-množství produktu za cenu
 */

-- Převod na společné roky: 2006-2018 - není třeba samostantě definovat, provede se přes inner join.

-- Průměrné roční mzdy pro jednotlivá odvětví, pro NULL napříč odvětvími
/* 5958 = kód pro mzdy */
SELECT
	AVG(cpay.value) AS avg_salary,
	LAG(AVG(cpay.value)) OVER (PARTITION BY cpay.industry_branch_code ORDER BY cpay.payroll_year) AS previous_avg_salary,
	cpay.industry_branch_code,
	cpay.payroll_year AS year_salary
FROM czechia_payroll cpay 
WHERE cpay.value_type_code = 5958
	AND cpay.calculation_code = 200
GROUP BY cpay.industry_branch_code, cpay.payroll_year
ORDER BY cpay.payroll_year, cpay.industry_branch_code;

-- Průměrné roční ceny produktů, region code NULL = data pro celou republiku
SELECT 
	AVG(cpri.value) AS avg_value, 
	cpri.category_code,
	YEAR(cpri.date_from) AS year_price 
FROM czechia_price cpri
WHERE cpri.region_code IS NULL
GROUP BY cpri.category_code, YEAR(cpri.date_from);

SELECT *
FROM czechia_price_category cpc
WHERE name = 'Mléko polotučné pasterované' OR name = 'Chléb konzumní kmínový';


CREATE OR REPLACE TEMPORARY TABLE t_payroll_project AS
	SELECT
		AVG(cpay.value) AS avg_salary,
		cpay.industry_branch_code,
		cpib.name AS industry,
		cpay.payroll_year AS year_salary
	FROM czechia_payroll cpay 
	LEFT JOIN czechia_payroll_industry_branch cpib 
		ON cpay.industry_branch_code = cpib.code 
	WHERE cpay.value_type_code = 5958
		AND cpay.calculation_code = 200
	GROUP BY cpay.industry_branch_code, cpay.payroll_year
	ORDER BY cpay.payroll_year, cpay.industry_branch_code;
	
CREATE OR REPLACE TEMPORARY TABLE t_prices_project AS
	SELECT 
		AVG(cpri.value) AS avg_value, 
		cpri.category_code,
		cpc.name AS item,
		CONCAT(cpc.price_value, ' ', cpc.price_unit) AS units,
		YEAR(cpri.date_from) AS year_price 
	FROM czechia_price cpri
	JOIN czechia_price_category cpc 
		ON cpri.category_code = cpc.code 
	WHERE cpri.region_code IS NULL
	GROUP BY cpri.category_code, YEAR(cpri.date_from);
	
SELECT *
FROM t_payroll_project tpp;

SELECT *
FROM t_prices_project;


CREATE OR REPLACE TABLE t_michaela_segers_project_SQL_primary_final AS
	SELECT *
	FROM t_payroll_project tpay
	JOIN t_prices_project tpri
		ON tpay.year_salary = tpri.year_price;

-- engeto server nedovolí vytvořit dočasné tabulky, takže alternativy:

CREATE OR REPLACE TABLE t_michaela_segers_project_SQL_primary_final AS 
 WITH tpay AS (
	SELECT
		AVG(cpay.value) AS avg_salary,
		cpay.industry_branch_code,
		cpib.name AS industry,
		cpay.payroll_year AS year_salary
	FROM czechia_payroll cpay 
	LEFT JOIN czechia_payroll_industry_branch cpib 
		ON cpay.industry_branch_code = cpib.code 
	WHERE cpay.value_type_code = 5958
		AND cpay.calculation_code = 200
	GROUP BY cpay.industry_branch_code, cpay.payroll_year),
tpri AS (
	SELECT 
		AVG(cpri.value) AS avg_value, 
		cpri.category_code,
		cpc.name AS item,
		CONCAT(cpc.price_value, ' ', cpc.price_unit) AS units,
		YEAR(cpri.date_from) AS year_price 
	FROM czechia_price cpri
	JOIN czechia_price_category cpc 
		ON cpri.category_code = cpc.code 
	WHERE cpri.region_code IS NULL
	GROUP BY cpri.category_code, YEAR(cpri.date_from)
	)
SELECT *
FROM tpay
JOIN tpri
	ON tpay.year_salary = tpri.year_price;

DROP TABLE t_michaela_segers_project_SQL_primary_final;

-- nebo

CREATE TABLE t_payroll_project AS
	SELECT
		AVG(cpay.value) AS avg_salary,
		cpay.industry_branch_code,
		cpib.name AS industry,
		cpay.payroll_year AS year_salary
	FROM czechia_payroll cpay 
	LEFT JOIN czechia_payroll_industry_branch cpib 
		ON cpay.industry_branch_code = cpib.code 
	WHERE cpay.value_type_code = 5958
		AND cpay.calculation_code = 200
	GROUP BY cpay.industry_branch_code, cpay.payroll_year
	ORDER BY cpay.payroll_year, cpay.industry_branch_code;
	
CREATE TABLE t_prices_project AS
	SELECT 
		AVG(cpri.value) AS avg_value, 
		cpri.category_code,
		cpc.name AS item,
		CONCAT(cpc.price_value, ' ', cpc.price_unit) AS units,
		YEAR(cpri.date_from) AS year_price 
	FROM czechia_price cpri
	JOIN czechia_price_category cpc 
		ON cpri.category_code = cpc.code 
	WHERE cpri.region_code IS NULL
	GROUP BY cpri.category_code, YEAR(cpri.date_from);


CREATE TABLE IF NOT EXISTS t_michaela_segers_project_SQL_primary_final AS
	SELECT *
	FROM t_payroll_project tpay
	JOIN t_prices_project tpri
		ON tpay.year_salary = tpri.year_price;
		
DROP TABLE t_prices_project;

DROP TABLE t_payroll_project;

-- Tabulka 2

/*
 * economies - rok
 * economies - země (evropské)
 * economies - GDP
 * economies - GINI
 * economies - population
 */

SELECT *
FROM economies e;

SELECT *
FROM countries c;


CREATE OR REPLACE TABLE t_michaela_segers_project_SQL_secondary_final AS
	SELECT 
		e.country,
		e.`year`,
		e.GDP,
		e.population,
		e.gini
	FROM economies e 
	JOIN countries c 
		ON e.country = c.country 
	WHERE c.continent = 'Europe'
		AND e.`year` BETWEEN 2006 AND 2018
	ORDER BY e.country, e.`year`;


-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?


WITH salaries AS (
	SELECT DISTINCT 
		year_salary,
		industry_branch_code,
		industry,
		avg_salary
	FROM t_michaela_segers_project_SQL_primary_final tms
	WHERE industry_branch_code IS NOT NULL
	)
SELECT 
	*,
	LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary) AS salary_prev,
	ROUND((avg_salary - LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary)) * 100 / LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary), 2) AS salary_growth
FROM salaries
ORDER BY salary_growth;


SELECT *
FROM (
	SELECT 
		*,
		LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary) AS salary_prev,
		ROUND((avg_salary - LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary)) * 100 / LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary), 2) AS salary_growth
	FROM (
		SELECT DISTINCT 
			year_salary,
			industry_branch_code,
			industry,
			avg_salary
		FROM t_michaela_segers_project_SQL_primary_final
		WHERE industry_branch_code IS NOT NULL ) x
	) y
WHERE year_salary > 2006
ORDER BY salary_growth;
		
SELECT *
FROM (
	SELECT 
		*,
		LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary) AS salary_prev,
		ROUND((avg_salary - LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary)) * 100 / LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary), 2) AS salary_growth
	FROM (
		SELECT DISTINCT 
			year_salary,
			industry_branch_code,
			industry,
			avg_salary
		FROM t_michaela_segers_project_SQL_primary_final
		WHERE industry_branch_code IS NOT NULL ) x
	) y
WHERE year_salary > 2006
ORDER BY salary_growth DESC;

SELECT
	industry_branch_code,
	industry,
	ROUND(AVG(y.salary_growth), 2) AS avg_salary_growth
FROM (
	SELECT 
		*,
		LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary) AS salary_prev,
		ROUND((avg_salary - LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary)) * 100 / LAG(avg_salary) OVER (PARTITION BY industry_branch_code ORDER BY year_salary), 2) AS salary_growth
	FROM (
		SELECT DISTINCT 
			year_salary,
			industry_branch_code,
			industry,
			avg_salary
		FROM t_michaela_segers_project_SQL_primary_final
		WHERE industry_branch_code IS NOT NULL ) x
	) y
WHERE year_salary > 2006
GROUP BY industry_branch_code
ORDER BY avg_salary_growth;

-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

SELECT *
FROM t_michaela_segers_project_sql_primary_final tmspspf
WHERE year_salary IN (2006, 2018)
	AND (item = 'Mléko polotučné pasterované' OR item = 'Chléb konzumní kmínový');
	
SELECT 
	avg_salary,
	industry,
	year_salary,
	avg_value,
	item,
	FLOOR(avg_salary / avg_value) AS items_afforded 
FROM t_michaela_segers_project_sql_primary_final tmspspf
WHERE year_salary IN (2006, 2018)
	AND (item = 'Mléko polotučné pasterované' OR item = 'Chléb konzumní kmínový')
	AND industry_branch_code IS NULL;

SELECT 
	avg_salary,
	industry,
	year_salary,
	avg_value,
	item,
	FLOOR(avg_salary / avg_value) AS items_afforded 
FROM t_michaela_segers_project_sql_primary_final tmspspf
WHERE year_salary IN (2006, 2018)
	AND (item = 'Mléko polotučné pasterované' OR item = 'Chléb konzumní kmínový')
ORDER BY items_afforded;

-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT 
	y.*,
	ROUND((y.avg_value - y.previous_price) * 100 / y.previous_price, 2) AS price_growth
FROM (
	SELECT 
		x.*,
		ROUND(LAG(avg_value) OVER (PARTITION BY category_code ORDER BY year_price), 3) AS previous_price
	FROM (
		SELECT DISTINCT 
			year_price,
			avg_value,
			category_code,
			item
		FROM t_michaela_segers_project_SQL_primary_final tmspspf
		) x
	) y
WHERE y.previous_price IS NOT NULL
ORDER BY price_growth;

SELECT 
	y.category_code,
	y.item,
	ROUND(AVG((y.avg_value - y.previous_price) * 100 / y.previous_price), 2) AS avg_price_growth
 FROM (
	SELECT 
		x.*,
		ROUND(LAG(avg_value) OVER (PARTITION BY category_code ORDER BY year_price), 3) AS previous_price
	FROM (
		SELECT DISTINCT 
			year_price,
			avg_value,
			category_code,
			item
		FROM t_michaela_segers_project_SQL_primary_final tmspspf
		) x
	) y
WHERE y.previous_price IS NOT NULL
GROUP BY y.category_code
ORDER BY avg_price_growth;

SELECT DISTINCT 
	item,
	avg_value 
FROM t_michaela_segers_project_SQL_primary_final tmspspf 
WHERE item LIKE '%cukr%'
AND year_price IN (2006, 2018);

-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

SELECT
	*,
	LAG(avg_salary) OVER (ORDER BY year_salary) AS previous_salary
FROM (
	SELECT DISTINCT 
		year_salary,
		avg_salary
	FROM t_michaela_segers_project_sql_primary_final tmspspf
	WHERE industry_branch_code IS NULL
	) x;

SELECT 
	*,
	LAG(avg_value) OVER (PARTITION BY category_code ORDER BY year_price) AS previous_value
FROM (
	SELECT DISTINCT 
		year_price,
		category_code,
		item,
		avg_value
	FROM t_michaela_segers_project_sql_primary_final tms
	) x;



WITH salaries AS (
	SELECT
		*,
		LAG(avg_salary) OVER (ORDER BY year_salary) AS previous_salary
	FROM (
		SELECT DISTINCT 
			year_salary,
			avg_salary
		FROM t_michaela_segers_project_sql_primary_final tmspspf
		WHERE industry_branch_code IS NULL
		) x
	),
	prices AS (
	SELECT 
	*,
	LAG(avg_value) OVER (PARTITION BY category_code ORDER BY year_price) AS previous_value
	FROM (
		SELECT DISTINCT 
			year_price,
			category_code,
			item,
			avg_value
		FROM t_michaela_segers_project_sql_primary_final tmspspf
	) x
	)
SELECT
	salaries.*,
	ROUND((salaries.avg_salary - salaries.previous_salary) * 100 / salaries.previous_salary, 2) AS salary_growth,
	prices.*,
	ROUND((prices.avg_value - prices.previous_value) * 100 / prices.previous_value, 2) AS price_growth,
	ROUND(((prices.avg_value - prices.previous_value) * 100 / prices.previous_value) - ((salaries.avg_salary - salaries.previous_salary) * 100 / salaries.previous_salary), 2) AS growth_difference
FROM salaries
JOIN prices
	ON salaries.year_salary = prices.year_price
WHERE salaries.year_salary > 2006
ORDER BY growth_difference DESC;


SELECT 
	tms.year_salary,
	ROUND((tms.avg_salary - tms2.avg_salary) * 100 / tms2.avg_salary, 2) AS salary_growth,
	ROUND(AVG((tms.avg_value - tms2.avg_value) * 100 / tms2.avg_value), 2) AS price_growth,
	ROUND((AVG((tms.avg_value - tms2.avg_value) * 100 / tms2.avg_value)) - ((tms.avg_salary - tms2.avg_salary) * 100 / tms2.avg_salary), 2) AS growth_difference
FROM t_michaela_segers_project_sql_primary_final tms
LEFT JOIN t_michaela_segers_project_sql_primary_final tms2 
	ON tms.category_code = tms2.category_code
	AND tms.year_salary = tms2.year_salary + 1
WHERE tms.industry_branch_code IS NULL 
	AND tms.year_salary > 2006
GROUP BY tms.year_price 
ORDER BY growth_difference DESC;

-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?
-- Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

SELECT 
	`year`,
	GDP,
	LAG(GDP) OVER (ORDER BY `year`) AS previous_GDP,
	ROUND((GDP - (LAG(GDP) OVER (ORDER BY `year`))) * 100 / (LAG(GDP) OVER (ORDER BY `year`)), 2) AS GDP_growth
FROM t_michaela_segers_project_sql_secondary_final tmspssf
WHERE country = 'Czech Republic';


SELECT 
	tms.year_salary,
	ROUND((tms.avg_salary - tms2.avg_salary) * 100 / tms2.avg_salary, 2) AS salary_growth,
	ROUND(AVG((tms.avg_value - tms2.avg_value) * 100 / tms2.avg_value), 2) AS price_growth,
	ROUND((tmspssf.GDP - tmspssf2.GDP) * 100 / tmspssf2.GDP, 2) AS GDP_growth
FROM t_michaela_segers_project_sql_primary_final tms
LEFT JOIN t_michaela_segers_project_sql_primary_final tms2 
	ON tms.category_code = tms2.category_code
	AND tms.year_salary = tms2.year_salary + 1
LEFT JOIN t_michaela_segers_project_sql_secondary_final tmspssf 
	ON tms.year_salary = tmspssf.`year`
LEFT JOIN t_michaela_segers_project_sql_secondary_final tmspssf2 
	ON tms.year_salary = tmspssf2.`year` + 1
	AND tmspssf.country = tmspssf2.country 
WHERE tms.industry_branch_code IS NULL 
	AND tms.year_salary > 2006
	AND tmspssf.country = 'Czech Republic'
GROUP BY tms.year_price 
;


SELECT 
	tms.year_salary,
	ROUND((tms.avg_salary - tms2.avg_salary) * 100 / tms2.avg_salary, 2) AS salary_growth,
	CASE 
		WHEN (tms.avg_salary - tms2.avg_salary) * 100 / tms2.avg_salary > 3 THEN 'significant +'
		WHEN (tms.avg_salary - tms2.avg_salary) * 100 / tms2.avg_salary < -3 THEN 'significant -'
		ELSE 'neutral'
	END AS salary_growth_summary,
	ROUND(AVG((tms.avg_value - tms2.avg_value) * 100 / tms2.avg_value), 2) AS price_growth,
	CASE 
		WHEN AVG((tms.avg_value - tms2.avg_value) * 100 / tms2.avg_value) > 3 THEN 'significant +'
		WHEN AVG((tms.avg_value - tms2.avg_value) * 100 / tms2.avg_value) < -3 THEN 'significant -'
		ELSE 'neutral'
	END AS price_growth_summary,
	ROUND((tmspssf.GDP - tmspssf2.GDP) * 100 / tmspssf2.GDP, 2) AS GDP_growth,
	CASE 
		WHEN (tmspssf.GDP - tmspssf2.GDP) * 100 / tmspssf2.GDP > 3 THEN 'significant +'
		WHEN (tmspssf.GDP - tmspssf2.GDP) * 100 / tmspssf2.GDP < -3 THEN 'significant -'
		ELSE 'neutral'
	END AS GDP_growth_summary
FROM t_michaela_segers_project_sql_primary_final tms
LEFT JOIN t_michaela_segers_project_sql_primary_final tms2 
	ON tms.category_code = tms2.category_code
	AND tms.year_salary = tms2.year_salary + 1
LEFT JOIN t_michaela_segers_project_sql_secondary_final tmspssf 
	ON tms.year_salary = tmspssf.`year`
LEFT JOIN t_michaela_segers_project_sql_secondary_final tmspssf2 
	ON tms.year_salary = tmspssf2.`year` + 1
	AND tmspssf.country = tmspssf2.country 
WHERE tms.industry_branch_code IS NULL 
	AND tms.year_salary > 2006
	AND tmspssf.country = 'Czech Republic'
GROUP BY tms.year_price 
;