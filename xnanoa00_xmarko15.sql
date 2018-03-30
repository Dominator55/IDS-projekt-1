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

    Regexes (AvReg: The Aviation RegEx Match Toolkit)
    https://gist.github.com/yectep/4372d1166a192d5e9754
*/

-- =================================================================
-- [x] [1/5] ERD + USE CASE
-- =================================================================
    -- NO SCRIPT PDF odovzdane


-- =================================================================
-- [ ] [2/5] SQL skript pro vytvoření základních objektů schématu
-- =================================================================

/* DELETE TABLES for CLEAN START */

DROP TABLE customers        CASCADE CONSTRAINTS;
DROP TABLE reservations     CASCADE CONSTRAINTS;
DROP TABLE flight_tickets   CASCADE CONSTRAINTS;
DROP TABLE flights          CASCADE CONSTRAINTS;
DROP TABLE airplanes        CASCADE CONSTRAINTS;
DROP TABLE airports         CASCADE CONSTRAINTS;
DROP TABLE airlines         CASCADE CONSTRAINTS;
DROP TABLE passengers       CASCADE CONSTRAINTS;
DROP TABLE search_records   CASCADE CONSTRAINTS;
-- DROP TABLE flight_realised  CASCADE CONSTRAINTS; -- ??
DROP TABLE flight_seats     CASCADE CONSTRAINTS;

-- customers make reservations
-- reservations contain many tickets
-- each ticket is for a flight
-- each flight has an airplane
--      & is issued by an airline


-- DONE
-- zakaznik
CREATE TABLE customers (
  id               NUMBER PRIMARY KEY,
  first_name       VARCHAR(50) NOT NULL,
  last_name        VARCHAR(50) NOT NULL,
  email            VARCHAR(100) NOT NULL,
  addr_street      VARCHAR(100) NOT NULL,
  addr_town        VARCHAR(100) NOT NULL,
  addr_post_code   NUMBER NOT NULL,
  addr_state       VARCHAR(100) NOT NULL
);

-- rezervacia
CREATE TABLE reservations (
  id              NUMBER PRIMARY KEY,
  total_cost      NUMBER,
  payment_status  NUMBER NOT NULL CHECK(REGEXP_LIKE(payment_status,'[0-1]')), -- true or false
  created_at      TIMESTAMP NOT NULL,
  created_by      NUMBER,

  CONSTRAINT reservation_creator_fk FOREIGN KEY (created_by) REFERENCES customers(id)
);

-- letenka
CREATE TABLE tickets (
  /* Flight Ticket number ; Example : 160-4837291830 */
  ticket_number   VARCHAR(10) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(ticket_number, '[0-9]{3}(-)?[0-9]{10}')),
  cost            NUMBER NOT NULL,
  reservation     NUMBER NOT NULL,
  passenger       NUMBER NOT NULL,

  CONSTRAINT ticket_in_reservation_fk   FOREIGN KEY (reservation) REFERENCES reservations(id),
  CONSTRAINT ticket_for_passenger_fk    FOREIGN KEY (passenger)   REFERENCES passengers(id)
);

CREATE TABLE passengers (
  /* rodne cislo */
  id              NUMBER NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(id,'[0-9][0-9](0|1|2|3|5|6|7|8)[0-9][0-3][0-9][0-9]{3,4}')),
  first_name      VARCHAR(50) NOT NULL,
  last_name       VARCHAR(50) NOT NULL
);

