-- =================================================================
-- Name: IDS Projekt - SQL
-- Description: School Database Systems project, SQL for Oracle 12c 
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
-- [X] [1/5] ERD + USE CASE
-- =================================================================
    -- NO SCRIPT PDF odovzdane


-- =================================================================
-- [X] [2/5] SQL skript pro vytvoření základních objektů schématu
-- =================================================================

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

  DROP SEQUENCE reservation_seq;
  CREATE SEQUENCE reservation_seq START WITH 1 INCREMENT BY 1 NOCYCLE;

  DROP SEQUENCE search_record_seq;
  CREATE SEQUENCE search_record_seq START WITH 1 INCREMENT BY 1 NOCYCLE;

  DROP SEQUENCE customer_seq;
  CREATE SEQUENCE customer_seq START WITH 1 INCREMENT BY 1 NOCYCLE;


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
    airline    VARCHAR(2) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(airline,'[A-Z0-9]{2}')),
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

    CONSTRAINT airplane_owner_airline_fk FOREIGN KEY (airline) REFERENCES airlines(airline)
  );


  /* Reservation system */
  CREATE TABLE flights (
    /* Flight Number in IATA official format; Example: BA026 */
    flight_number     VARCHAR(6) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(flight_number, '[0-9a-zA-Z]{2}[0-9]{4}')),
    departure_time    TIMESTAMP WITH TIME ZONE NOT NULL,
    arrival_time      TIMESTAMP WITH TIME ZONE NOT NULL,
    airplane          NUMBER,
    airline           VARCHAR(2) NOT NULL,
    origin            VARCHAR(3) NOT NULL,
    destination       VARCHAR(3) NOT NULL,
    fclass_seats_free NUMBER,
    constraint fclass_uint_seats check (fclass_seats_free >= 0),
    bclass_seats_free NUMBER,
    constraint bclass_uint_seats check (bclass_seats_free >= 0),
    eclass_seats_free NUMBER,
    constraint eclass_uint_seats check (eclass_seats_free >= 0),

    CONSTRAINT flight_with_airplane_fk        FOREIGN KEY (airplane)    REFERENCES airplanes(id),
    CONSTRAINT flight_operated_by_airline_fk  FOREIGN KEY (airline)     REFERENCES airlines(airline),
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
    id              NUMBER NOT NULL PRIMARY KEY,
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
    ticket_number   VARCHAR(14) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(ticket_number, '[0-9]{3}(-)?[0-9]{10}')),
    cost            NUMBER NOT NULL,
    reservation     NUMBER NOT NULL,
    passenger       NUMBER NOT NULL,
    flight          VARCHAR(6) NOT NULL,
    seat_number     VARCHAR(3) CHECK(REGEXP_LIKE(seat_number, '[0-9][0-9][A-K]')),
    seat_class      VARCHAR(1) CHECK(REGEXP_LIKE(seat_class, '(F|B|E)')),

    CONSTRAINT ticket_in_reservation_fk   FOREIGN KEY (reservation) REFERENCES reservations(id),
    CONSTRAINT ticket_for_passenger_fk    FOREIGN KEY (passenger)   REFERENCES passengers(id),
    CONSTRAINT ticket_for_flight_fk       FOREIGN KEY (flight)      REFERENCES flights(flight_number)
  );

  CREATE TABLE search_records (
    id        NUMBER NOT NULL PRIMARY KEY,
    customer  NUMBER NOT NULL,
    flight    VARCHAR(6) NOT NULL,

    CONSTRAINT searched_by_customer_fk  FOREIGN KEY (customer)  REFERENCES customers(id),
    CONSTRAINT searched_for_flight_fk   FOREIGN KEY (flight)    REFERENCES flights(flight_number)
  );

  CREATE OR REPLACE TRIGGER f_ticket_trig BEFORE
    INSERT ON tickets
    FOR EACH ROW
    WHEN (NEW.seat_class = 'F')
    BEGIN
        UPDATE flights
        SET fclass_seats_free = fclass_seats_free - 1
        WHERE flights.flight_number = :NEW.flight;
    END;
  /
  CREATE OR REPLACE TRIGGER b_ticket_trig BEFORE
    INSERT ON tickets
    FOR EACH ROW
    WHEN (NEW.seat_class = 'B')
    BEGIN
        UPDATE flights
        SET bclass_seats_free = bclass_seats_free - 1
        WHERE flights.flight_number = :NEW.flight;
    END;
  /
  CREATE OR REPLACE TRIGGER e_ticket_trig BEFORE
    INSERT ON tickets
    FOR EACH ROW
    WHEN (NEW.seat_class = 'E')
    BEGIN
        UPDATE flights
        SET eclass_seats_free = eclass_seats_free - 1
        WHERE flights.flight_number = :NEW.flight;
    END;
  /
  CREATE OR REPLACE TRIGGER flight_trig BEFORE
    INSERT ON flights
    FOR EACH ROW
    BEGIN
        SELECT fclass_seats
        INTO : NEW.fclass_seats_free
        FROM airplanes
        WHERE airplanes.id = :NEW.airplane;
        
        SELECT bclass_seats
        INTO : NEW.bclass_seats_free
        FROM airplanes
        WHERE airplanes.id = :NEW.airplane;
        
        SELECT eclass_seats
        INTO : NEW.eclass_seats_free
        FROM airplanes
        WHERE airplanes.id = :NEW.airplane;
    END;
  /
  CREATE OR REPLACE TRIGGER airplane_trig BEFORE
    INSERT ON airplanes
    FOR EACH ROW
    BEGIN
        SELECT airplane_seq.NEXTVAL
        INTO : NEW.id
        FROM dual;
    END;
  /
  CREATE OR REPLACE TRIGGER reservation_trig BEFORE
    INSERT ON reservations
    FOR EACH ROW
    BEGIN
        SELECT reservation_seq.NEXTVAL
        INTO : NEW.id
        FROM dual;
    END;
