-- =================================================================
-- Name: IDS Projekt - SQL
-- Description: School Database Systems project
-- Authors: Andrej Nano (xnanoa00)
--          Peter Marko (xmarko15)
-- Repository: https://github.com/andrejnano/IDS-projekt
-- =================================================================

/*
    Zadanie projektu:
    https://www.fit.vutbr.cz/study/courses/IDS/private/projekt.xhtml

    SQL Style Guide:
    http://www.sqlstyle.guide/
*/

-- =================================================================
-- [x] [1/5] ERD + USE CASE
-- =================================================================
    -- NO SCRIPT PDF odovzdane


-- =================================================================
-- [ ] [2/5] SQL skript pro vytvoření základních objektů schématu
-- =================================================================
/*Delete tables*/
DROP TABLE customer CASCADE CONSTRAINTS;
DROP TABLE reservation CASCADE CONSTRAINTS;
DROP TABLE ticket CASCADE CONSTRAINTS;
DROP TABLE seat CASCADE CONSTRAINTS;
DROP TABLE flight CASCADE CONSTRAINTS;
DROP TABLE plane CASCADE CONSTRAINTS;
DROP TABLE airlane CASCADE CONSTRAINTS;

CREATE TABLE customer (
    id_customer NUMBER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email_adress VARCHAR(100) NOT NULL,
    adress_streeet VARCHAR(100) NOT NULL,
    adress_town VARCHAR(100) NOT NULL,
    adress_post_code NUMBER NOT NULL,
    adress_state VARCHAR(100) NOT NULL
);

CREATE TABLE reservation (
-- rodne cislo ten regex som skopiroval z nejakeho stareho projektu
    personal_id NUMBER PRIMARY KEY CHECK(REGEXP_LIKE(personal_id,'[0-9][0-9](0|1|2|3|5|6|7|8)[0-9][0-3][0-9][0-9]{3,4}')),
    total_cost NUMBER NOT NULL,
    state NUMBER NOT NULL,
	date_of_creation TIMESTAMP NOT NULL
);

CREATE TABLE ticket (
    ticket_id NUMBER NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
	cost NUMBER NOT NULL,
    checked_in NUMBER CHECK(REGEXP_LIKE(checked_in,'[0-1]'))
);
CREATE TABLE seat (
    seat_id NUMBER NOT NULL PRIMARY KEY,
    seat_cost NUMBER NOT NULL,
    seat_class NUMBER NOT NULL
);

CREATE TABLE flight (
    flight_id NUMBER NOT NULL PRIMARY KEY,
    start_airport VARCHAR(100) NOT NULL,
    destination_airport VARCHAR(100) NOT NULL,
    time_of_departure TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL
);

CREATE TABLE airlane (
    airlane_id NUMBER NOT NULL PRIMARY KEY,
    nationality VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    hub_airport VARCHAR(100) NOT NULL
);

-- =================================================================
-- [ ] [3/5] SQL skript s několika dotazy SELECT
-- =================================================================


-- =================================================================
-- [ ] [4/5] SQL skript pro vytvoření pokročilých objektů schématu
-- =================================================================


-- =================================================================
-- [ ] [5/5] Dokumentace popisující finální schéma databáze
-- =================================================================