-- let
CREATE TABLE flights (
  /* Flight Number in IATA official format; Example: BA026 */
  flight_number     NUMBER NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(flight_number, '[A-Z0-9]{3,}')),
  departure_time    TIMESTAMP WITH TIME ZONE NOT NULL,
  arrival_time      TIMESTAMP WITH TIME ZONE NOT NULL,
  airplane          NUMBER,
  airline           VARCHAR(2) NOT NULL,
  origin            VARCHAR(3) NOT NULL,
  destination       VARCHAR(3) NOT NULL,

  CONSTRAINT flight_with_airplane_fk        FOREIGN KEY (airplane)    REFERENCES airplanes(id),
  CONSTRAINT flight_operated_by_airline_fk  FOREIGN KEY (airline)     REFERENCES airlines(airline_code),
  CONSTRAINT flight_origin_airport_fk       FOREIGN KEY (origin)      REFERENCES airports(airport_code),
  CONSTRAINT flight_destination_airport_fk  FOREIGN KEY (destination) REFERENCES airports(airport_code)
);


-- lietadlo
CREATE TABLE airplanes (
  id                NUMBER NOT NULL PRIMARY KEY,
  production_year   DATE,
  producer          VARCHAR(100),
  model             VARCHAR(100),
  fclass_seats      NUMBER NOT NULL,  -- first class = 1.
  bclass_seats      NUMBER NOT NULL,  -- business class = 2.
  eclass_seats      NUMBER NOT NULL,  -- economy class = 3.
  airline           VARCHAR(2),

  CONSTRAINT airplane_owner_airline_fk FOREIGN KEY (airline) REFERENCES airlines(airline_code)
);


-- letecka spolocnost / aerolinie
CREATE TABLE airlines (
  /* Airline code in official IATA format; Example: CX */
  airline_code    VARCHAR(2) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(airline_code,'[A-Z0-9]{2}'),
  nationality     VARCHAR(100) NOT NULL,
  full_name       VARCHAR(100) NOT NULL,
  hub             VARCHAR(3) REFERENCES airports(airport_code)
);


-- letisko
CREATE TABLE airports (
  airport_code    VARCHAR(3) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(airport_code, '[A-Z]{3}')),
  city            VARCHAR(100) NOT NULL,
  country         VARCHAR(100) NOT NULL
);


-- ??? TODO:
-- CREATE TABLE flight_realised (
--     realisation_id NUMBER NOT NULL PRIMARY KEY,
--     realised_by NUMBER,
--     realised_flight NUMBER,
--
--     CONSTRAINT fk_realised_by     FOREIGN KEY (realised_by)     REFERENCES airline (airline_id),
--     CONSTRAINT fk_realised_flight FOREIGN KEY (realised_flight) REFERENCES flight (flight_id)
-- );


-- zaznam vyhladavania
CREATE TABLE search_records (
  id        NUMBER NOT NULL PRIMARY KEY,
  customer  NUMBER NOT NULL,
  flight    NUMBER NOT NULL REFERENCES flights(flight_number),

  CONSTRAINT searched_by_customer_fk  FOREIGN KEY (customer)  REFERENCES customers(id),
  CONSTRAINT searched_for_flight_fk   FOREIGN KEY (flight)    REFERENCES flights(flight_number)
);


-- probably NOT
-- ??
-- CREATE TABLE flight_seats (
--   id           NUMBER NOT NULL PRIMARY KEY,
--   cost         NUMBER NOT NULL,
--   class        NUMBER NOT NULL,
--   passenger    NUMBER NOT NULL,
--   flight       NUMBER NOT NULL,
--   offered_by   NUMBER NOT NULL,
--
--   CONSTRAINT fk_seat_reserved_by FOREIGN KEY (seat_reserved_by) REFERENCES reservation (reservation_id),
--   CONSTRAINT fk_at_flight FOREIGN KEY (at_flight) REFERENCES flight (flight_id),
--   CONSTRAINT fk_offered_by FOREIGN KEY (offered_by) REFERENCES airline (airline_id)
-- );


-- =================================================================
-- [ ] [3/5] SQL skript s několika dotazy SELECT
-- =================================================================


-- =================================================================
-- [ ] [4/5] SQL skript pro vytvoření pokročilých objektů schématu
-- =================================================================


-- =================================================================
-- [ ] [5/5] Dokumentace popisující finální schéma databáze
-- =================================================================
