-- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? 
-- Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?


SELECT * 
FROM t_Klara_Dvorakova_project_SQL_primary_final AS p
WHERE 1=1
AND p.FoodPrice IS NOT NULL;

SELECT * FROM t_Klara_Dvorakova_project_SQL_secondary_final AS c;

-- create view pro přidání předpředchozího roku, abychom mohli sledovat změnu potravin a mezd za následující rok
CREATE OR REPLACE VIEW view_Klara_Dvorakova_GDP AS 
SELECT 
	 c.year
	,c.GDP
	,c.GDPLY
	,c2.GDP AS GDPLLY
FROM t_Klara_Dvorakova_project_SQL_secondary_final AS c
LEFT JOIN t_Klara_Dvorakova_project_SQL_secondary_final AS c2 ON c.year = c2.year +2
WHERE 1=1
AND c2.GDP IS NOT NULL
ORDER BY c.year ASC
;

SELECT * FROM view_Klara_Dvorakova_GDP;

-- create view pro avg food price a vyhození kategorie Jakostní víno bílé, protože tam je jenom 3 roky

CREATE OR REPLACE VIEW view_Klara_Dvorakova_AVGFood AS
SELECT 
	 p.year
	,AVG(p.FoodPrice) AS avgFoodPrice
	,AVG(p.FoodPriceLY) AS avgFoodPriceLY
FROM t_Klara_Dvorakova_project_SQL_primary_final as p
WHERE 1=1
AND p.FoodPrice IS NOT NULL
AND p.category != 'Jakostní víno bílé'
GROUP BY p.year
;

SELECT * FROM view_Klara_Dvorakova_AVGFood;



-- create view pro avg wage

CREATE OR REPLACE VIEW view_Klara_Dvorakova_AVGWage AS
SELECT 
	 p.year
	,AVG(p.wage) AS avgWage
	,AVG(p.wageLY) AS avgWageLY
FROM t_Klara_Dvorakova_project_SQL_primary_final as p
WHERE 1=1
AND p.wage IS NOT NULL
GROUP BY p.year
;

SELECT * FROM view_Klara_Dvorakova_AVGWage;



SELECT
	 g.year
	,g.GDP
	,g.GDPLY 
	,g.GDPLLY 
	,f.avgFoodPrice 
	,f.avgFoodPriceLY 
	,w.avgWage 
	,w.avgWageLY 
	,(ROUND(g.GDP /g.GDPLY, 4) * 100) - 100 AS GDPpct
	,(ROUND(g.GDP /g.GDPLLY, 4) * 100) - 100 AS GDPpct2
	,(ROUND(w.avgWage /w.avgWageLY, 4) * 100) - 100 AS wagePct
	,(ROUND( f.avgFoodPrice / f.avgFoodPriceLY, 4) * 100) - 100 AS foodPct
FROM view_Klara_Dvorakova_GDP AS g
LEFT JOIN view_Klara_Dvorakova_AVGFood AS f ON g.year = f.year
LEFT JOIN view_Klara_Dvorakova_AVGWage AS w ON g.year = w.year
WHERE 1=1
AND f.avgFoodPriceLY IS NOT NULL

;








/*

SELECT 
	 p.`year` 
	,AVG(p.wage) AS avgWage
	,AVG(p.wageLY) AS avgWageLY
	,AVG(p.FoodPrice) AS avgFoodPrice
	,AVG(p.FoodPriceLY) AS avgFoodPriceLY
	-- ,p.category
	,c.GDP
	,c.GDPLY
	,(ROUND(c.GDP /c.GDPLY, 4) * 100) - 100 AS GDPpct
	,(ROUND(AVG(p.wage) /AVG(p.wageLY), 4) * 100) - 100 AS wagePct
	,(ROUND( AVG(p.FoodPrice) / AVG(p.FoodPriceLY), 4) * 100) - 100 AS foodPct
-- SELECT *
FROM t_Klara_Dvorakova_project_SQL_primary_final AS p
LEFT JOIN t_Klara_Dvorakova_project_SQL_secondary_final AS c ON p.year = c.year
WHERE 1=1
AND c.GDP IS NOT NULL
-- AND p.category != 'Jakostní víno bílé'
GROUP BY p.`year`, c.GDP, c.GDPLY  
HAVING AVG(p.FoodPriceLY) IS NOT NULL 

;

*/


