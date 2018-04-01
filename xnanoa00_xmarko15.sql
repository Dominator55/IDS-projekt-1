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

/* TODO: payment info ( credit cards ), seating info storing, */

/*
    __SUMMARY__
    
    TABLES: 
      airlines
      airplanes
      airports
      flights
      customers
      passengers
      reservations
      tickets
      search_records
      
    RULES:
      - customers make reservations
      - reservations contain many tickets
      - each ticket is for 1 flight and 1 passenger
      - each flight has 1 airplane assigned
        & is issued by 1 airline
      - there may be multiple tickets for the same passenger and for the same flight
      - each ticket has seat
*/

/* DELETE TABLES for CLEAN START */

  DROP TABLE customers        CASCADE CONSTRAINTS;
  DROP TABLE reservations     CASCADE CONSTRAINTS;
  DROP TABLE tickets          CASCADE CONSTRAINTS;
  DROP TABLE flights          CASCADE CONSTRAINTS;
  DROP TABLE airplanes        CASCADE CONSTRAINTS;
  DROP TABLE airports         CASCADE CONSTRAINTS;
  DROP TABLE airlines         CASCADE CONSTRAINTS;
  DROP TABLE passengers       CASCADE CONSTRAINTS;
  DROP TABLE search_records   CASCADE CONSTRAINTS;

  DROP SEQUENCE airplane_seq;
  CREATE SEQUENCE airplane_seq START WITH 1 INCREMENT BY 1 NOCYCLE;
/* CREATE ALL TABLES */

  /* AVIATION MODEL */

  CREATE TABLE airports (
    /* Airport code in official IATA format; Example: JFK */
    airport_code    VARCHAR(3) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(airport_code, '[A-Z]{3}')),
    city            VARCHAR(100) NOT NULL,
    country         VARCHAR(100) NOT NULL
  );


  CREATE TABLE airlines (
    /* Airline code in official IATA format; Example: CX */
    airline_code    VARCHAR(2) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(airline_code,'[A-Z0-9]{2}')),
    full_name       VARCHAR(100) NOT NULL,
    nationality     VARCHAR(100) NOT NULL,
    hub             VARCHAR(3),
    
    CONSTRAINT airline_hub_airport_fk FOREIGN KEY (hub) REFERENCES airports(airport_code)
  );


  CREATE TABLE airplanes (
    id                NUMBER NOT NULL PRIMARY KEY,
    producer          VARCHAR(100),
    model             VARCHAR(100),
    fclass_seats      NUMBER NOT NULL,  -- first class = 1.
    bclass_seats      NUMBER NOT NULL,  -- business class = 2.
    eclass_seats      NUMBER NOT NULL,  -- economy class = 3.
    airline           VARCHAR(2),

    CONSTRAINT airplane_owner_airline_fk FOREIGN KEY (airline) REFERENCES airlines(airline_code)
  );


  /* Reservation system */

  CREATE TABLE flights (
    /* Flight Number in IATA official format; Example: BA026 */
    flight_number     NUMBER NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(flight_number, '[A-Z0-9]{3,}')),
    departure_time    TIMESTAMP WITH TIME ZONE NOT NULL,
    arrival_time      TIMESTAMP WITH TIME ZONE NOT NULL,
    airplane          NUMBER,
    airline           VARCHAR(2) NOT NULL,
    origin            VARCHAR(3) NOT NULL,
    destination       VARCHAR(3) NOT NULL,
    --fclass_seats_free NUMBER,
    --bclass_seats_free NUMBER,
    --eclass_seats_free NUMBER,

    CONSTRAINT flight_with_airplane_fk        FOREIGN KEY (airplane)    REFERENCES airplanes(id),
    CONSTRAINT flight_operated_by_airline_fk  FOREIGN KEY (airline)     REFERENCES airlines(airline_code),
    CONSTRAINT flight_origin_airport_fk       FOREIGN KEY (origin)      REFERENCES airports(airport_code),
    CONSTRAINT flight_destination_airport_fk  FOREIGN KEY (destination) REFERENCES airports(airport_code)
  );

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

  CREATE TABLE reservations (
    id              NUMBER PRIMARY KEY,
    total_cost      NUMBER,
    payment_status  NUMBER NOT NULL CHECK(payment_status = 0 or payment_status = 1), -- true or false
    created_at      TIMESTAMP NOT NULL,
    created_by      NUMBER,

    CONSTRAINT reservation_creator_fk FOREIGN KEY (created_by) REFERENCES customers(id)
  );

  CREATE TABLE passengers (
    /* Personal ID number */
    id              NUMBER NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(id,'[0-9][0-9][0-8][0-9][0-3][0-9][0-9]{3,4}')),
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL
  );

  CREATE TABLE tickets (
    /* Flight Ticket number ; Example : 160-4837291830 */
    ticket_number   VARCHAR(10) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(ticket_number, '[0-9]{3}(-)?[0-9]{10}')),
    cost            NUMBER NOT NULL,
    reservation     NUMBER NOT NULL,
    passenger       NUMBER NOT NULL,
    flight          NUMBER NOT NULL,
    seat_number     VARCHAR(3) CHECK(REGEXP_LIKE(seat_number, '[0-9][0-9][A-K]')),
    seat_class      VARCHAR(1) CHECK(REGEXP_LIKE(seat_class, 'F|B|E')),

    CONSTRAINT ticket_in_reservation_fk   FOREIGN KEY (reservation) REFERENCES reservations(id),
    CONSTRAINT ticket_for_passenger_fk    FOREIGN KEY (passenger)   REFERENCES passengers(id),
    CONSTRAINT ticket_for_flight_fk       FOREIGN KEY (flight)      REFERENCES flights(flight_number)
  );

  CREATE TABLE search_records (
    id        NUMBER NOT NULL PRIMARY KEY,
    customer  NUMBER NOT NULL,
    flight    NUMBER NOT NULL,

    CONSTRAINT searched_by_customer_fk  FOREIGN KEY (customer)  REFERENCES customers(id),
    CONSTRAINT searched_for_flight_fk   FOREIGN KEY (flight)    REFERENCES flights(flight_number)
  );

  CREATE OR REPLACE TRIGGER airplane_trig BEFORE
    INSERT ON airplanes
    FOR EACH ROW
    BEGIN
        SELECT airplane_seq.NEXTVAL
        INTO : NEW.id
        FROM dual;
  END;
  /
  