/
    CREATE OR REPLACE TRIGGER search_record_trig BEFORE
    INSERT ON search_records
    FOR EACH ROW
    BEGIN
        SELECT search_record_seq.NEXTVAL
        INTO : NEW.id
        FROM dual;
    END;
/
    CREATE OR REPLACE TRIGGER customer_trig BEFORE
    INSERT ON customers
    FOR EACH ROW
    BEGIN
        SELECT customer_seq.NEXTVAL
        INTO : NEW.id
        FROM dual;
    END;
  /


SET serveroutput ON;
/* ---------------------------------------
 Vypcita kolko priemerne zaplatil zakaznik s cislom id predanym v argumente za jednu letenku.
 Pokiaľ zákazník nemá rezerváciu, alebo rezervácia neobsahuje žiadne letenky, tak sa volá výnimka,
 informacie o tom, kto plati 
 letenky su ulozene v tabulke reservations, zakaznik moze zaplatit rezervaciu, ktora obsahuje
 viacere letenky aj pre ine osoby
 * --------------------------------------- */
CREATE OR REPLACE PROCEDURE customer_ticket_avg_cost (id_customer_arg NUMBER) AS
  BEGIN
    DECLARE CURSOR cursor_cost is
    SELECT C.id, C.first_name, C.last_name, T.cost
    FROM  customers C,  reservations R, tickets T
    WHERE C.id = id_customer_arg AND C.id = R.created_by AND R.id = T.reservation;
			id_customer customers.id%TYPE;
			first_name customers.first_name%TYPE;
			last_name customers.last_name%TYPE;
			cost tickets.cost%TYPE;
			total_cost tickets.cost%TYPE;
			avg_cost tickets.cost%TYPE;
			num_tickets NUMBER;
			BEGIN
				num_tickets := 0;
				total_cost := 0;
				OPEN cursor_cost;
				LOOP
					FETCH cursor_cost INTO id_customer, first_name, last_name, cost;
					EXIT WHEN cursor_cost%NOTFOUND;
					num_tickets:=num_tickets+1;
					total_cost := total_cost + cost;
				END LOOP;
				CLOSE cursor_cost;
				avg_cost := total_cost / num_tickets;
				DBMS_OUTPUT.put_line('Customer ' || id_customer || ' name : ' || first_name || ' ' || last_name || ' avg_cost : ' || avg_cost);
				EXCEPTION WHEN ZERO_DIVIDE THEN
					BEGIN
					DBMS_OUTPUT.put_line('Customer with ID: ' || id_customer_arg || ' does not have reservation in database.');
				END;
			END;
	END;
/

