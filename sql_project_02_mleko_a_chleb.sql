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