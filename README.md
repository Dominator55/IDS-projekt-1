# IDS 2018 Projekt v SQL

> [Zadanie projektu](www.fit.vutbr.cz/study/courses/IDS/private/projekt.xhtml)
> 
> [Stránka predmetu IDS](www.fit.vutbr.cz/study/courses/IDS/private/index.html)



## Popis

Cielom riešeného projektu je návrh a implementácia relačnej databázy na zvolenú tému.
Projekt sestává ze pěti částí, které se odevzdávají ve stanovených termínech do WISu:
Datový model (ERD) a model případů užití.

- [x] **Datový model (ER diagram)** zachycující strukturu dat, resp. požadavky na data v databázi, vyjádřený jako diagram tříd v notaci UML nebo jako ER diagram v tzv. Crow's Foot notaci a model případů užití vyjádřený jako diagram případů užití v notaci UML reprezentující požadavky na poskytovanou funkcionalitu aplikace používající databázi navrženého datového modelu. Datový model musí obsahovat alespoň jeden vztah generalizace/specializace (tedy nějakou entitu/třídu a nějakou její specializovanou entitu/podtřídu spojené vztahem generalizace/specializace; vč. použití správné notace vztahu generalizace/specializace v diagramu).

- [ ] **SQL skript pro vytvoření základních objektů schématu databáze** - SQL skript vytvářející základní objekty schéma databáze, jako jsou tabulky vč. definice integritních omezení (zejména primárních a cizích klíčů), a naplňující vytvořené tabulky ukázkovými daty. Vytvořené schéma databáze musí odpovídat datovému modelu z předchozí části projektu a musí splňovat upřesňující požadavky zadání.

- [ ] **SQL skript s několika dotazy SELECT** – SQL skript, který nejprve vytvoří základní objekty schéma databáze a naplní tabulky ukázkovými daty (stejně jako skript v bodě 2) a poté provede několik dotazů SELECT dle upřesňujících požadavků zadání.

- [ ] **SQL skript pro vytvoření pokročilých objektů schématu databáze** – SQL skript, který nejprve vytvoří základní objekty schéma databáze a naplní tabulky ukázkovými daty (stejně jako skript v bodě 2), a poté zadefinuje či vytvoří pokročilá omezení či objekty databáze dle upřesňujících požadavků zadání. Dále skript bude obsahovat ukázkové příkazy manipulace dat a dotazy demonstrující použití výše zmiňovaných omezení a objektů tohoto skriptu (např. pro demonstraci použití indexů zavolá nejprve skript EXPLAIN PLAN na dotaz bez indexu, poté vytvoří index, a nakonec zavolá EXPLAIN PLAN na dotaz s indexem; pro demostranci databázového triggeru se provede manipulace s daty, která vyvolá daný trigger; atp.).

- [ ] **Dokumentace popisující finální schéma databáze** – Dokumentace popisující řešení ze skriptu v bodě 4 vč. jejich zdůvodnění (např. popisuje výstup příkazu EXPLAIN PLAN bez indexu, důvod vytvoření zvoleného indexu, a výstup EXPLAIN PLAN s indexem, atd.).
Všechny odevzdávané SQL skripty musí být určené pro systém řízení báze dat (SŘBD) Oracle 12c a musí umožňovat opakované volání, tedy odstranění a opětovné vytvoření, nebo rovnou přepsání, objektů v databázi a jejich dat (je v pořádku, když při prvním volání skriptu proběhnou neúspěšné pokusy o odstranění neexistujících databázových objektů).

Část projektu s diagramy a část projektu s dokumentací se odevzdávájí vždy jako jeden PDF soubor. Části projektu s SQL skripty se odevzdávají jednotlivě vždy v jednom souboru s prostým textem v kódování znaků UTF-8.



## Zvolená téma

### 37. Rezervace letenek (z minuleho roka, podla toho som to robil)