/* ------------------------------------
 Vypocita koloko percent vsetkych lietadiel vlastni letecka spolocnost s id airline_id_arg.
 Pokial databaza neobsahuje ziadne lietadlo vyvola sa vynimka
* ------------------------------------- */
CREATE OR REPLACE PROCEDURE airline_plane_percentage (airline_id_arg IN VARCHAR) AS
  BEGIN
    DECLARE CURSOR cursor_planes is
    SELECT P.airline, P.id
    FROM  airplanes P;
			id_airline airplanes.airline%TYPE;
      id_plane airplanes.id%TYPE;
			num_planes NUMBER;
      num_all_planes NUMBER;
      plane_percentage NUMBER;
			BEGIN
        num_all_planes := 0;
				num_planes := 0;
				OPEN cursor_planes;
				LOOP
					FETCH cursor_planes INTO id_airline, id_plane;
					EXIT WHEN cursor_planes%NOTFOUND;
          if id_airline = airline_id_arg THEN
            num_planes := num_planes + 1;
          END IF;
          num_all_planes := num_all_planes + 1;
				END LOOP;
				CLOSE cursor_planes;
				plane_percentage := (num_planes / num_all_planes) * 100;
				DBMS_OUTPUT.put_line('Airline ' || airline_id_arg || ' owns : ' || plane_percentage || ' % of all planes in database');
				EXCEPTION WHEN ZERO_DIVIDE THEN
					BEGIN
					DBMS_OUTPUT.put_line('Airplane database is empty!' );
				END;
			END;
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
VALUES ('LGW', 'London', 'United Kingdom');

INSERT INTO airports (airport_code, city, country)
VALUES ('DXB', 'Dubai', 'United Arab Emirates');

INSERT INTO airports (airport_code, city, country)
VALUES ('DFW', 'Dallas', 'USA');

INSERT INTO airports (airport_code, city, country)
VALUES ('TXL', 'Berlin', 'Germany');

INSERT INTO airports (airport_code, city, country)
VALUES ('JFK', 'New York', 'USA');

INSERT INTO airports (airport_code, city, country)
VALUES ('HEL', 'Helsinki', 'Finland');

INSERT INTO airports (airport_code, city, country)
VALUES ('VIE', 'Vienna', 'Austria');



-- info from wikipedia ; list of airlines
INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('AA', 'American Airlines', 'USA', 'DFW');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('LH', 'Lufthansa', 'Germany', 'FRA');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('AF', 'Air France', 'France', 'CDG');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('BA', 'British Airways', 'United Kingdom ', 'LHR');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('TK', 'Turkish Airlines', 'Turkey', 'IST');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('EK', 'Emirates', 'United Arab Emirates', 'DXB');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('FZ', 'flydubai', 'United Arab Emirates', 'DXB');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('AY', 'Finnair Oyj', 'Finland', 'HEL');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('OS', 'Austrian', 'Austria', 'VIE');


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
VALUES ('Boeing', '767-300', '0', '28', '160', 'AY');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '767-300', '0', '28', '160', 'AA');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '747-400', '14', '86', '145', 'BA');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A330-200', '0', '22', '228', 'TK');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A330-300', '8', '42', '145', 'LH');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '767-300', '0', '36', '176', 'OS');


INSERT INTO passengers (id, first_name, last_name)
VALUES (9802261040, 'Andrej', 'Nano');

INSERT INTO passengers (id, first_name, last_name)
VALUES (9812345678, 'Peter', 'Marko');

INSERT INTO passengers (id, first_name, last_name)
VALUES (9905291235, 'Sherwin', 'Hsu');

INSERT INTO passengers (id, first_name, last_name)
VALUES (9805291244, 'Ifor', 'Smoak');

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
VALUES (97057912356, 'Teódor', 'Ladislav');


-- generator used: https://names.igopaygo.com/people/fake-person
INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Chahaya', 'Miles', 'ch.mile@egl-inc.info', '5542 Thunder Log Trail', 'Quebec City', 7542, 'Canada');

INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Ifor', 'Smoak', 'iforsmoa@diaperstack.com', '3909 Tawny View Rise', 'New York', 1237, 'USA');

INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Zelda', 'Reel', 'zelda.reel@autozone-inc.info', '4326 Lazy Sky Via', 'West Virginia', 2649, 'USA');

INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Sherwin', 'Hsu', 'sherwinhsu@diaperstack.com', '9264 Silver Lagoon Concession', 'Maryland', 1922, 'USA');

