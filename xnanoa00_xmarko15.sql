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
DROP TABLE flight_ticket CASCADE CONSTRAINTS;
DROP TABLE flight_seat CASCADE CONSTRAINTS;
DROP TABLE flight CASCADE CONSTRAINTS;
DROP TABLE airplane CASCADE CONSTRAINTS;
DROP TABLE airline CASCADE CONSTRAINTS;
DROP TABLE search CASCADE CONSTRAINTS;
DROP TABLE flight_realised CASCADE CONSTRAINTS;


CREATE TABLE customer (
    customer_id NUMBER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email_adress VARCHAR(100) NOT NULL,
    address_street VARCHAR(100) NOT NULL,
    address_town VARCHAR(100) NOT NULL,
    address_post_code NUMBER NOT NULL,
    address_state VARCHAR(100) NOT NULL
);

CREATE TABLE reservation (
-- rodne cislo ten regex som skopiroval z nejakeho stareho projektu
    reservation_id NUMBER PRIMARY KEY CHECK(REGEXP_LIKE(reservation_id,'[0-9][0-9](0|1|2|3|5|6|7|8)[0-9][0-3][0-9][0-9]{3,4}')),
    total_cost NUMBER NOT NULL,
    payment_status NUMBER NOT NULL,
	creation_date TIMESTAMP NOT NULL,
    creator NUMBER,
    CONSTRAINT fk_creator FOREIGN KEY (creator) REFERENCES customer (customer_id)
);


CREATE TABLE airline (
    --TODO: airline_code instead of id ; https://gist.github.com/yectep/4372d1166a192d5e9754
    airline_id NUMBER NOT NULL PRIMARY KEY,
    nationality VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    hub_airport VARCHAR(100) NOT NULL
);

CREATE TABLE airplane (
    airplane_id NUMBER NOT NULL PRIMARY KEY,
    production_year NUMBER CHECK(REGEXP_LIKE(production_year,'[0-9][0-9][0-9][0-9]')),
    producer VARCHAR(100),
    model VARCHAR(100),
    seats_1class NUMBER NOT NULL,
    seats_2class NUMBER NOT NULL,
    seats_3class NUMBER NOT NULL,
    airline NUMBER, --TODO:add better naming, can't be owner -> reserved keyword
    CONSTRAINT fk_airline FOREIGN KEY (airline) REFERENCES airline (airline_id)    
);

CREATE TABLE flight (
    -- TODO: flight code instead of ID, https://academe.co.uk/2014/01/validating-flight-codes/
    -- Aviation regex toolkit https://gist.github.com/yectep/4372d1166a192d5e9754
    flight_id NUMBER NOT NULL PRIMARY KEY,
    origin_airport VARCHAR(100) NOT NULL,
    destination_airport VARCHAR(100) NOT NULL,
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    airplane NUMBER,
    CONSTRAINT fk_airplane FOREIGN KEY (airplane) REFERENCES airplane (airplane_id)
);

CREATE TABLE search (
    search_id NUMBER NOT NULL PRIMARY KEY,
    searched_by NUMBER,
    CONSTRAINT fk_searched_by FOREIGN KEY (searched_by) REFERENCES customer (customer_id),
    flight_searched NUMBER,
    CONSTRAINT fk_flight_searched FOREIGN KEY (flight_searched) REFERENCES flight (flight_id)
);

CREATE TABLE flight_realised (
    realisation_id NUMBER NOT NULL PRIMARY KEY,
    realised_by NUMBER,
    CONSTRAINT fk_realised_by FOREIGN KEY (realised_by) REFERENCES airline (airline_id),
    realised_flight NUMBER,
    CONSTRAINT fk_realised_flight FOREIGN KEY (realised_flight) REFERENCES flight (flight_id)
);


CREATE TABLE ticket (
    ticket_id NUMBER NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
	cost NUMBER NOT NULL,
    check_in_status NUMBER CHECK(REGEXP_LIKE(checked_in,'[0-1]')),
    reserved_by NUMBER,
    CONSTRAINT fk_reserved_by FOREIGN KEY (reserved_by) REFERENCES reservation (reservation_id)
);

CREATE TABLE seat (
    seat_id NUMBER NOT NULL PRIMARY KEY,
    seat_cost NUMBER NOT NULL,
    seat_class NUMBER NOT NULL,
    seat_reserved_by NUMBER NOT NULL,
    CONSTRAINT fk_seat_reserved_by FOREIGN KEY (seat_reserved_by) REFERENCES reservation (reservation_id),
    at_flight NUMBER NOT NULL,
    CONSTRAINT fk_at_flight FOREIGN KEY (at_flight) REFERENCES flight (flight_id),
    offered_by NUMBER NOT NULL,
    CONSTRAINT fk_offered_by FOREIGN KEY (offered_by) REFERENCES airline (airline_id)
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