/* ---------------------
  INSERT SAMPLE DATA 
---------------------- */

INSERT INTO airports (airport_code, city, country)
VALUES ('FRA', 'Frankfurt', 'Germany');

INSERT INTO airports (airport_code, city, country)
VALUES ('CDG', 'Paris', 'France');

INSERT INTO airports (airport_code, city, country)
VALUES ('IST', 'Istanbul', 'Turkey');

INSERT INTO airports (airport_code, city, country)
VALUES ('LHR', 'London', 'United Kingdom');

INSERT INTO airports (airport_code, city, country)
VALUES ('DXB', 'Dubai', 'United Arab Emirates');

INSERT INTO airports (airport_code, city, country)
VALUES ('DFW', 'Dallas', 'USA');

-- info from wikipedia ; list of airlines
INSERT INTO airlines (airline_code, full_name, nationality, hub)
VALUES ('AA', 'American Airlines', 'USA', 'DFW');

INSERT INTO airlines (airline_code, full_name, nationality, hub)
VALUES ('LH', 'Lufthansa', 'Germany', 'FRA');

INSERT INTO airlines (airline_code, full_name, nationality, hub)
VALUES ('AF', 'Air France', 'France', 'CDG');

INSERT INTO airlines (airline_code, full_name, nationality, hub)
VALUES ('BA', 'British Airways', 'United Kingdom ', 'LHR');

INSERT INTO airlines (airline_code, full_name, nationality, hub)
VALUES ('TK', 'Turkish Airlines', 'Turkey', 'IST');

INSERT INTO airlines (airline_code, full_name, nationality, hub)
VALUES ('EK', 'Emirates', 'United Arab Emirates', 'DXB');

-- info from: https://seatguru.com/
-- TODO: pridat autoincrement na ID alebo pridat priamo ID 
INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A380-800', '14', '76', '399', 'EK');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '777-300ER', '8', '42', '304', 'EK');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A330-200', '0', '40', '147', 'AF');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A330-200', '0', '20', '224', 'AA');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '767-300', '0', '28', '160', 'AA');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '767-300', '0', '28', '160', 'AA');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '747-400', '14', '86', '145', 'BA');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A330-200', '0', '22', '228', 'TK');



-- TODO: pridat rodne cisla
INSERT INTO passengers (id, first_name, last_name)
VALUES ('<rodnecislo>', 'Andrej', 'Nano');

INSERT INTO passengers (id, first_name, last_name)
VALUES ('<rodnecislo>', 'Peter', 'Marko');

INSERT INTO passengers (id, first_name, last_name)
VALUES (9905291235, 'Meno', 'Priezvisko');

INSERT INTO passengers (id, first_name, last_name)
VALUES (9805291244, 'Meno', 'Priezvisko');

INSERT INTO passengers (id, first_name, last_name)
VALUES (9805291245, 'Meno', 'Priezvisko');

INSERT INTO passengers (id, first_name, last_name)
VALUES (9805291246, 'Meno', 'Priezvisko');

INSERT INTO passengers (id, first_name, last_name)
VALUES (9805291247, 'Meno', 'Priezvisko');

INSERT INTO passengers (id, first_name, last_name)
VALUES (6905291235, 'Dalibor', 'Masaryk');

INSERT INTO passengers (id, first_name, last_name)
VALUES (8502191235, 'Aurélia', 'Dubovská');

INSERT INTO passengers (id, first_name, last_name)
VALUES (73115291233, 'Mohamed', 'Lee');

INSERT INTO passengers (id, first_name, last_name)
VALUES (9705791235, 'Teódor', 'Ladislav');


-- generator used: https://names.igopaygo.com/people/fake-person
INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Chahaya', 'Miles', 'ch.mile@egl-inc.info', '5542 Thunder Log Trail', 'Quebec City', 'G6R-5B7', 'Canada');

INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Ifor', 'Smoak', 'iforsmoa@diaperstack.com', '3909 Tawny View Rise', 'New York', '12379-2763', 'USA');

INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Zelda', 'Reel', 'zelda.reel@autozone-inc.info', '4326 Lazy Sky Via', 'West Virginia', '26499-7868', 'USA');

INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Sherwin', 'Hsu', 'sherwinhsu@diaperstack.com', '9264 Silver Lagoon Concession', 'Maryland', '21922-7045', 'USA');

INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Teódor', 'Ladislav', 'teodorL@gmail.com', '4 S. Chalupku', 'Prievidza', '97101', 'Slovakia');



-- =================================================================
-- [ ] [3/5] SQL skript s několika dotazy SELECT
-- =================================================================


-- =================================================================
-- [ ] [4/5] SQL skript pro vytvoření pokročilých objektů schématu
-- =================================================================


-- =================================================================
-- [ ] [5/5] Dokumentace popisující finální schéma databáze
-- =================================================================
