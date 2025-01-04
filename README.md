# DatovaAkademie_dklarka

---
Soubory projektu Datová akademie Engeto.

## Zadání projektu
Tento projekt je od Datové akademie Engeto a analyzuje různá data, hlavně co se týče změny mezd, potravin a HDP. Jeho hlavním úkolem je vyzkoušet si a zlepšit si moje schopnosti v SQL a také trochu v Excelu. 
Projekt je koncipovan tak, že byly potřeba vytvořit 2 tabulky. První obsahuje data o cenách potravin a výšku mezd. Druhá obsahuje změnu HDP v průběhu několik let u České republiky. Další částí byly výzkumné otázky, na které se 
odpovídalo pomocí dat z předchozích tabulek. Otázek bylo dohromady 5 a dole lze vidět detalnější popsání postupu při vytváření tabulek a odpovědí na otázky.

## Popis postupů
---
## Vytvoření tabulek

### Primární tabulka
Vytvoření primární tabulky byl jeden ze složitějších úkolů. Bylo potřeba, aby data v ní byla přehledná a nebyly v ní zbytečná data. prvně jsem začala tím, že jsem si vytvořila view pro payroll tabulku, abych siprvně ujasnila jaké data budou z ní potřeba.
Když jsem dělala tyto úpravy, tak jsem narazila na dilema, jestli použít fyzický nebo přepočtený kalkulace, ale nakonec jsem se rozhodla pro přepočtený, protože se do ní započítavají i částečné úvazky. Nakonec jsem k tomuto view join zbylé tabulky k payroll.
Jakmile bylo toto view hodoté, tak jsem ho join ještě jednou k sebe samému, protože jsem u něho chtěla ve výsledné tabulce vidět mzdy z předchozího roku. Následně jsem vytvořila další view, tentokrát k food price tabulce. U ní jsem také vynechala nedůležité 
informace a join tabulku kategorií potravin. A také jsem ho join ještě jednou k sebe samému, abych viděla cena za minulý rok. Naposled jsem spojila obě view k sobě pomocí UNION a metody řídké matice, abych vždycky mohla vzít ty data, které potřebuji.
To protože u metody řídké matice se u hodnoty, kterou nemám dá NULL a podzději, když budu potřebovat vybrat specifická data, tak napíšu jenom aby to NULL nebylo. Tabulka se jmenuje *t_Klara_Dvorakova_project_SQL_primary_final*.
---
### Sekundární tabulka
Vytovření sekundární tabulky byly jednodušší i proto, že tam bylo méně potřebných dat. Podle popisu projektu jsem usoudila, že budou pořeba vždy jenom data o ČR, což už na začátku výrazně snížilo počet řádků. Prvně jsem si zase vytvořila view, abych spojila
tabulky econimies a countries. Následně jsem vytvořila sekundární tabulku, kde jsem ještě join view k sebe samému join, abych měla informace k HDP i k předchozím letům. Tabulka se jmenuje *t_Klara_Dvorakova_project_SQL_secondary_final*.
---
## Výzkumné otázky
---
###Q1 Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 
Z přiloženéh selectu a Excel tabulky vyplývá, že průměrná mzda se někdy zvýšila a někdy zvýšila. Nejvíce se průměrné snížila v roce 2013. Nejčastěji klesala v odtvětví Těžba. Také lze vidět v přiložené Excel tabulce, že odvětní
Doprava a skladnování, Ostatní činnosti, Zdravotní a sociální péče a Zpracovatelský průmysl v letech jenom rostly a neklesaly.
---
###Q2 Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
První srovnatelné období je rok 2006 a poslední srovnatelné období je rok 2018. Z výsledných selectů vyplývá, že chleba je možné si koupit za průměrný plat 1 308 kg za rok 2006 a za rok 2018 to je 1 363 kg. 
A mléka je možné si koupit za průměrný plat 1 460 l za rok 2006 a za rok 2018 je možné si ho koupit 1 667 l.
---
###Q3 Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
U této otázky jsem si prvně určila, že to zase budu porovnávat za první a poslední srovnatelné období, nebyli znova rok 2006 a 2018. prvně jsem si tedi vzala ceny potravin za první a poslední období a následně jsem to převedla do procent. 
Naposled jsem výsledek seřadila podle těchto procent. Zárověň bylo potřeba vyřadit Jakostní víno bílé z celé otázky, protože máme o něm data jenom za 3 roky a tudíž by to mohlo zkreslovat data. Z těchto výsledků nám vyjde, že cukr zdražuje nejpomaleji a dokonce se zlevnil.
V roce 2006 stál 21,73 Kč a v roce 2018 stál 15,75 Kč.
---
###Q4 Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
U této otázky jsem si nejprve vytvořila view pro výpočet meziročníc změn mezd a cen potravin. Ty jsem následně join podle roků. Z těchto kroků mi vyšly následující výsledky. Ne v žádném roce nebyl meziroční cen potravin výazně vyšší než růst mezd. 
Nejvyšší nárůst cen potravin byl v roce 2017 a to o 9,63 %. Nejvyšší navýšení mezd bylo v roce 2018 o 7,72 %. ejvyšší rozdíl mezi meziročním nárůstem cen potravin a mezd byl v roce 2013 a to o 6,59 %.
---
###Q5 Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
Na tuto otázku bylo zdelake nejtěžší odpovědět. Abych mohla být co nejvíce přesná, tak jsem si přidala do tabulky t_Klara_Dvorakova_project_SQL_secondary_final HDP, které bylo 2 roky dozadu, protože abych mohli sledovat jeho vliv na změnu potravin a mezd
tak nemůžu brát pouze stejné rozmezí, ale i to předchozí. Dále jsem si znova vytvořila view pro průměrné ceny potravin, kde jsem znova vyhodila Jakostní víno bílé (protože je tam pořád jenom 3 roky). Následně jsem vytvořila view pro výpočet průměrné mzdy skrz roky.
Tyto 2 view jsem následně join k tabulce t_Klara_Dvorakova_project_SQL_secondary_final. V této tabulce jsem následně měla vypočítaná procenta u všech kategorií (průměrná mzda, průměrná cena potravin, HDP minulý rok a tento rok, HDP předminulý rok a tento rok).
Následně jsem tyto data vyexportovala do excelu, abych je mohla dát do grafu. V něm lze dobře vidět, že průměrná mzda kopíruje změnu HDP jak minulý a tento rok a předminulý a tento rok. U potravin to je složitější. 
Na začátku lze vidět, že potraviny to opisují stejně, ale v roce 2012 nastane zlom a potraviny mají větší procentuální nárůst než zbylé kategorie. Tento trend pokračuje do roku 2013 a následně se to znova stabilizuje. To, proč bylo takové zdražení může být na svědomí
několik faktorů. Například velká sucha dané roky, dražší energetika ... Jako hlavním důvodem může být zvýšení DHP na některé potraviny a tudíž jejich následné zdražení. Tudíž odpovědí na otázku je, že HDP má velký vliv na výšku mezd, ale už menší na ceny potravin, u
kterých je několik dalších faktorů.