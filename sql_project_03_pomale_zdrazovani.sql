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