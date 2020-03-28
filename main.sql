--Galaktické impérium 

-- cleanup

DROP TABLE "star-element";
DROP TABLE "orbits_around";
DROP TABLE "star";
DROP TABLE "merchant";
DROP TABLE "warship";
DROP TABLE "colonial";
DROP TABLE "jedi";
DROP TABLE "spaceship";
DROP TABLE "fleet";
DROP TABLE "planet";
DROP TABLE "element";
DROP TABLE "planetary_system";
DROP TABLE "star_type";



-- main body

--TODO
--check
--on delete
--mock data
--null / not null (jsou vazby 0:N nebo 1:N ?), hlavne u FK
--default hodnoty u specializace spaceship
--desetinne mista (density, grav_acceleration)

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
    "group" INTEGER CONSTRAINT "group_nn" NOT NULL
);

CREATE TABLE "star"
(
    "id" INTEGER CONSTRAINT "PK_star" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "star_name_uni" UNIQUE CONSTRAINT "star_name_nn" NOT NULL,
    "planetary_system_id" INTEGER CONSTRAINT "star_planetary_system_id_nn" NOT NULL, 
    "type" VARCHAR(60) CONSTRAINT "star_type_nn" NOT NULL,
    CONSTRAINT "FK_planetary_system_id" FOREIGN KEY ("planetary_system_id") REFERENCES "planetary_system" ("id"),
    CONSTRAINT "FK_star_type" FOREIGN KEY ("type") REFERENCES "star_type" ("type")
);

CREATE TABLE "star-element"
(
    "star_id" INTEGER,
    "atomic_number" INTEGER,
    CONSTRAINT "PK_star-element" PRIMARY KEY ("star_id", "atomic_number"),
    CONSTRAINT "FK_star_id" FOREIGN KEY ("star_id") REFERENCES "star" ("id"),
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
    CONSTRAINT "PK_orbit_planet-star" PRIMARY KEY ("planet_id", "star_id"),
    CONSTRAINT "FK_orbit_planet_id" FOREIGN KEY ("planet_id") REFERENCES "planet" ("id"),
    CONSTRAINT "FK_orbit_star_id" FOREIGN KEY ("star_id") REFERENCES "star" ("id")

);


CREATE TABLE "fleet"
(
    "id" INTEGER CONSTRAINT "fleet_id_PK" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "fleet_name_uni" UNIQUE CONSTRAINT "fleet_name_nn" NOT NULL,
    "orbits_planet" INTEGER,
    CONSTRAINT "FK_orbits_planet" FOREIGN KEY ("orbits_planet") REFERENCES "planet" ("id")
);

CREATE TABLE "spaceship"
(
    "id" INTEGER CONSTRAINT "PK_spaceship_id" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "spaceship_name_uni" UNIQUE CONSTRAINT "spaceship_name_nn" NOT NULL,
    "year_of_manufacture" INTEGER,
    "crew size" INTEGER,
    "fleet_id" INTEGER CONSTRAINT "spaceship_fleet_id_nn" NOT NULL,
    CONSTRAINT "FK_fleet_id" FOREIGN KEY ("fleet_id") REFERENCES "fleet" ("id")
);

CREATE TABLE "jedi"
(
    --todo check
    "imperial_identification_number" CHAR(20) CONSTRAINT "PK_jedi_imperial_id_number" PRIMARY KEY,
    "name" VARCHAR(60) CONSTRAINT "jedi_name_nn" NOT NULL,
    "surname" VARCHAR(60) CONSTRAINT "jedi_surname_nn" NOT NULL ,
    "date_of_birth" DATE,
    "lightsaber_color" VARCHAR(60),
    "midichlorian_count" INTEGER DEFAULT 7000, --todo check x > 7000 , jinak neni jedi 
    "commands_fleet" INTEGER,
    "on_board" INTEGER,
    CONSTRAINT "FK_commands_fleet_id" FOREIGN KEY ("commands_fleet") REFERENCES "fleet" ("id"),
    CONSTRAINT "FK_on_board" FOREIGN KEY ("on_board") REFERENCES "spaceship" ("id")
);

CREATE TABLE "merchant"
(
    "id" INTEGER CONSTRAINT "PK_merchant_id" PRIMARY KEY,
    "cargo_capacity" INTEGER DEFAULT 10000,
    CONSTRAINT "FK_merchant_id" FOREIGN KEY ("id") REFERENCES "spaceship" ("id")
);

CREATE TABLE "warship"
(
    "id" INTEGER CONSTRAINT "PK_warship_id" PRIMARY KEY,
    "starfighter_count" INTEGER DEFAULT 50,
    CONSTRAINT "FK_warship_id" FOREIGN KEY ("id") REFERENCES "spaceship" ("id")
);

CREATE TABLE "colonial"
(
    "id" INTEGER CONSTRAINT "PK_colonial_id" PRIMARY KEY,
    "settlers_capacity" INTEGER DEFAULT 1500,
    CONSTRAINT "FK_colonial_id" FOREIGN KEY ("id") REFERENCES "spaceship" ("id")
);

-- insert mock data

INSERT INTO "planetary-system" ("name") VALUES ("Canis Major");
INSERT INTO "planetary-system" ("name") VALUES ("Orion");

INSERT INTO "star" ("name") VALUES ("Sirius");
INSERT INTO "star" ("name") VALUES ("Rigel");
INSERT INTO "star" ("name") VALUES ("Betelgeuse");

INSERT INTO "element" ("atomic-number", "name", "symbol", "density", "column", "group") VALUES (1, "Hydrogen", "H", 0.089, 1, 1);
INSERT INTO "element" ("atomic-number", "name", "symbol", "density", "column", "group") VALUES (2, "Helium", "He", 0.179, 18, 18);
INSERT INTO "element" ("atomic-number", "name", "symbol", "density", "column", "group") VALUES (6, "Carbon", "C", 2.267, 14, 14);
INSERT INTO "element" ("atomic-number", "name", "symbol", "density", "column", "group") VALUES (16, "Sulfur", "S", 2.071, 16, 16);

INSERT INTO "planet" ("name", "habitable", "radius", "density", "gravitational_index", "moon_count") VALUES ("B-612", 1, 364, 5.23, 8.41, 0);
INSERT INTO "planet" ("name", "habitable", "radius", "density", "gravitational_index", "moon_count") VALUES ("R-4565", 0, 1604, 0.93, 15.41, 2);
INSERT INTO "planet" ("name", "habitable", "radius", "density", "gravitational_index", "moon_count") VALUES ("B-612", 0, 98721, 1.23, 45.41, 3);

INSERT INTO "star-type" ("types") VALUES ("Blue dwarf")
INSERT INTO "star-type" ("types") VALUES ("Red dwarf")
INSERT INTO "star-type" ("types") VALUES ("Sun")
