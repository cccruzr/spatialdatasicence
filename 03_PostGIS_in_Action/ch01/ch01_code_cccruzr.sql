CREATE EXTENSION postgis;
-- SELECT postgis_full_version();

-- Create schema
CREATE SCHEMA ch01

-- Create franchise lookup table
CREATE TABLE ch01.lu_franchises (
	id char(3) PRIMARY KEY,
	franchise varchar(30)
)

-- Update franchises table
INSERT INTO ch01.lu_franchises(id, franchise)
VALUES
	('BKG', 'Burger King'), ('CJR', 'Carl''s Jr'),
	('HDE', 'Hardee'), ('INO', 'In-N-Out'), 
	('JIB', 'Jack in the Box'), ('KFC', 'Kentucky Fried Chicken'),
	('MCD', 'McDonald'), ('PZH', 'Pizza Hut'), 
	('TCB', 'Taco Bell'), ('WDY', 'Wendy''s');

-- Create restaurants table
CREATE TABLE ch01.restaurants (
	id serial PRIMARY KEY,
	franchise char(3) NOT NULL,
	geom geometry(point, 2163) --EPSG:2163
);

-- Create spatial index on geometry column
CREATE INDEX idx_code_restaurantes_geom 
ON ch01.restaurants
USING gist(geom);

-- Create foreign key relationship between franchises / restaurants
ALTER TABLE ch01.restaurants
ADD CONSTRAINT fk_restaurants_lu_franchises FOREIGN KEY (franchise)
REFERENCES ch01.lu_franchises(id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Index to join the two tables
CREATE INDEX fki_restaurants_franchises ON ch01.restaurants(franchise);


-- Create highways table
CREATE TABLE ch01.highways (
	gid integer NOT NULL,
	feature character varying(80),
	name character varying(120),
	state character varying(2),
	geom geometry(multilinestring, 2163),
	CONSTRAINT pk_highways PRIMARY KEY (gid)
);

-- Add spatial index
CREATE INDEX idx_highways
ON ch01.highways
USING gist(geom);

-- Importing CSV file into a staging table
CREATE TABLE ch01.restaurants_staging (
	franchise text,
	lat double precision,
	lon double precision
);

-- \copy command to import CSV
\copy ch01.restaurants_staging FROM 'C:\Users\Camilo Cruz\Desktop\PostGIS in Action\ch01\data\restaurants.csv' DELIMITER AS ',';
--Run using command line (https://stackoverflow.com/questions/41196030/how-to-use-copy-in-postgresql-with-pgadmin4)
--RESULT--COPY 50002
--SELECT * FROM ch01.restaurants_Staging

/* 
Purpose here is to get the CSV data into a table 
so it can be scrutinized more carefully and write
any additional queries to sanitize the data before 
inserting it in the production table.
*/
INSERT INTO ch01.restaurants(franchise, geom)
SELECT
	franchise,
	ST_Transform(ST_SetSRID(ST_Point(lon, lat), 4326), 2163) AS geom
FROM ch01.restaurants_staging;
--RESULT--INSERT 0 50002
--SELECT * FROM ch01.restaurants

/*
Using command-line shp2pgsql tool into Windows CMD:
shp2pgsql -s 4269:2163 -g geom -I "C:\Users\Camilo Cruz\Desktop\PostGIS in Action\ch01\data\roadtrl020.shp" ch01.highways_staging | psql -h localhost -U postgres -p 5432 -d postgis_in_action

--Check for connection status
--psql -U postgres -d postgis_in_action -c "SELECT postgis_version()"
*/
--SELECT * FROM ch01.highways_staging

-- Populate the highways table with only 'Principal Highways'
INSERT INTO ch01.highways(gid, feature, name, state, geom)
SELECT gid, feature, name, state, ST_Transform(geom, 2163)
FROM ch01.highways_staging
WHERE feature LIKE 'Principal Highway%';
--RESULT--INSERT 0 16433

--Routine maintenance
VACUUM ANALYZE ch01.highways;

----- QUERIES ----- 
-- Query 1:
-- How many fast-food restaurants are within one mile of a highway?
SELECT f.franchise, COUNT(DISTINCT r.id) AS total --Remove duplicates
FROM
	ch01.restaurants AS r 
	INNER JOIN ch01.lu_franchises AS f ON r.franchise = f.id 
	INNER JOIN ch01.highways AS h ON ST_DWithin(r.geom, h.geom, 1609) --Spatial Join 1609 m = 1 mi
GROUP BY f.franchise
ORDER BY total DESC;
--RESULT 
/*
"McDonald"	"5343"
"Burger King"	"3049"
"Pizza Hut"	"2920"
"Wendy's"	"2446"
"Taco Bell"	"2428"
"Kentucky Fried Chicken"	"2371"
"Hardee"	"1077"
"Jack in the Box"	"509"
"Carl's Jr"	"224"
"In-N-Out"	"44"
*/

--Query 2: (OpenJUMP)
--Locate Hardee’s restaurants within a 20-mile buffer of U.S. 
--Route 1 in the state of Maryland.

-- 1-Draw US Route 1
SELECT gid, name, geom
FROM ch01.highways
WHERE name = 'US Route 1' AND state = 'MD';

-- 2 Overlay the 20-mile corridor:
SELECT ST_Union(ST_Buffer(geom, 1609*20))
FROM ch01.highways
WHERE name = 'US Route 1' AND state = 'MD';

-- 3 Position Hardee's in the buffer zone routes
SELECT r.geom
FROM ch01.restaurants AS r
WHERE EXISTS(
	SELECT gid
	FROM ch01.highways
	WHERE
		ST_DWithin(r.geom, geom, 1609*20) AND
		name = 'US Route 1' AND
		state = 'MD' AND
		r.franchise = 'HDE'
);
