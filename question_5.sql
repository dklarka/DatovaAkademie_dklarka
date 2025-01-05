-- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? 
-- Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

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


-- create view pro průměrnou mzdu
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


SELECT
	 g.year
	,g.GDP
	,g.GDPLY 
	,g.GDPLLY 
	,f.avgFoodPrice 
	,f.avgFoodPriceLY 
	,w.avgWage 
	,w.avgWageLY 
	,(ROUND(g.GDP /g.GDPLY, 4) * 100) - 100 AS GDPpct -- Procentuální změna HDP oproti předchozímu roku
	,(ROUND(g.GDPLY /g.GDPLLY, 4) * 100) - 100 AS GDPpct2 -- Procentuální změna HDP předchozího oproti předpředchozímu roku
	,(ROUND(w.avgWage /w.avgWageLY, 4) * 100) - 100 AS wagePct -- Procentuální změna mezd oproti předchozímu roku
	,(ROUND( f.avgFoodPrice / f.avgFoodPriceLY, 4) * 100) - 100 AS foodPct -- Procentuální změna mezd oproti předpředchozímu roku
FROM view_Klara_Dvorakova_GDP AS g
LEFT JOIN view_Klara_Dvorakova_AVGFood AS f ON g.year = f.year
LEFT JOIN view_Klara_Dvorakova_AVGWage AS w ON g.year = w.year
WHERE 1=1
AND f.avgFoodPriceLY IS NOT NULL
;

-- Platy kopírují změnu HDP, ale potraviny se chovají atypicky, jak lze vidět na přiloženm grafu. Potraviny to také kopírovali do roku 2012/2013, kde bylo výraznější navýšení a to například kvůli zvýšení DPH na něteré potraviny.