Vaším úkolem je navrhnout webovou aplikaci pro rezervaci letenek. Systém musí uživateli umožnit specifikovat požadavek pomocí místa odletu a příletu, data, času, třídy, letecké společnosti apod. Jedno letadlo může létat na více letech, stejně tak mezi dvěmi destinacemi může létat více letadel různých společností. Zákazník si rezervuje letenku, která může být na několik letů, i různých společností (např. letenka Praha -> San Francisco s lety Praha -> Londýn ČSA, Londýn -> San Francisco British Airways). Systém musí umožnit klientovi tisk letového itineráře, který obsahuje informace o dobách příletů a odletů na jednotlivých letištích. Každý typ letadla má různý počet sedadel a jejich rozvržení do tříd. Nemodelujte jednotlivá sedadla. Rezervací může klient zamluvit i více míst v jednom letu. Technická mezipřistání modelovat nemusíte. Systém musí evidovat, která společnost kdy, odkud a kam létá. Cena sedadla v dané třídě může být u každé společnosti jiná, cena letenky je dána součtem cen všech rezervovaných sedadel na všech letech. Pokud klient rezervovanou letenku včas nezaplatí, rezervace se z databáze smaže.



[Zadania projektov](https://www.fit.vutbr.cz/study/courses/IDS/private/projekt.xhtml#temata) <--



## Užitočné materiály a nástroje



**Prednasky**

[Transformacia ERD -> schema relacnej DB](https://www.fit.vutbr.cz/study/courses/IDS/private/prednasky/4_transformaceERD.pdf)

[Jazyk SQL](https://www.fit.vutbr.cz/study/courses/IDS/private/prednasky/5_jazyky.pdf)

[Priklad "banka_CREATE.sql"](https://www.fit.vutbr.cz/study/courses/IDS/private/prednasky/SQL/banka_CREATE.sql)



##### SQL + PL/SQL

[10 easy steps to a complete understanding of SQL](https://blog.jooq.org/2016/03/17/10-easy-steps-to-a-complete-understanding-of-sql/)

[SQL Cheatsheet](http://files.zeroturnaround.com/pdf/zt\_sql\_cheat_sheet.pdf) & [cely clanok](https://zeroturnaround.com/rebellabs/sql-cheat-sheet/)

[SQL Style Guide](http://www.sqlstyle.guide/)

[PL/SQL Quick Reference](https://umanitoba.ca/computing/ist/internal/admin\_sys/project\_review/media/Oracle\_PLSQL\_Quick\_Reference\_Card.pdf)



**Official ORACLE documentation**

[Oracle Database](https://docs.oracle.com/database/121/index.htm)

[Database SQL Language Reference](https://docs.oracle.com/database/121/SQLRF/toc.htm)

[Database PL/SQL Language Reference](https://docs.oracle.com/database/121/LNPLS/toc.htm)

[SQL Developer User's Guide](https://docs.oracle.com/database/121/RPTUG/intro.htm#RPTUG10000)



**Videa/Tutorials**

[Learning PL/SQL programming](https://www.youtube.com/watch?v=xofpqdU3cD4)

[PL/SQL Oracle tutorial, Oracle introduction, PL/SQL basics](https://www.youtube.com/watch?v=9RlxvHMg9PI)


**...**

[SQL "JOINS"](https://blog.jooq.org/2016/07/05/say-no-to-venn-diagrams-when-explaining-joins/)

[Different ways to join tables in sql](https://blog.jooq.org/2017/01/12/a-probably-incomplete-comprehensive-guide-to-the-many-different-ways-to-join-tables-in-sql/)

["True Order" of SQL operations](https://blog.jooq.org/2016/12/09/a-beginners-guide-to-the-true-order-of-sql-operations/)

[SQL Tricks And Tuning](https://blog.jooq.org/sql/)



[Kreslenie diagramov - draw.io](https://www.draw.io/)
