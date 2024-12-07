-- 3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
SELECT 
	 p.category 
	,(SELECT p1.FoodPrice FROM t_Klara_Dvorakova_project_SQL_primary_final as p1 WHERE p1.year = 2006 AND p1.category = p.category) as first_price
	,(SELECT p2.FoodPrice FROM t_Klara_Dvorakova_project_SQL_primary_final as p2 WHERE p2.year = 2018 AND p2.category = p.category) as last_price
	,ROUND( 
	(SELECT p2.FoodPrice FROM t_Klara_Dvorakova_project_SQL_primary_final as p2 WHERE p2.year = 2018 AND p2.category = p.category)
	/
	(SELECT p1.FoodPrice FROM t_Klara_Dvorakova_project_SQL_primary_final as p1 WHERE p1.year = 2006 AND p1.category = p.category)
	,2) * 100.0 AS percantage
FROM t_Klara_Dvorakova_project_SQL_primary_final AS p
WHERE 1=1
AND p.FoodPrice IS NOT NULL
AND p.category != 'Jakostní víno bílé' -- má data en za 3 roky
GROUP BY p.category 
ORDER BY percantage

-- select * FROM t_Klara_Dvorakova_project_SQL_primary_final where category ='Cukr krystalový'
-- Cena cukr zdražuje nejpomaleji - dokonce zlevnil. Cena v roce 2006 byla 21,73 a v roce 2018 byla 15,75.