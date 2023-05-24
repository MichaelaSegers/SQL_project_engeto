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