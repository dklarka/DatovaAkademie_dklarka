# DatovaAkademie_dklarka

---

## Soubory projektu Datová akademie Engeto.

### Zadání projektu
Tento projekt je od Datové akademie Engeto a analyzuje různá data, hlavně co se týče změny mezd, potravin a HDP. Jeho hlavním úkolem je vyzkoušet si a zlepšit si moje schopnosti v SQL a také trochu v Excelu. Projekt je koncipován tak, že byly potřeba vytvořit 2 tabulky. První obsahuje data o cenách potravin a výši mezd. Druhá obsahuje změnu HDP v průběhu několika let u České republiky. Další částí byly výzkumné otázky, na které se odpovědělo pomocí dat z předchozích tabulek. Otázek bylo dohromady 5 a dole lze vidět podrobnější popsání postupu při vytváření tabulek a odpovědí na otázky.

---

## Popis postupů

### Vytvoření tabulek

#### Primární tabulka
Vytvoření primární tabulky byl jeden ze složitějších úkolů. Bylo potřeba, aby data v ní byla přehledná a zároveň nebyla zbytečná. Prvně jsem začala tím, že jsem si vytvořila *view* pro *payroll* tabulku, abych si prvně ujasnila, jaké data budou z ní potřeba.  
Když jsem dělala tyto úpravy, tak jsem narazila na dilema, jestli použít fyzický nebo přepočtený kalkulace, ale nakonec jsem se rozhodla pro přepočtený, protože se do ní započítávají i částečné úvazky. Nakonec jsem k tomuto *view* připojila zbylé tabulky k *payroll*.  
Jakmile bylo toto *view* hotové, tak jsem ho spojila ještě jednou sám se sebou, protože jsem chtěla ve výsledné tabulce vidět mzdy z současného a zároveň předchozího roku. Následně jsem vytvořila další *view*, tentokrát k *food price* tabulce. U ní jsem také vynechala nedůležité informace a připojila k ní tabulku kategorií potravin. A také jsem ji připojila ještě jednou k sobě samé, abych viděla ceny za minulý rok.  
Naposledy jsem spojila obě *view* k sobě pomocí *UNION* a metody řídké matice, abych vždycky mohla vzít ta data, která potřebuji.  
To proto, že u metody řídké matice se u hodnoty, kterou nemám, dá *NULL* a později, když budu potřebovat vybrat specifická data, tak napíšu jenom, aby to *NULL* nebylo. Díky této technice pak v budoucnu lépe vyberu, jestli chci pracovat s cenami potravin nebo výše mezd. 
Tabulka se jmenuje `t_Klara_Dvorakova_project_SQL_primary_final`.

#### Sekundární tabulka
Vytvoření sekundární tabulky bylo jednodušší i proto, že obsahuje méně potřebných dat. Podle popisu projektu jsem usoudila, že budou potřeba vždy jenom data o ČR, což už na začátku výrazně snížilo počet řádků. Prvně jsem si zase vytvořila *view*, abych spojila tabulky *economies* a *countries*. Následně jsem vytvořila sekundární tabulku, kde jsem ještě připojila *view* k sobě samému, abych měla informace k HDP i k předchozím letům.  
Tabulka se jmenuje `t_Klara_Dvorakova_project_SQL_secondary_final`.

---

## Výzkumné otázky

### Q1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
Z přiloženého *selectu* a Excel tabulky vyplývá, že průměrná mzda se někdy zvýšila a někdy klesla. Nejvíce se průměrné mzdy snížily v roce 2013. Nejčastěji klesala v odvětví Těžba. Také lze vidět v přiložené Excel tabulce, že odvětví Doprava a skladování, Ostatní činnosti, Zdravotní a sociální péče a Zpracovatelský průmysl v letech pouze rostla a neklesala.

