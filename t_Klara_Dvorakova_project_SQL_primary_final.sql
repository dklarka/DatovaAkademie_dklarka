-- Mzdy v různých odvětví
SELECT id, value, value_type_code, unit_code, calculation_code, industry_branch_code, payroll_year, payroll_quarter FROM data_academy_2024_09_26.czechia_payroll;

-- Číselník fyzický/přepočtený
SELECT code, name FROM data_academy_2024_09_26.czechia_payroll_calculation;

-- Číselník název odvětví Zemědělství, lesnictví, rybářství/Těžba a dobývání/..
SELECT code, name FROM data_academy_2024_09_26.czechia_payroll_industry_branch;

-- Číselník typ hodnoty  tis. osob (tis. os.) / Kč
SELECT code, name FROM data_academy_2024_09_26.czechia_payroll_unit;

-- Číselník typ hodnoty Průměrný počet zaměstnaných osob/Průměrná hrubá mzda na zaměstnance
SELECT code, name FROM data_academy_2024_09_26.czechia_payroll_value_type;


-- MZDY MOJE UPRAVA
CREATE OR REPLACE VIEW view_dklarka_payroll AS
SELECT 
	Avg(coalesce(p.value,0)) AS wage
	-- ,p.value_type_code
	-- ,pvt.name as value_type_code
	-- ,p.unit_code
	-- ,pu.name as unit_code
	-- ,p.calculation_code -- VAZBA na czechia_payroll_calculation
	-- ,pcal.name as calculation_code
	-- ,p.industry_branch_code
	,CASE WHEN pin.name IS NULL THEN '*N/A' ELSE pin.name END as industry
	,p.payroll_year as year
	-- ,p.payroll_quarter
-- select  *
-- select count(*) -- 6880->3440
-- select distinct pvt.name
FROM czechia_payroll AS p -- p=payroll
LEFT JOIN czechia_payroll_calculation AS pcal ON p.calculation_code = pcal.code
LEFT JOIN czechia_payroll_industry_branch as pin ON p.industry_branch_code = pin.code 
-- LEFT JOIN czechia_payroll_unit as pu ON p.unit_code = pu.code 
LEFT JOIN czechia_payroll_value_type as pvt ON p.value_type_code = pvt.code 
WHERE 1=1
 	-- and p.value IS  NULL
	-- AND industry_branch_code IS  NULL 
 AND pvt.name != 'Průměrný počet zaměstnaných osob'
 AND pcal.name = 'přepočtený'
 	-- AND calculation_code = 200
 	-- and payroll_year =2000 and payroll_quarter=1
-- ORDER BY payroll_year, and payroll_quarter=1
 GROUP BY payroll_year, pcal.name, pin.name 
 ORDER BY pin.name, payroll_year, payroll_quarter
 -- SELECT * FROM view_payroll
;
CREATE OR REPLACE VIEW view_dklarka_payroll_final AS
SELECT 
	 p.year
	,p.industry
	,p.wage
	,p2.wage AS wageLY
-- select count(*) -- 440
FROM view_payroll AS p
LEFT JOIN view_payroll AS p2 ON p.year = p2.year+1 AND p.industry = p2.industry
;



CREATE OR REPLACE VIEW view_dklarka_foodprice AS
SELECT 
	 YEAR(date_from) AS year
	-- ,date_to
	-- ,category_code		-- SELECT code, name, price_value, price_unit FROM czechia_price_category;
	,prc.name AS category
	,prc.price_value
	,prc.price_unit
	-- ,region_code -- SELECT code, name FROM czechia_region;
	,AVG(coalesce(value,0)) AS FoodPrice
FROM czechia_price AS pr
LEFT JOIN czechia_price_category AS prc ON pr.category_code = prc.code 
WHERE 1=1
	-- AND YEAR(date_from) != YEAR(date_to)
GROUP BY prc.name, YEAR(date_from),prc.price_value,prc.price_unit
;

CREATE OR REPLACE VIEW view_dklarka_foodprice_final AS
SELECT 
	 f.year
	,f.category
	,f.price_value
	,f.price_unit
	,f.FoodPrice
	,f2.FoodPrice AS FoodPriceLY
-- select *
-- select count(*) -- 342 !Pocet se nesmi joinem zvysit
FROM view_foodprice AS f
LEFT JOIN view_foodprice AS f2 ON f.year = f2.year+1 AND f.category = f2.category
;


-- řídká matice!!!
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
FROM view_payroll_final as vp
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
FROM view_foodprice_final as vf 
;


-- tabulka obsahuje po rocích 1. mzdy za odvětví 2. Ceny kategorií potravin. Je to řídká matice. 
SELECT * FROM t_Klara_Dvorakova_project_SQL_primary_final
 
DROP VIEW IF EXISTS view_dklarka_payroll;
DROP VIEW IF EXISTS view_dklarka_payroll_final;
DROP VIEW IF EXISTS view_dklarka_foodprice;
DROP VIEW IF EXISTS view_dklarka_foodprice_final;

/*
DROP VIEW IF EXISTS view_payroll;
DROP VIEW IF EXISTS view_payroll_final;
DROP VIEW IF EXISTS view_foodprice;
DROP VIEW IF EXISTS view_foodprice_final;
*/
