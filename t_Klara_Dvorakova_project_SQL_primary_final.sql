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


