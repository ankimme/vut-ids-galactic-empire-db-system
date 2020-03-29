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

INSERT INTO "star" ("id", "name", "planetary_system_id", "type") VALUES (1, 'Sirius', 1, 'White dwarf');
INSERT INTO "star" ("id", "name", "planetary_system_id", "type") VALUES (2, 'Rigel', 2, 'Blue supergiant');
INSERT INTO "star" ("id", "name", "planetary_system_id", "type") VALUES (3, 'Betelgeuse', 2, 'Red supergiant');

INSERT INTO "fleet" ("id", "name", "orbits_planet") VALUES (1, 'San Diego', 2);
INSERT INTO "fleet" ("id", "name", "orbits_planet") VALUES (2, 'Boeing', 2);
INSERT INTO "fleet" ("id", "name", "orbits_planet") VALUES (3, 'Lokotos', NULL);

INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (2, 'Cactus', 2008, 720, 1, 'merchant', 4500, null, null);
INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (3, 'Eddi', 2012, 320, 1, 'warship', null, 280, null);
INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (4, 'Marco Polo', 2007, 1570, 1, 'colonial', null, null, 1550);
INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (45, 'Aurelius', 2003, 720, 2, null, null, null, null);
INSERT INTO "spaceship" ("id", "name", "year_of_manufacture", "crew_size", "fleet_id", "type", "cargo_capacity", "starfighter_count", "settlers_capacity") VALUES (6, 'Osiris', 2019, 20, 2, 'merchant', 500, null, null);

INSERT INTO "jedi" ("imperial_identification_number", "name", "surname", "date_of_birth", "lightsaber_color", "commands_fleet", "on_board") VALUES ('12345-abcd-abcd-abcd', 'Anakin', 'Skywalker', (TO_DATE('1960/12/01 20:03:24', 'yyyy/mm/dd hh24:mi:ss')), '#34a1eb', 1, null);
INSERT INTO "jedi" ("imperial_identification_number", "name", "surname", "date_of_birth", "lightsaber_color", "commands_fleet", "on_board") VALUES ('78912-abcd-abcd-abcd', 'Qui-Gon', 'Jinn', (TO_DATE('1954/05/12 15:15:44', 'yyyy/mm/dd hh24:mi:ss')), '#f54e42', 2, null);

-- bond table

INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (1, 1);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (1, 2);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (1, 16);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (2, 1);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (2, 6);
INSERT INTO "star-element" ("star_id", "atomic_number") VALUES (3, 1);

INSERT INTO "orbits_around" ("planet_id", "star_id", "distance") VALUES (1, 2, 4562321);
INSERT INTO "orbits_around" ("planet_id", "star_id", "distance") VALUES (2, 3, 5621);
INSERT INTO "orbits_around" ("planet_id", "star_id") VALUES (3, 2);