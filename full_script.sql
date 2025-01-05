-- Discord : dklarka


-- Vytvoření Tabulky Číslo 1

-- Vytvoření view z PAYROLL tabulky, které pomůže s vytvořením finální tabulky
CREATE OR REPLACE VIEW view_dklarka_payroll AS
SELECT 
	AVG(coalesce(p.value,0)) AS wage -- abychom nemuseli pracovat s NULL hodnotami
	,CASE WHEN pin.name IS NULL THEN '*N/A' ELSE pin.name END as industry
	,p.payroll_year as year
-- select  *
-- select count(*) -- 6880->3440 -- kontrola jestli jsme neztratili data
-- select distinct pvt.name
FROM czechia_payroll AS p -- p=payroll
LEFT JOIN czechia_payroll_calculation AS pcal ON p.calculation_code = pcal.code
LEFT JOIN czechia_payroll_industry_branch as pin ON p.industry_branch_code = pin.code 
LEFT JOIN czechia_payroll_value_type as pvt ON p.value_type_code = pvt.code 
WHERE 1=1
 AND pvt.name != 'Průměrný počet zaměstnaných osob'
 AND pcal.name = 'přepočtený' 
 GROUP BY payroll_year, pcal.name, pin.name 
 ORDER BY pin.name, payroll_year, payroll_quarter
 ;

-- Vytvoření druhého view PAYROLL které join sám se sebou abychom viděli mzdu z minulého roku
CREATE OR REPLACE VIEW view_dklarka_payroll_final AS
SELECT 
	 p.year
	,p.industry
	,p.wage
	,p2.wage AS wageLY
-- select count(*) -- 440
FROM view_dklarka_payroll AS p
LEFT JOIN view_dklarka_payroll AS p2 ON p.year = p2.year+1 AND p.industry = p2.industry
;

--  Vytvoření dalšího view pro FOOD PRICE
CREATE OR REPLACE VIEW view_dklarka_foodprice AS
SELECT 
	 YEAR(date_from) AS year
	,prc.name AS category
	,prc.price_value
	,prc.price_unit
	,AVG(coalesce(value,0)) AS FoodPrice -- abychom nemuseli pracovat s NULL hodnotami
FROM czechia_price AS pr
LEFT JOIN czechia_price_category AS prc ON pr.category_code = prc.code 
GROUP BY prc.name, YEAR(date_from),prc.price_value,prc.price_unit
;

-- Vytvoření druhého view FOOD PRICE které join sám se sebou abychom viděli cenu potravin z minulého roku
CREATE OR REPLACE VIEW view_dklarka_foodprice_final AS
SELECT 
	 f.year
	,f.category
	,f.price_value
	,f.price_unit
	,f.FoodPrice
	,f2.FoodPrice AS FoodPriceLY
-- select *
-- select count(*) -- 342 
FROM view_dklarka_foodprice AS f
LEFT JOIN view_dklarka_foodprice AS f2 ON f.year = f2.year+1 AND f.category = f2.category
;

-- Použijeme řídkou matici na spojení 2 view
CREATE OR REPLACE TABLE t_Klara_Dvorakova_project_SQL_primary_final AS 
SELECT
	 vp.year AS year
	,vp.industry AS industry 
	,vp.wage 
	,vp.wageLY
	,NULL AS category
	,NULL AS price_value
	,null AS price_unit
	,null AS FoodPrice
	,null AS FoodPriceLY
FROM view_dklarka_payroll_final as vp
UNION ALL
SELECT 
	 vf.year AS year
	,null AS industry 
	,null AS wage
	,null AS wageLY
	,vf.category AS category
	,vf.price_value AS price_value
	,vf.price_unit AS price_unit
	,vf.FoodPrice AS FoodPrice
	,vf.FoodPriceLY AS FoodPriceLY
FROM view_dklarka_foodprice_final as vf 
;


-- Tabulka která obsahuje 1. mzdy a odvětví a 2. cenu potravin a kateorie potravin každé za každý rok.
SELECT * FROM t_Klara_Dvorakova_project_SQL_primary_final
 

DROP VIEW IF EXISTS view_dklarka_payroll;
DROP VIEW IF EXISTS view_dklarka_payroll_final;
DROP VIEW IF EXISTS view_dklarka_foodprice;
DROP VIEW IF EXISTS view_dklarka_foodprice_final;


-- Vytvoření Tabulky Číslo 2

-- Vytvoření pomocného view kde se join economies a countries
CREATE OR REPLACE VIEW view_dklarka_economy AS
SELECT 
	 e.GDP
	,e.`year` 
FROM economies as e 
JOIN countries as c ON c.country = e.country 
WHERE 1=1
AND c.country LIKE '%Cz%'
AND e.GDP IS NOT NULL
ORDER BY e.year ASC;

-- Vytvoření finální tabulky kde se ještě join ta samá tabulka abychom přidali předchozí rok
CREATE OR REPLACE TABLE t_Klara_Dvorakova_project_SQL_secondary_final AS 
SELECT
	 e.year
	,e.GDP
	,e2.GDP AS GDPLY
FROM view_dklarka_economy AS e
LEFT JOIN view_dklarka_economy AS e2 ON e.year = e2.year+1


SELECT *
FROM t_Klara_Dvorakova_project_SQL_secondary_final;

DROP VIEW IF EXISTS view_dklarka_economy;



