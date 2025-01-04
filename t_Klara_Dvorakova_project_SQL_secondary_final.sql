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

