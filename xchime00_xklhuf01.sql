-- Name:
-- IDS Projekt 2019/20
-- Galaktické impérium

-- Authors:
-- Andrea Chimenti (xchime00)
-- Jan Klhůfek (xklhuf01)


-- cleanup

DROP TABLE "star-element";
DROP TABLE "orbits_around";
DROP TABLE "star";
DROP TABLE "jedi";
DROP TABLE "spaceship";
DROP TABLE "fleet";
DROP TABLE "planet";
DROP TABLE "element";
DROP TABLE "planetary_system";
DROP TABLE "star_type";

DROP SEQUENCE "star_pk_num";

DROP INDEX "fleet_spaceships";

DROP MATERIALIZED VIEW "fleets_orbiting_planet";

-- main body

CREATE TABLE "planetary_system"
(
    "id" INTEGER CONSTRAINT "PK_planetary_system" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "planetary_system_name_uni" UNIQUE CONSTRAINT "planetary_system_name_nn" NOT NULL
);

CREATE TABLE "star_type"
(
    "type" VARCHAR(60) CONSTRAINT "PK_star_type" PRIMARY KEY
);


CREATE TABLE "element"
(
    "atomic_number" INTEGER CONSTRAINT "PK_element" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "element_name_uni" UNIQUE CONSTRAINT "element_name_nn" NOT NULL,
    "symbol" VARCHAR(2) CONSTRAINT "element_symbol_uni" UNIQUE CONSTRAINT "element_symbol_nn" NOT NULL,
    "density" NUMBER(*,3) CONSTRAINT "density_nn" NOT NULL,
    "column" INTEGER CONSTRAINT "column_nn" NOT NULL,
    "row" INTEGER CONSTRAINT "row_nn" NOT NULL
);

CREATE TABLE "star"
(
    "id" INTEGER CONSTRAINT "PK_star" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "star_name_uni" UNIQUE CONSTRAINT "star_name_nn" NOT NULL,
    "planetary_system_id" INTEGER CONSTRAINT "star_planetary_system_id_nn" NOT NULL,
    "type" VARCHAR(60) CONSTRAINT "star_type_nn" NOT NULL,
    CONSTRAINT "FK_planetary_system_id" FOREIGN KEY ("planetary_system_id") REFERENCES "planetary_system" ("id") ON DELETE CASCADE,
    CONSTRAINT "FK_star_type" FOREIGN KEY ("type") REFERENCES "star_type" ("type")
);

CREATE TABLE "star-element"
(
    "star_id" INTEGER,
    "atomic_number" INTEGER,
    CONSTRAINT "PK_star-element" PRIMARY KEY ("star_id", "atomic_number"),
    CONSTRAINT "FK_star_id" FOREIGN KEY ("star_id") REFERENCES "star" ("id") ON DELETE CASCADE,
    CONSTRAINT "FK_atomic_number" FOREIGN KEY ("atomic_number") REFERENCES "element" ("atomic_number")
);

CREATE TABLE "planet"
(
    "id" INTEGER CONSTRAINT "PK_planet_id" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "planet_name_uni" UNIQUE CONSTRAINT "planet_name_nn" NOT NULL,
    "habitable" NUMBER(1, 0),
    "radius" INTEGER,
    "density" NUMBER(*,3),
    "gravitational_acceleration" NUMBER(*,3),
    "moon_count" INTEGER
);


CREATE TABLE "orbits_around"
(
    "planet_id" INTEGER,
    "star_id" INTEGER,
    "distance" INTEGER,
    CONSTRAINT "PK_orbits_planet-star" PRIMARY KEY ("planet_id", "star_id"),
    CONSTRAINT "FK_orbits_planet_id" FOREIGN KEY ("planet_id") REFERENCES "planet" ("id") ON DELETE CASCADE,
    CONSTRAINT "FK_orbits_star_id" FOREIGN KEY ("star_id") REFERENCES "star" ("id") ON DELETE CASCADE
);

