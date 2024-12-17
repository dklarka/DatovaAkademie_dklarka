-- Tabulka s obecnými informacemi o zemích světa
SELECT * FROM countries AS c
WHERE country LIKE '%Cz%';

-- Tabulka s daty o ekonomice států
SELECT * FROM economies AS e 
WHERE country LIKE '%Cz%';

CREATE OR REPLACE VIEW view_dklarka_economy AS
SELECT 
	 e.GDP
	,e.`year` 
FROM countries as c 
LEFT JOIN economies as e ON c.country = e.country 
WHERE 1=1
AND c.country LIKE '%Cz%'
AND e.GDP IS NOT NULL
ORDER BY e.year ASC;

CREATE OR REPLACE TABLE t_Klara_Dvorakova_project_SQL_secondary_final AS 
SELECT
	 e.year
	,e.GDP
	-- ,e2.year
	,e2.GDP AS GDPLY
FROM view_dklarka_economy AS e
LEFT JOIN view_dklarka_economy AS e2 ON e.year = e2.`year`+1
WHERE 1=1
AND e2.year IS NOT NULL;


SELECT *
FROM t_Klara_Dvorakova_project_SQL_secondary_final;

DROP VIEW IF EXISTS view_dklarka_economy;

