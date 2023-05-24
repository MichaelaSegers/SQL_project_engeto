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