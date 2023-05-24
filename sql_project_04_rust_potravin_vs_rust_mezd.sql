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