INSERT INTO customers (first_name, last_name, email, addr_street, addr_town, addr_post_code, addr_state)
VALUES ('Teódor', 'Ladislav', 'teodorL@gmail.com', '4 S. Chalupku', 'Prievidza', 97101, 'Slovakia');


-- insert flights
INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('BA0304', TIMESTAMP '2018-05-20 07:20:00.00 +00:00', TIMESTAMP  '2018-05-20 09:35:00.00 +01:00', 9, 'BA', 'LHR', 'CDG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('EK1234', TIMESTAMP '2018-05-14 11:20:00.00 +04:00', TIMESTAMP '2018-05-14 14:55:00.00 +03:00', 2, 'EK', 'DXB', 'IST');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AA0000', TIMESTAMP '2018-05-09 16:40:00.00 +04:00', TIMESTAMP '2018-05-09 20:20:00.00 +03:00', 3, 'FZ', 'DXB', 'IST');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AA0001', TIMESTAMP '2018-05-11 19:50:00.00 +00:00', TIMESTAMP '2018-05-11 23:30:00.00 -04:00', 1, 'BA', 'LHR', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AA0002', TIMESTAMP '2018-05-20 8:30:00.00 +00:00', TIMESTAMP '2018-05-20 12:10:00.00 -04:00', 1, 'BA', 'LHR', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AA0003', TIMESTAMP '2018-05-21 8:30:00.00 +00:00', TIMESTAMP '2018-05-21 12:10:00.00 -04:00', 7, 'AY', 'LHR', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LH1724', TIMESTAMP'2018-05-20 06:15:00.00 +01:00', TIMESTAMP '2018-05-20 07:55:00.00 +01:00', 9, 'LH', 'FRA', 'TXL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LH1725', TIMESTAMP'2018-05-27 06:15:00.00 +01:00', TIMESTAMP '2018-05-27 07:55:00.00 +01:00', 9, 'LH', 'FRA', 'TXL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('OS0089', TIMESTAMP'2018-05-25 10:15:00.00 +01:00', TIMESTAMP '2018-05-25 13:50:00.00 -04:00', 10, 'OS', 'VIE', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LH1235', TIMESTAMP'2018-05-25 11:10:00.00 +01:00', TIMESTAMP '2018-05-25 15:45:00.00 -04:00', 7, 'LH', 'VIE', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AZ2275', TIMESTAMP'2018-05-30 8:00:00.00 +00:00', TIMESTAMP '2018-05-30 10:15:00.00 +01:00', 2, 'BA', 'LGW', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AB3275', TIMESTAMP'2018-05-04 08:00:00.00 +02:00', TIMESTAMP '2018-05-04 08:45:00.00 +00:00', 5, 'AY', 'HEL', 'LGW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AC1275', TIMESTAMP'2018-05-05 18:00:00.00 +00:00', TIMESTAMP '2018-05-05 22:50:00.00 +02:00', 5, 'AY', 'LGW', 'HEL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('BZ1275', TIMESTAMP'2018-05-25 04:10:00.00 +00:00', TIMESTAMP '2018-05-25 06:45:00.00 +01:00', 6, 'LH', 'LHR', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LI1725', TIMESTAMP'2018-05-27 06:15:00.00 +01:00', TIMESTAMP '2018-05-27 07:55:00.00 +00:00', 10, 'LH', 'TXL', 'LHR');




-- insert reservations
INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('1', TIMESTAMP '2018-03-20 02:42:11.00', '1');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('0', TIMESTAMP '2018-03-25 21:12:12.00', '2');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('1', TIMESTAMP '2018-02-01 23:42:12.00', '3');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('0', TIMESTAMP '2018-05-01 23:42:12.00', '4');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('1', TIMESTAMP '2018-05-01 00:42:12.00', '4');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('1', TIMESTAMP '2018-05-03 5:42:12.00', '5');



-- insert tickets
INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('212-1241241421', 410, 2, 9802261040, 'BA0304', '12B', 'E');

INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('011-1251000221', 123, 4, 9812345678, 'EK1234', '03F', 'B');

INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('011-1251077229', 142, 4, 97057912356, 'LH1724', '01B', 'B');

INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('021-1251077233', 142, 6, 97057912356, 'LH1725', '01B', 'B');

INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('021-1251077257', 172, 6, 97057912356, 'LI1725', '01C', 'B');

INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('021-1251077242', 112, 5, 9802261040, 'AZ2275', '01D', 'E');

INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('021-1251077299', 512, 5, 9802261040, 'AA0001', '05D', 'E');

INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('021-1251077429', 512, 2, 9905291235, 'AA0001', '05D', 'E');

INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('021-1251022299', 512, 4, 9805291244, 'AA0001', '05D', 'E');



-- insert search records
INSERT INTO search_records (customer, flight)
VALUES (1, 'BA0304');

INSERT INTO search_records (customer, flight)
VALUES (1, 'LH1724');

INSERT INTO search_records (customer, flight)
VALUES (1, 'EK1234');

-- =================================================================
-- [X] [3/5] SQL skript s několika dotazy SELECT
-- =================================================================

/*
  SQL skript obsahující dotazy SELECT musí obsahovat konkrétně 
  alespoň dva dotazy využívající spojení dvou tabulek, jeden 
  využívající spojení tří tabulek, dva dotazy s klauzulí 
  GROUP BY a agregační funkcí, jeden dotaz obsahující predikát 
  EXISTS a jeden dotaz s predikátem IN s vnořeným selectem 
  (nikoliv IN s množinou konstatních dat). U každého z dotazů 
  musí být (v komentáři SQL kódu) popsáno srozumitelně, jaká 
  data hledá daný dotaz (jaká je jeho funkce v aplikaci).
*/

-- 2 dotazy (JOIN 2 tables)

-- Ktore lety su prevadzakovane British Airways
  SELECT *
  from flights NATURAL JOIN airlines
  WHERE  full_name = 'British Airways';
    
-- Ake typy lietadiel vlastni American Airlines
  SELECT DISTINCT producer, model
  from airlines NATURAL JOIN airplanes
  WHERE  full_name = 'American Airlines';
    
-- 1 dotaz (JOIN 3 tables)

  -- Kto prevadzkuje lety z London do New York?
  SELECT DISTINCT full_name
  FROM  flights NATURAL JOIN airlines, airports A1, airports A2
  WHERE A1.city = 'London' AND A2.city = 'New York' AND flights.origin = A1.airport_code AND flights.destination = A2.airport_code;


-- 2 dotazy (GROUP BY & agregacna funkcia)
  
  -- Vypis spolocnosti podla poctu destinacii, do ktorych lietaju
  SELECT full_name, COUNT(DISTINCT A.airport_code)
  FROM flights NATURAL JOIN airlines, airports A
  WHERE flights.destination = A.airport_code
  GROUP BY full_name
  ORDER BY 2 DESC;
    
  -- Ktory pasazieri maju zakupene viac ako 2 letenky?
  SELECT p.first_name, p.last_name, COUNT(DISTINCT t.ticket_number)
  FROM  tickets t, passengers p
  WHERE t.passenger = p.id
  GROUP BY p.first_name, p.last_name
  HAVING COUNT(DISTINCT t.ticket_number) > 2;

-- 1 dotaz (EXISTS)
  
  -- Ktora letecka spolocnost lieta do Helsinki a New Yorku zaroven ? 
  SELECT airlines.full_name
  FROM airlines
  WHERE EXISTS (
      SELECT flight_number
      FROM flights
      WHERE airline = airlines.airline 
      AND flights.destination IN ( SELECT airport_code FROM airports WHERE airports.city = 'Helsinki')
      )
  AND EXISTS (
      SELECT flight_number
      FROM flights
      WHERE airline = airlines.airline 
      AND flights.destination IN ( SELECT airport_code FROM airports WHERE airports.city = 'New York')
      );


-- 1 dotaz (predikat IN s vnorenym selectom)
  
  -- Vypis vsetky lety Vieden->New York (je mozne zamenit za ine mesta)
  SELECT flights.flight_number , flights.departure_time, flights.arrival_time
  FROM flights 
  WHERE flights.origin IN (
    SELECT airport_code FROM airports WHERE airports.city = 'Vienna'
  ) 
  AND flights.destination IN (
    SELECT airport_code FROM airports WHERE airports.city = 'New York'
  );
  

  -- Kolko letov lieta celkovo z Viedne ?
  SELECT city, count(*)
  FROM flights JOIN airports ON flights.origin = airports.airport_code
  WHERE airports.city = 'Vienna'
  GROUP BY city;

  -- debug queries
  select *
  from flights;

  select *
  from airports; 
  
  select *
  from airlines;


