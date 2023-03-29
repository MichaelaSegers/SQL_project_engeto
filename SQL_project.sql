-- Tabulka 1

/* payroll-rok
 * payroll-průměrná mzda za rok
 * payroll-odvětví
 * price-produkt
 * price-rok
 * price-průměrná cena za rok
 */

-- Převod na společné roky: 2006-2018 - není třeba samostantě definovat, provede se přes inner join.

-- Průměrné roční mzdy pro jednotlivá odvětví, pro NULL napříč odvětvími
/* 5958 = kód pro mzdy */
SELECT
	AVG(cpay.value) AS avg_salary,
	cpay.industry_branch_code,
	cpay.payroll_year AS year_salary
FROM czechia_payroll cpay 
WHERE cpay.value_type_code = 5958
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
	GROUP BY cpay.industry_branch_code, cpay.payroll_year
	ORDER BY cpay.payroll_year, cpay.industry_branch_code;
	
CREATE OR REPLACE TEMPORARY TABLE t_prices_project AS
	SELECT 
		AVG(cpri.value) AS avg_value, 
		cpri.category_code,
		cpc.name AS item,
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


CREATE TABLE IF NOT EXISTS t_michaela_segers_project_SQL_primary_final AS
	SELECT *
	FROM t_payroll_project tpay
	JOIN t_prices_project tpri
		ON tpay.year_salary = tpri.year_price;

-- engeto server nedovolí vytvořit dočasné tabulky, takže alternativy:

CREATE TABLE t_michaela_segers_project_SQL_primary_final AS 
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
	GROUP BY cpay.industry_branch_code, cpay.payroll_year),
tpri AS (
	SELECT 
		AVG(cpri.value) AS avg_value, 
		cpri.category_code,
		cpc.name AS item,
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
	GROUP BY cpay.industry_branch_code, cpay.payroll_year
	ORDER BY cpay.payroll_year, cpay.industry_branch_code;
	
CREATE TABLE t_prices_project AS
	SELECT 
		AVG(cpri.value) AS avg_value, 
		cpri.category_code,
		cpc.name AS item,
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

SELECT *
FROM t_michaela_segers_project_SQL_primary_final tmspspf;