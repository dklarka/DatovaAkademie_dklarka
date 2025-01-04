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