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