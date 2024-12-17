-- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

SELECT * 
FROM t_Klara_Dvorakova_project_SQL_primary_final AS p;

SELECT * 
FROM t_Klara_Dvorakova_project_SQL_secondary_final AS c;

SELECT 
	 p.`year` 
	,AVG(p.wage) AS avgWage
	,AVG(p.FoodPrice) AS avgFoodPrice
	-- ,p.category
	,c.GDP
	,c.GDPLY
-- SELECT *
FROM t_Klara_Dvorakova_project_SQL_primary_final AS p
LEFT JOIN t_Klara_Dvorakova_project_SQL_secondary_final AS c ON p.`year` = c.`year`
WHERE 1=1
AND c.GDP IS NOT NULL
GROUP BY p.`year`, c.GDP, c.GDPLY  
HAVING AVG(p.FoodPrice) IS NOT NULL
;