-- 1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 
SELECT 
	 year
	,industry 
	,wage 
	,wageLY 
	,CASE WHEN wage-wageLY > 0 THEN '+' ELSE '-' END AS LYDif
	,(wage - wageLY) AS YearDif
-- select distinct industry
-- select count(*) --420 
FROM t_Klara_Dvorakova_project_SQL_primary_final as p
WHERE 1=1
AND wage IS NOT NULL
AND wageLY IS NOT NULL
;


-- Průměrná mzda se někdy i snížila, hlavně v roce 2013 a nejčastěji klesala v odětví těžba (4 krát)


-- 2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

 SELECT 
 	 p.year
	,p.category 
	,p.FoodPrice
	,(SELECT AVG(p1.wage)
		FROM t_Klara_Dvorakova_project_SQL_primary_final as p1
		WHERE 1=1
		AND p1.year = p.year
		) as avgWage -- Poddotaz vrací průměrnou mzdu pro konkrétní rok
	,ROUND( (SELECT AVG(p1.wage)
		FROM t_Klara_Dvorakova_project_SQL_primary_final as p1
		WHERE 1=1
		AND p1.year = p.year
		)/p.FoodPrice,0) as foodForWage -- Tento poddotaz počítá, kolik jednotek dané potraviny lze koupit za průměrnou mzdu
 FROM t_Klara_Dvorakova_project_SQL_primary_final AS p
 WHERE 1=1
 AND (category = "Chléb konzumní kmínový" OR category = "Mléko polotučné pasterované")
 AND (year = 2006 OR year = 2018)
 ORDER BY year
;


-- Chleba je možné si koupit za průměrný plat 1 308 kg za 1. období (rok 2006) a za poslední období to je 1 363 kg (rok 2018). 
-- Mléka je možné si koupit za průměrný plat 1 460 l za 1. srovnatelné období (rok 2006) a za poslední srovnatelné období je možné si ho koupit 1 667 l (rok 2018)


-- 3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
SELECT 
	 p.category 
	,(SELECT p1.FoodPrice FROM t_Klara_Dvorakova_project_SQL_primary_final as p1 WHERE p1.year = 2006 AND p1.category = p.category) as first_price -- cena potravin v 1. období
	,(SELECT p2.FoodPrice FROM t_Klara_Dvorakova_project_SQL_primary_final as p2 WHERE p2.year = 2018 AND p2.category = p.category) as last_price -- cena potravin v posledním období
	,ROUND( 
	(SELECT p2.FoodPrice FROM t_Klara_Dvorakova_project_SQL_primary_final as p2 WHERE p2.year = 2018 AND p2.category = p.category)
	/
	(SELECT p1.FoodPrice FROM t_Klara_Dvorakova_project_SQL_primary_final as p1 WHERE p1.year = 2006 AND p1.category = p.category)
	,2) * 100.0 AS percantage -- výpočet procentuální změny mezi prvním a posledním obdobím
FROM t_Klara_Dvorakova_project_SQL_primary_final AS p
WHERE 1=1
AND p.FoodPrice IS NOT NULL
AND p.category != 'Jakostní víno bílé' -- vyřazeno, protože má data jen za 3 roky
GROUP BY p.category 
ORDER BY percantage

-- Cena cukr zdražuje nejpomaleji - dokonce zlevnil. Cena v roce 2006 byla 21,73 a v roce 2018 byla 15,75.

-- 4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

-- View pro meziroční nárůst wage
CREATE OR REPLACE VIEW view_dklarka_wage AS
SELECT 
	 p.year
	,AVG(p.wage) AS awgWage
	,AVG(p.wageLY) AS awgWageLY
	,(ROUND ((AVG(p.wage)) / (AVG(p.wageLY)), 4) * 100.0)-100.0 AS percentageWage -- výpočet meziročního procentuálního růstu mezd
FROM t_Klara_Dvorakova_project_SQL_primary_final as p 
WHERE 1=1
AND p.wageLY IS NOT NULL
GROUP BY p.year 
;

-- view pro meziroční nárůst foodPrice
CREATE OR REPLACE VIEW view_dklarka_food AS 
SELECT 
	 p.year 
	,AVG(p.FoodPrice) AS FoodPrice
	,AVG(p.FoodPriceLY) AS FoodPriceLY 
	,(ROUND(AVG(p.FoodPrice) / AVG(p.FoodPriceLY), 4) *100.0)-100.0 AS percentageFood -- výpočet meziročního procentuálního růstu cen potravin
FROM t_Klara_Dvorakova_project_SQL_primary_final as p
WHERE 1=1
AND p.FoodPriceLY IS NOT NULL
GROUP BY p.year
;

-- join podle roků
SELECT 
	 w.year
	,w.percentageWage 
	,f.percentageFood 
	,f.percentageFood - w.percentageWage AS difference
FROM view_dklarka_wage AS w
LEFT JOIN view_dklarka_food AS f ON w.year = f.year
WHERE 1=1
AND f.percentageFood IS NOT NULL 
;

-- Nikdy nebyl rozdíl mezi průměrnou mzdou a cenou potravin výrazně vyšší než 10 %. 
-- Nejvyšší nárůst cen potravin byl v roce 2017 a to o 9,63 %. 
-- Nejvyšší navýšení mezd bylo v roce 2018 o 7,72 %. 
-- Nejvyšší rozdíl mezi meziročním nárůstem cen potravin a mezd byl v roce 2013 a to o 6,59 %.


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