### Q2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
První srovnatelné období je rok 2006 a poslední srovnatelné období je rok 2018. Z výsledných *selectů* vyplývá, že chleba je možné si koupit za průměrný plat 1 308 kg za rok 2006 a za rok 2018 to je 1 363 kg. A mléka je možné si koupit za průměrný plat 1 460 l za rok 2006 a za rok 2018 je možné si ho koupit 1 667 l.

### Q3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
U této otázky jsem si prvně určila, že to zase budu porovnávat za první a poslední srovnatelné období, tedy roky 2006 a 2018. Prvně jsem si vzala ceny potravin za první a poslední období a následně jsem pomocí procent zjistila, jak se ceny změnily. Nakonec jsem výsledek seřadila podle těchto procent. Zároveň bylo potřeba vyřadit Jakostní víno bílé z celé otázky, protože máme o něm data jenom za 3 roky, což by mohlo zkreslovat data.  
Z těchto výsledků nám výjde, že cukr zdražuje nejpomaleji a dokonce se zlevnil. V roce 2006 stál 21,73 Kč a v roce 2018 stál 15,75 Kč.

### Q4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
U této otázky jsem si nejprve vytvořila *view* pro výpočet meziroční změn mezd a cen potravin. Meziroční změny jsem vyjádřila pomocí procent. Tyto view jsem následně spojila k sobě pomocí společných roků. Z těchto kroků jsem došla k následujícím výsledkům:  
Ne, v žádném roce nebyl meziroční nárůst cen potravin výrazně vyšší než růst mezd. Nejvyšší nárůst cen potravin byl v roce 2017 a to o 9,63 %. Nejvyšší navýšení mezd bylo v roce 2018 o 7,72 %. Nejvyšší rozdíl mezi meziročním nárůstem cen potravin a mezd byl v roce 2013 a to o 6,59 %.

### Q5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
Na tuto otázku bylo nejtěžší odpovědět. Abych mohla být co nejvíce přesná, přidala jsem do tabulky `t_Klara_Dvorakova_project_SQL_secondary_final` HDP, které bylo 2 roky dozadu. To jsem udělala, protože abych mohla sledovat jeho vliv na změnu cen potravin a výšku mezd, nemůžu brát pouze stejné rozmezí, ale i to předchozí.  
Dále jsem si znovu vytvořila *view* pro průměrné ceny potravin, kde jsem znovu vyhodila Jakostní víno bílé (protože obsahuje data jenom za 3 roky). Následně jsem vytvořila *view* pro výpočet průměrné mzdy skrz roky.  
Tyto dvě *view* jsem následně spojila k tabulce `t_Klara_Dvorakova_project_SQL_secondary_final`. V této tabulce jsem poté měla vypočítané procentuální meziroční změny u všech kategorií (průměrná mzda minulý rok a současný rok, průměrná cena potravin minulý rok a současný rok, HDP minulý rok a současný rok, HDP předminulý rok a minulý rok ).  
Následně jsem tyto data vyexportovala do Excelu, abych je mohla dát do grafu. V něm lze dobře vidět, že průměrná mzda kopíruje změnu HDP mezi současným a minulým rokem. Výkyvy změn v minulém a předminulém roce nemají zásadní vliv na mzdy ani ceny potravin, větší vliv mají změny minulého a současného roku.  
U potravin to je složitější. Na začátku lze vidět, že potraviny to opisují stejně, ale v roce 2012 nastane zlom a potraviny mají větší procentuální nárůst než zbylé kategorie. Tento trend pokračuje do roku 2013 a následně se to znovu stabilizuje.  
To, proč došlo k takovému zdražení, může mít na svědomí několik faktorů. Například velká sucha v daném roce, dražší energie atd. Jako hlavní důvod může být zvýšení DPH na některé potraviny v roce 2012 a tudíž jejich následné zdražení.  
Tudíž odpovědí na tuto otázku je, že HDP má velký vliv na výšku mezd, ale již menší na ceny potravin.