CREATE TABLE "fleet"
(
    "id" INTEGER CONSTRAINT "fleet_id_PK" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "fleet_name_uni" UNIQUE CONSTRAINT "fleet_name_nn" NOT NULL,
    "orbits_planet" INTEGER,
    CONSTRAINT "FK_orbits_planet" FOREIGN KEY ("orbits_planet") REFERENCES "planet" ("id") ON DELETE SET NULL
);

CREATE TABLE "spaceship"
(
    "id" INTEGER CONSTRAINT "PK_spaceship_id" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "spaceship_name_uni" UNIQUE CONSTRAINT "spaceship_name_nn" NOT NULL,
    "year_of_manufacture" INTEGER,
    "crew_size" INTEGER,
    "fleet_id" INTEGER CONSTRAINT "spaceship_fleet_id_nn" NOT NULL,
    CONSTRAINT "FK_fleet_id" FOREIGN KEY ("fleet_id") REFERENCES "fleet" ("id") ON DELETE CASCADE,
    "type" VARCHAR(60),
    "cargo_capacity" INTEGER,
    "starfighter_count" INTEGER,
    "settlers_capacity" INTEGER,
    CONSTRAINT "check_ship_type" CHECK (
        ("type" = 'merchant' AND "type" IS NOT NULL AND "cargo_capacity" IS NOT NULL AND "starfighter_count" IS NULL AND "settlers_capacity" IS NULL)
        OR
        ("type" = 'warship' AND "type" IS NOT NULL AND "cargo_capacity" IS NULL AND "starfighter_count" IS NOT NULL AND "settlers_capacity" IS NULL)
        OR
        ("type" = 'colonial' AND "type" IS NOT NULL AND "cargo_capacity" IS NULL AND "starfighter_count" IS NULL AND "settlers_capacity" IS NOT NULL)
        OR
        ("type" IS NULL AND "cargo_capacity" IS NULL AND "starfighter_count" IS NULL AND "settlers_capacity" IS NULL)
        )
);

