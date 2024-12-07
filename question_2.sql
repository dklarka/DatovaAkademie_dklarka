-- 2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

 SELECT 
 	 p.year
	,p.category 
	,p.FoodPrice
	,(SELECT AVG(p1.wage)
		FROM t_Klara_Dvorakova_project_SQL_primary_final as p1
		WHERE 1=1
		AND p1.year = p.year
		) as avgWage
	,ROUND( (SELECT AVG(p1.wage)
		FROM t_Klara_Dvorakova_project_SQL_primary_final as p1
		WHERE 1=1
		AND p1.year = p.year
		)/p.FoodPrice,0) as foodForWage
 FROM t_Klara_Dvorakova_project_SQL_primary_final AS p
 WHERE 1=1
 AND (category = "Chléb konzumní kmínový" OR category = "Mléko polotučné pasterované")
 AND (year = 2006 OR year = 2018)
 ORDER BY year
;

SELECT 
	-- p.year
	 AVG(p.wage)
FROM t_Klara_Dvorakova_project_SQL_primary_final as p
WHERE 1=1
AND p.year = 2006
;

-- Chleba je možné si koupit za průměrný plat 1308 kg za 1. období (rok 2006) a za poslední období to je 1 363 (rok 2018). 
-- Mléka je možné si koupit za průměrný plat 1460l za 1. srovnatelné období (rok 2006) a za poslední srovnatelné období je možné si ho koupit 1 667 (rok 2018)