-- =================================================================
-- [X] [4/5] SQL skript pro vytvoření pokročilých objektů schématu
-- =================================================================

-- Explain plan, to see the difference between searching against tables without INDEX
-- and with an INDEX. Should be used for frequently used tables.


-- first run
-- Display information for every passenger for every reservation, including number of flights and total cost for the passenger
EXPLAIN PLAN FOR 
SELECT reservation, first_name, last_name, COUNT(*) AS num_of_flights, SUM(cost) AS cost_all
FROM passengers, tickets
WHERE passengers.id = tickets.passenger
GROUP BY reservation, first_name, last_name;

-- OUTPUT 
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- create an INDEX
--CREATE INDEX passenger_index ON passengers (id, first_name, last_name); -- additional index 
CREATE INDEX ticket_index ON tickets (passenger, reservation, cost);
-- 

-- second run
EXPLAIN PLAN FOR 
SELECT reservation, first_name, last_name, COUNT(*) AS num_of_flights, SUM(cost) AS cost_all
FROM passengers, tickets
WHERE passengers.id = tickets.passenger
GROUP BY reservation, first_name, last_name;

-- OUTPUT 
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- the actual query output, only for DEBUG
-- SELECT reservation, first_name, last_name, COUNT(*) AS num_of_flights, SUM(cost) AS cost_all
-- FROM passengers, tickets
-- WHERE passengers.id = tickets.passenger
-- GROUP BY reservation, first_name, last_name;

DROP INDEX ticket_index;
--DROP INDEX passenger_index;

-- example procedure execution
EXEC customer_ticket_avg_cost(2);
EXEC customer_ticket_avg_cost(4);
EXEC customer_ticket_avg_cost(5);
EXEC airline_plane_percentage('AA');
EXEC airline_plane_percentage('EK');
EXEC airline_plane_percentage('AY');

--
-- Permissions for the second user (as Booking Agent, explained in documentation)
--
GRANT SELECT ON flights     TO xmarko15;
GRANT SELECT ON airlines    TO xmarko15;
GRANT SELECT ON airports    TO xmarko15;

GRANT ALL ON customers      TO xmarko15;
GRANT ALL ON passengers     TO xmarko15;
GRANT ALL ON reservations   TO xmarko15;
GRANT ALL ON tickets        TO xmarko15;
GRANT ALL ON search_records TO xmarko15;

-- execution permission on procedures
GRANT EXECUTE ON customer_ticket_avg_cost TO xmarko15;
GRANT EXECUTE ON airline_plane_percentage TO xmarko15;

--
-- Materialized view
-- 
DROP MATERIALIZED VIEW passenger_ticket_summary;

-- log changes to these tables
CREATE MATERIALIZED VIEW LOG ON tickets WITH PRIMARY KEY, ROWID;
CREATE MATERIALIZED VIEW LOG ON passengers WITH PRIMARY KEY, ROWID;

-- often used passenger-ticket pairs
CREATE MATERIALIZED VIEW passenger_ticket_summary
  NOLOGGING
  CACHE
  BUILD IMMEDIATE
  REFRESH FAST ON COMMIT
  ENABLE QUERY REWRITE
AS
SELECT passengers.rowid AS passenger_rid, tickets.rowid AS ticket_rid,
first_name, last_name, flight, seat_number, seat_class, cost
FROM passengers JOIN tickets ON passengers.id = tickets.passenger;

GRANT ALL ON passenger_ticket_summary TO xmarko15;

-- example usage:

SELECT first_name, last_name, flight, seat_number, seat_class, cost
FROM passenger_ticket_summary;

INSERT INTO tickets (ticket_number, cost, reservation, passenger, flight, seat_number, seat_class)
VALUES ('022-0231079259', 139, 4, 9802261040, 'LH1724', '01A', 'F');

COMMIT;

SELECT first_name, last_name, flight, seat_number, seat_class, cost
FROM passenger_ticket_summary;

DELETE FROM tickets WHERE ticket_number = '022-0231079259';

SELECT first_name, last_name, flight, seat_number, seat_class, cost
FROM passenger_ticket_summary;

-- commit to apply the last DELETE statement
COMMIT;

SELECT first_name, last_name, flight, seat_number, seat_class, cost
FROM passenger_ticket_summary;


-- =================================================================
-- [X] [5/5] Dokumentace popisující finální schéma databáze
-- =================================================================