CREATE TABLE "jedi"
(
    "imperial_identification_number" CHAR(20) CONSTRAINT "PK_jedi_imperial_id_number" PRIMARY KEY CONSTRAINT "jedi_imperial_id_format" CHECK(REGEXP_LIKE("imperial_identification_number", '[0-9]{5}-[a-zA-Z]{4}-[a-zA-Z]{4}-[a-zA-Z]{4}')), --např. "00000-AAAA-FFFF-ZZZZ"
    "name" VARCHAR(60) CONSTRAINT "jedi_name_nn" NOT NULL,
    "surname" VARCHAR(60) CONSTRAINT "jedi_surname_nn" NOT NULL ,
    "date_of_birth" DATE,
    "lightsaber_color" CHAR(7) CONSTRAINT "check_lightsaber_color" CHECK(REGEXP_LIKE("lightsaber_color", '#[0-9a-fA-F]{6}')), --hexadecimalni hodnota pro barvu (#000000 = cerna)
    "midichlorian_count" INTEGER DEFAULT 7000 CONSTRAINT "check_midichlorian_count" CHECK ("midichlorian_count" >= 7000),
    "commands_fleet" INTEGER CONSTRAINT "commands_fleet_uni" UNIQUE,
    "on_board" INTEGER,
    CONSTRAINT "FK_commands_fleet_id" FOREIGN KEY ("commands_fleet") REFERENCES "fleet" ("id") ON DELETE SET NULL,
    CONSTRAINT "FK_on_board" FOREIGN KEY ("on_board") REFERENCES "spaceship" ("id") ON DELETE SET NULL
);


-- insert mock data

INSERT INTO "planetary_system" ("id", "name") VALUES (1, 'Canis Major');
INSERT INTO "planetary_system" ("id", "name") VALUES (2, 'Orion');
INSERT INTO "planetary_system" ("id", "name") VALUES (3, 'Ursa Major');

INSERT INTO "element" ("atomic_number", "name", "symbol", "density", "column", "row") VALUES (1, 'Hydrogen', 'H', 0.089, 1, 1);
INSERT INTO "element" ("atomic_number", "name", "symbol", "density", "column", "row") VALUES (2, 'Helium', 'He', 0.179, 18, 1);
INSERT INTO "element" ("atomic_number", "name", "symbol", "density", "column", "row") VALUES (6, 'Carbon', 'C', 2.267, 14, 2);
INSERT INTO "element" ("atomic_number", "name", "symbol", "density", "column", "row") VALUES (16, 'Sulfur', 'S', 2.071, 16, 3);

INSERT INTO "planet" ("id", "name", "habitable", "radius", "density", "gravitational_acceleration", "moon_count") VALUES (1, 'B-612', 1, 364, 5.23, 8.41, 0);
INSERT INTO "planet" ("id", "name", "habitable", "radius", "density", "gravitational_acceleration", "moon_count") VALUES (2, 'R-4565', 0, 1604, 0.93, 15.41, 2);
INSERT INTO "planet" ("id", "name", "habitable", "radius", "density", "gravitational_acceleration", "moon_count") VALUES (3, 'E-897', 0, 98721, 1.23, 45.41, 3);

INSERT INTO "star_type" ("type") VALUES ('Blue dwarf');
INSERT INTO "star_type" ("type") VALUES ('Blue supergiant');
INSERT INTO "star_type" ("type") VALUES ('Red dwarf');
INSERT INTO "star_type" ("type") VALUES ('Red supergiant');
INSERT INTO "star_type" ("type") VALUES ('White dwarf');
INSERT INTO "star_type" ("type") VALUES ('Sun');
INSERT INTO "star_type" ("type") VALUES ('Artificial');

INSERT INTO "star" ("id", "name", "planetary_system_id", "type") VALUES (1, 'Sirius', 1, 'White dwarf');
INSERT INTO "star" ("id", "name", "planetary_system_id", "type") VALUES (2, 'Dubhe', 3, 'Red dwarf');
INSERT INTO "star" ("id", "name", "planetary_system_id", "type") VALUES (4, 'Rigel', 2, 'Blue supergiant');
INSERT INTO "star" ("id", "name", "planetary_system_id", "type") VALUES (5, 'Merak', 3, 'Artificial');
INSERT INTO "star" ("id", "name", "planetary_system_id", "type") VALUES (3, 'Betelgeuse', 2, 'Red supergiant');


INSERT INTO "fleet" ("id", "name", "orbits_planet") VALUES (1, 'San Diego', 2);
INSERT INTO "fleet" ("id", "name", "orbits_planet") VALUES (2, 'Boeing', 2);
INSERT INTO "fleet" ("id", "name", "orbits_planet") VALUES (3, 'Lokotos', NULL);

INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (2, 'Cactus', 2008, 720, 1, 'merchant', 4500, null, null);
INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (3, 'Eddi', 2012, 320, 1, 'warship', null, 280, null);
INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (4, 'Marco Polo', 2007, 1570, 1, 'colonial', null, null, 1550);
INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (45, 'Aurelius', 2003, 720, 2, null, null, null, null);
INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (6, 'Osiris', 2019, 20, 2, 'merchant', 500, null, null);

INSERT INTO "jedi" ("imperial_identification_number", "name", "surname", "date_of_birth", "lightsaber_color", "commands_fleet", "on_board", "midichlorian_count") VALUES ('12345-abcd-abcd-abcd', 'Anakin', 'Skywalker', (TO_DATE('1960/12/01 20:03:24', 'yyyy/mm/dd hh24:mi:ss')), '#34a1eb', 1, 2, 27700);
INSERT INTO "jedi" ("imperial_identification_number", "name", "surname", "date_of_birth", "lightsaber_color", "commands_fleet", "on_board") VALUES ('78912-abcd-abcd-abcd', 'Qui-Gon', 'Jinn', (TO_DATE('1954/05/12 15:15:44', 'yyyy/mm/dd hh24:mi:ss')), '#f54e42', 2, 6);
INSERT INTO "jedi" ("imperial_identification_number", "name", "surname", "date_of_birth", "lightsaber_color", "commands_fleet", "on_board") VALUES ('61056-zxcv-abcd-abcd', 'Mace', 'Windu', (TO_DATE('1987/03/31 15:15:44', 'yyyy/mm/dd hh24:mi:ss')), '#ed542c', null, 2);
INSERT INTO "jedi" ("imperial_identification_number", "name", "surname", "date_of_birth", "lightsaber_color", "commands_fleet", "on_board", "midichlorian_count") VALUES ('80234-zxcv-afdd-abcd', 'Obiwan', 'Kenobi', (TO_DATE('1972/08/10 15:15:44', 'yyyy/mm/dd hh24:mi:ss')), '#ed54ec', null, 6, 13400);
INSERT INTO "jedi" ("imperial_identification_number", "name", "surname", "date_of_birth", "lightsaber_color", "commands_fleet", "on_board", "midichlorian_count") VALUES ('40356-zxcv-abhg-ajcd', 'Master', 'Yoda', (TO_DATE('1900/01/18 15:15:44', 'yyyy/mm/dd hh24:mi:ss')), '#edaa2c', 3, null, 17700);

-- bond table

INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (1, 1);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (1, 2);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (1, 16);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (2, 1);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (2, 6);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (3, 1);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (4, 1);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (4, 16);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (5, 1);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (5, 2);

INSERT INTO "orbits_around" ("planet_id", "star_id", "distance") VALUES (1, 2, 4562321);
INSERT INTO "orbits_around" ("planet_id", "star_id", "distance") VALUES (2, 3, 5621);
INSERT INTO "orbits_around" ("planet_id", "star_id") VALUES (3, 2);

-- select queries

-- selects spaceships with fleet commanders on board
SELECT S."id" AS "spaceship_id", S."name" AS "spaceship_name", J."imperial_identification_number" AS "jedi_imperial_id", J."name" AS "jedi_name", J."surname" AS "jedi_surname"
FROM "jedi" J, "spaceship" S
WHERE J."on_board"=S."id"
AND J."commands_fleet" IS NOT NULL;

-- selects fleets which orbit a planet
SELECT P."id" AS "planet_id", P."name" AS "planet_name", F."id" AS "fleet_id", F."name" AS "fleet_name"
FROM "planet" P, "fleet" F
WHERE P."id" = F."orbits_planet"
ORDER BY "planet_name", "fleet_name";

-- selects stars with at least one habitable planet in its system
SELECT S."planetary_system_id" AS "planetary_system_id", S."id" AS "star_id", S."name" AS "star_name"
FROM "star" S, "orbits_around" O, "planet" P
WHERE S."id"=O."star_id" AND P."id" = O."planet_id"
AND P."habitable"=1
ORDER BY "planetary_system_id", "star_name";

-- list stars in planetary system by their type
SELECT P."name" AS "planetary_system_name", ST."type" AS "star_type", S."name" AS "star_name"
FROM "planetary_system" P, "star" S, "star_type" ST
WHERE P."id" = S."planetary_system_id" AND S."type" = ST."type"
ORDER BY P."name", ST."type", S."name";

-- count all jedis in a fleet
SELECT F."name" AS "fleet_name", COUNT(J."imperial_identification_number") AS "jedi_count"
FROM "fleet" F,"spaceship" S, "jedi" J
WHERE F."id" = S."fleet_id" AND S."id" = J."on_board"
GROUP BY F."name";

-- average moon count of planets orbiting a star
SELECT S."name" AS "star_name", AVG(P."moon_count") AS "average_moon_count"
FROM "star" S, "orbits_around" O, "planet" P
WHERE S."id"=O."star_id" AND P."id"=O."planet_id"
GROUP BY S."name";

-- select fleets with at least one spaceship with a crew smaller than 30
SELECT F."name"
FROM "fleet" F
WHERE EXISTS 
    (
        SELECT *
        FROM "spaceship" S
        WHERE S."fleet_id"=F."id"
        AND S."crew_size" < 30
    );

-- list all elements of which are Artificial stars made of
SELECT "name" as "element_name"
FROM "element"
WHERE "atomic_number" IN
    (
        SELECT "atomic_number"
        FROM "star-element"
        WHERE "star_id" IN
        (
            SELECT "id"
            FROM "star"
            WHERE "type"='Artificial'
        )
    );



-- database triggers

-- sequence for star primary key
CREATE SEQUENCE "star_pk_num" START WITH 1 INCREMENT BY 1;

-- TRIGGER no. 1: ensures insertion of new star with uniquely assigned primary key (id) if primary key is not defined by the user
CREATE OR REPLACE TRIGGER star_insertion
    BEFORE INSERT ON "star"
    FOR EACH ROW
DECLARE 
    nextval "star"."id"%TYPE;
    rows_found NUMBER;
BEGIN
    IF :NEW."id" IS NULL THEN
        nextval := "star_pk_num".NEXTVAL;
        SELECT count(*) INTO rows_found FROM "star" WHERE "id" = nextval;

        WHILE rows_found >= 1 LOOP
            nextval := "star_pk_num".NEXTVAL;
            SELECT count(*) INTO rows_found FROM "star" WHERE "id" = nextval;
        END LOOP;

        :NEW."id" := nextval;
    END IF;
END;
/

-- in this case some stars with IDs 1 to 5 already exist in the database, the trigger should automatically assign ID 6 to the new row
INSERT INTO "star" ("name", "planetary_system_id", "type") VALUES ('Altair', 1, 'White dwarf');
--SELECT * FROM "star";

-- TRIGGER no. 2: update crew size after reallocating jedi

CREATE OR REPLACE TRIGGER jedi_on_board
    AFTER UPDATE OF "on_board" ON "jedi" 
    FOR EACH row
BEGIN
  UPDATE "spaceship" SET "crew_size" = "crew_size" - 1
  WHERE "id" = :OLD."on_board";
  UPDATE "spaceship" SET "crew_size" = "crew_size" + 1
  WHERE "id" = :NEW."on_board";
END;
/

-- reallocate Anakin Skywalker from spaceship ID 2 to spaceship ID 45
UPDATE "jedi" SET "on_board" = 45 WHERE "imperial_identification_number" = '12345-abcd-abcd-abcd';
-- SELECT * FROM "jedi";
-- SELECT * FROM "spaceship";


-- procedures

-- PROCEDURE no. 1: count number of habitable planets in a planetary system passed in by its id

CREATE OR REPLACE PROCEDURE count_habitable_planets_in_system ("ps_id" NUMBER)
IS
    planet_counter NUMBER := 0;
    planetary_system_id_exists NUMBER;
    planetary_system_name "planetary_system"."name"%TYPE;
    CURSOR habitable_planet_count
    IS
        SELECT PS."name" AS "planetary_system_name"
        FROM "planetary_system" PS, "star" S, "orbits_around" O, "planet" P
        WHERE PS."id" = "ps_id" AND PS."id" = S."planetary_system_id" AND S."id" = O."star_id" AND O."planet_id" = P."id" AND P."habitable" = 1;
BEGIN 
    SELECT count(*) INTO planetary_system_id_exists FROM "planetary_system" PS WHERE PS."id" = "ps_id";
 
    -- check ps_id argument
    IF (planetary_system_id_exists = 0) THEN
        RAISE_APPLICATION_ERROR(-20200, 'NONEXISTANT PLANETARY SYSTEM!');
    END IF;

    FOR planetary_system_row
    IN habitable_planet_count
    LOOP
        planet_counter := planet_counter + 1;
    END LOOP;
    DBMS_OUTPUT.put_line('System' || planetary_system_name || ' has ' || planet_counter || ' habitable planets.');
END;
/

BEGIN
    count_habitable_planets_in_system(3);
END;
/

-- PROCEDURE no. 2: print jedis with midichlorian count greater than specified value who are roaming through space in spaceships of a certain fleet

CREATE OR REPLACE PROCEDURE jedis_in_fleet ("f_id" NUMBER, "midi_count" NUMBER)
IS
    NO_JEDI_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT (NO_JEDI_FOUND, -20160);
    jedi_counter NUMBER := 0;
    fleet_id_exists NUMBER;
    CURSOR jedis
    IS
        SELECT J.*
        FROM "fleet" F, "spaceship" S, "jedi" J
        WHERE F."id" = S."fleet_id" AND S."id" = J."on_board" AND F."id" = "f_id" AND J."midichlorian_count" >= "midi_count";
BEGIN

    -- check f_id argument
    SELECT count(*) INTO fleet_id_exists FROM "fleet" F WHERE F."id" = "f_id";
    IF (fleet_id_exists = 0) THEN
        RAISE_APPLICATION_ERROR(-20201, 'NONEXISTANT FLEET!');
    END IF;

    -- check midi_count argument
    IF "midi_count" < 7000 THEN
        RAISE_APPLICATION_ERROR(-20301, 'GIVEN MIDICHLORIAN COUNT IS TOO LOW FOR A JEDI!');
    END IF;

    DBMS_OUTPUT.put_line('Jedis in fleet with midichlorian count greater than ' || "midi_count" || ':');

    FOR jedi_row
    IN jedis
    LOOP
        DBMS_OUTPUT.put_line(jedi_row."name" || ' ' || jedi_row."surname");
        jedi_counter := jedi_counter + 1;
    END LOOP;

    -- raising user defined exception
    IF jedi_counter = 0 THEN
        RAISE NO_JEDI_FOUND;
    END IF;

EXCEPTION
    WHEN NO_JEDI_FOUND THEN
        DBMS_OUTPUT.put_line('No jedi found on board any fleet''s spaceship.');
END;
/

BEGIN
    jedis_in_fleet(1, 7000);
END;
/

-- explain plans

-- show sum of crew sizes of spaceships in every fleet
EXPLAIN PLAN FOR
  SELECT F."name" AS "fleet_name", S."type" AS "spaceship_type", sum(S."crew_size") AS "fleet_crew_size" 
  FROM "fleet" F, "spaceship" S
  WHERE F."id" = S."fleet_id"
  GROUP BY F."name", S."type"
  ORDER BY F."name", S."type";
SELECT plan_table_output FROM TABLE (DBMS_XPLAN.DISPLAY());


-- index using spaceship information for query acceleration
CREATE INDEX "fleet_spaceships" ON "spaceship" ("fleet_id", "type", "crew_size");

EXPLAIN PLAN FOR
  SELECT F."name" AS "fleet_name", S."type" AS "spaceship_type", sum(S."crew_size") AS "fleet_crew_size" 
  FROM "fleet" F, "spaceship" S
  WHERE F."id" = S."fleet_id"
  GROUP BY F."name", S."type"
  ORDER BY F."name", S."type";
SELECT plan_table_output FROM TABLE (DBMS_XPLAN.DISPLAY());


-- materialized view

-- When using materialized view, a local (read-only) copy of data
-- is fetched from a remote server. Any changes made on server side
-- will not affect the local data until the 'commit' command is called.

-- count how many fleets are orbiting a planet
CREATE MATERIALIZED VIEW "fleets_orbiting_planet"
REFRESH ON COMMIT AS
SELECT P."name" AS "planet_name", count(F."id") AS "fleet_count"
FROM "fleet" F, "planet" P
WHERE F."orbits_planet" = P."id"
GROUP BY P."name";

-- display materialized view result
SELECT * from "fleets_orbiting_planet";

-- change data on server
UPDATE "planet" SET "name" = 'Nueva' WHERE "id" = 2;

-- display unchanged materialized view result
SELECT * from "fleets_orbiting_planet";

-- update materialized view
COMMIT;

-- display updated materialized view result
SELECT * from "fleets_orbiting_planet";


-- permissions for other user

-- tables permission
GRANT ALL ON "planetary_system" TO xklhuf01;
GRANT ALL ON "star_type" TO xklhuf01;
GRANT ALL ON "star" TO xklhuf01;
GRANT ALL ON "element" TO xklhuf01;
GRANT ALL ON "star-element" TO xklhuf01;
GRANT ALL ON "orbits_around" TO xklhuf01;
GRANT ALL ON "planet" TO xklhuf01;
GRANT ALL ON "fleet" TO xklhuf01;
GRANT ALL ON "spaceship" TO xklhuf01;
GRANT ALL ON "jedi" TO xklhuf01;

-- procedures permission
GRANT EXECUTE ON jedis_in_fleet TO xklhuf01;
GRANT EXECUTE ON count_habitable_planets_in_system TO xklhuf01;

-- materialized view permission
GRANT ALL ON "fleets_orbiting_planet" TO xklhuf01;