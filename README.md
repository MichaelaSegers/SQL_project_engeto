# SQL_project_engeto

Tvorba první tabulky t_michaela_segers_SQL_primary_final

Do tabulky budu chtít vložit následující sloupce, které potřebuji znát pro zodpovězení zadaných otázek.
Z tabulky payroll:
	- rok
	- value (průměrná mzda)
	- industry branch (odvětví)
Z tabulky prices:
	- rok
	- value (průměrná cena)
	- category code (produkt)

Všechna data budu zjišťovat za společné období obou tabulek, tedy 2006-2018, toto ale nijak v této fází nefiltruji, roky se samy takto definují, až později spojím data z obou tabulek pomocí inner join právě přes hodnotu roků.

Prvním skriptem tedy vyberu požadovaná data z tabulky payroll. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L15
Tabulka payroll obsahuje data po kvartálech, potřebuji tedy získat průměrnou mzdu za roky.
Počítám s calculation_code 200 pro mzdy přepočtené na celé úvazky.

Druhým skriptem vyberu požadovaná data z tabulky prices. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L25
Protože v celém projektu pracuji pouze s roky, data seskupím podle roku počátku měření.
Budu zodpovídat dotazy za celou republiku bez ohledu na regiony, region_code tedy volím NULL.

Na základě předchozích skriptů jsem si vytvořila na localhost dočasné tabulky, ze kterých pak vytvořím tabulku finální. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L34
Oproti předchozím selectům jsem ještě přidala jmenné názvy odvětví a produktů.

Tvořím finální tabulku pomocí inner join, abych vyfiltrovala pouze společné roky. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L66

Na Engeto serveru nemám povolení tvořit dočasné tabulky, finální tabulku tedy můžu vytvořit dvěma alternativními způsoby.

Buď přes common table expression, kde 3 kroky z původního způsobu spojím do jednoho. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L74

Anebo pomocné tabulky payroll a prices vytvořím jako standardní, ne dočasné. A po vytvoření finální tabulky je smažu. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L107

Tvorba druhé tabulky (další země)

V tabulce economies chybí poměrně hodně dat pro GDP a GINI za různé země v různých letech.

1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Potřebuji porovnat mzdy vždy s předchozím rokem. Protože v tabulce mám jako nejstarší rok v tabulce 2006, za tento rok mi bude růst vycházet NULL, protože nemám s čím porovnávat (pouze pokud bych importovala data z původní tabulky payroll v databázi za rok 2005).
U roku 2006 v této otázce proto nehodnotím růst, pouze využiji data o mzdách.
https://github.com/MichaelaSegers/SQL_project_engeto/blob/4e04224488debf88f68293e56ada5054467d71b5/SQL_project.sql#L207

V tomto selectu vidím konkrétní meziroční poklesy v jednotlivých odvětvích od největších poklesů mezd.

Můžeme také zhodnotit průměrné meziroční pohyby mezd, tedy pro jednotlivá odvětví za celé období.
https://github.com/MichaelaSegers/SQL_project_engeto/blob/4e04224488debf88f68293e56ada5054467d71b5/SQL_project.sql#L243

Odpověď na otázku č.1:
V průběhu let 2006-2018 došlo k největšímu meziročnímu poklesu mezd v:
	- peněžnictví a pojišťovnictví v roce 2013 (-8,83%)
	- výrobě a rozvodu elektřiny a plynu, tepla a klimatiz. vzduchu v roce 2013 (-4,44%)
	- těžbě a dobývání v roce 2013 (-3,24%)

Naopak největší meziroční růst mezd proběhl v:
	- výrobě a rozvodu elektřiny a plynu, tepla a klimatiz. vzduchu v roce 2008 (13,76%)
	- těžbě a dobývání v roce 2008 (13,75%)
	- profesní, vědecké a technické činnosti v roce 2008 (12,41%)

Za celkové období 2006-2018 je ve všech odvětvích průměrný růst mezd pozitivní. Nejnižší průměrný meziroční procentuální růst zaznamenalo peněžnictví a pojišťovnictví (2,75%), nejvyšší naopak zdravotní a sociální péče (4,95%).

2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

Za průměrné roční mzdy napříč odvětvími bylo možné pořídit (zaokrouhleno dolů na celá čísla):
	- 1353 l mléka v roce 2006
	- 1211 kg chleba v roce 2006
	- 1616 l mléka v roce 2018
	- 1321 kg chleba v roce 2018

Pro zajímavost je ještě možné se podívat, jak se toto liší v různých odvětvích.
<link>

3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Data za bílé víno jsou dostupná pouze od roku 2015.

Nejméně zdražila rajská jablka mezi lety 2006-2007 (zlevnění o 30,28%), průměrně nejpomaleji za celé období měření (tedy 2006-2018, ale v případě bílého vína měřeno pouze 2015-2018) zdražil cukr krystalový (dokonce meziročně průměrně zlevňoval o 1,92%).
<link>

Pro kontrolu jsem si zobrazila ceny cukru v letech 2006 a 2018.
<link>

4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Jednotlivé produkty měly meziroční průměrný růst cen často výrazně vyšší než průměrný meziroční růst mezd.
<link>

Průměrný růst cen všech produktů nebyl nikdy o 10% vyšší než průměrný růst mezd - nejvyšší rozdíl byl v roce 2013 o 6,14%.
<link>

5.