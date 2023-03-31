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

Druhým skriptem vyberu požadovaná data z tabulky prices. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L25
Protože v celém projektu pracuji pouze s roky, data seskupím podle roku počátku měření.
Budu zodpovídat dotazy za celou republiku bez ohledu na regiony, region_code tedy volím NULL.

Na základě předchozích skriptů jsem si vytvořila na localhost dočasné tabulky, ze kterých pak vytvořím tabulku finální. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L34
Oproti předchozím selectům jsem ještě přidala jmenné názvy odvětví a produktů.

Tvořím finální tabulku pomocí inner join, abych vyfiltrovala pouze společné roky. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L66

Na Engeto serveru nemám povolení tvořit dočasné tabulky, finální tabulku tedy můžu vytvořit dvěma alternativními způsoby.

Buď přes common table expression, kde 3 kroky z původního způsobu spojím do jednoho. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L74

Anebo pomocné tabulky payroll a prices vytvořím jako standardní, ne dočasné. A po vytvoření finální tabulky je smažu. https://github.com/MichaelaSegers/SQL_project_engeto/blob/14b4feaa868a7139fd07b0c625ad8ae4fe76e4ac/SQL_project.sql#L107