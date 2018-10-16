/* CHAPTER 2: Spatial Data Types */

-- Create chapter schema
CREATE SCHEMA ch02;

-- 1. POINTS
/*
POINT — A point in 2D space specified by its X and Y coordinates
POINTZ — A point in 3D space specified by its X, Y, and Z coordinates 
POINTM — A point in 2D space with a measured value specified by its spatial X and Y coordinates plus an M value
POINTZM — A point in 3D space with a measured value specified by its X, Y, and Z coordinates plus an M value
*/

-- Create a table with all types of points
CREATE TABLE ch02.my_points (
	id serial PRIMARY KEY,
	p geometry(POINT), --XY
	pz geometry(POINTZ), --XYZ
	pm geometry(POINTM),  --XYM -M: measure
	pzm geometry(POINTZM), --XYZM
	p_srid geometry(POINT, 4269) --NAD83 SRID
);

/*
In PostGIS 2.0 and later, you should make use of the subtype type modifier in the type declaration itself, as in geometry (POINT), so that you can create the table in a single step. To draw a parallel example with other PostgreSQL data types, the constraint approach would be akin to declaring a column as varchar and then adding a check constraint that limits the length to be 8 instead of declaring the column as varchar(8) to begin with.

TYPMOD We use the term typmod both as an abbreviation for type modifier and also to refer to the practice of adding type modifiers in parentheses during column creation.
*/

-- Populate table with a single record
INSERT INTO ch02.my_points (
	p,
	pz,
	pm,
	pzm,
	p_srid
)
VALUES (
	ST_GeomFromText('POINT(1 -1)'),
	ST_GeomFromText('POINT Z(1 -1 1)'), --Use the space _ in POINT_Z for cross-compatibility
	ST_GeomFromText('POINT M(1 -1 1)'),
	ST_GeomFromText('POINT ZM(1 -1 1 1)'),
	ST_GeomFromText('POINT(1 -1)', 4269),
);


-- 2. LINESTRINGS 
/*
LINESTRING - 2D, defined by two points
LINESTRINGZ - 3D, defined by two points
LINESTRINGM
LINESTRINGZM - Likewise POINTZM

Called also segments or edges(topology)
Non-simple linestrings cross themselves

Check for simplicity sentence:
SELECT ST_IsSimple(ST_GeomFromText('LINESTRING(2 0, 0 0, 1 1, 1 -1)'));
>> FALSE

*/

CREATE TABLE ch02.my_linestrings (
	id serial PRIMARY KEY,
	name varchar(20),
	my_linestrings geometry(LINESTRING)
)

-- Populate table
INSERT INTO ch02.my_linestrings (name, my_linestrings)
VALUES (
	('OPEN', ST_GeomFromText('LINESTRING(0 0, 1 1, 1 -1)')),
	('CLOSED', ST_GeomFromText('LINESTRING(0 0, 1 1, 1 -1, 0 0)')) -- Closed linestring
);



-- 3. POLYGONS
/*
Polygon = Points enclosed by the linestring + linestring itself

The closed linestring outlining the boundary of the polygon is called the *exterior ring* of the polygon

With polygons, you have the concept of validity. The rings of a valid polygon may only intersect at distinct points—rings can’t overlap each other, and two rings can’t share a common boundary. A polygon whose inner rings partly lie outside its exterior ring is also invalid.

*/

-- Triangular polygon with no holes
ALTER TABLE ch02.my_geometries 
	ADD COLUMN my_polygons geometry(POLYGON),
INSERT INTO ch02.my_geometries (name, my_polygons)
VALUES (
	'TRIANGLE',
	ST_GeomFromText('POLYGON((0 0, 1 1, 1 -1, 0 0))')		
);

-- Polygon with holes
ALTER TABLE ch02.my_geometries
INSERT INTO ch02.my_geometries (name, my_polygons)
VALUES (
	'Square Two Holes',
	ST_GeomFromText(
		'POLYGON( 
			(-0.25 -1.25,-0.25 1.25,2.5 1.25,2.5 -1.25,-0.25 -1.25), 
			(2.25 0,1.25 1,1.25 -1,2.25 0),
			(1 -1,1 1,0 0,1 -1)
		)'

		-- WKT (Well-known Text Representation)
		-- First line: exterior ring
		-- Second and subsequent lines: interior rings
	)
);



-- 4. COLLECTION GEOMETRIES
/*
A collection of geometries groups separate geometries as data types in their own right.

In PostGIS, each of the single geometry subtypes has a collection counterpart:

MULTIPOINT
MULTISTRING
MULTIPOLYGON

When we use the term 3D, we’re almost always referring to coordinate dimensions, not geometry dimensions. PostGIS doesn’t have any 3D geometries. At best, it has 2D geometries living in 3D or 4D coordinate dimensions. In other words, PostGIS has no solids.
*/

-- MULTIPOINTS
-- WKT
MULTIPOINT(-1 1, 0 0, 2 3)
MULTIPOINT((-1 1), (0 0), (2 3)) -- Also valid
MULTIPOINT Z(0 0 0, 1 1 1, 2 2 2)
MULTIPOINT M(0 0 0, 1 1 1, 2 2 2)
MULTIPOINT ZM(0 0 0 0, 1 1 1 1, 2 2 2 2)

-- MULTILINESTRINGS
/*
Note that because the M coordinate can’t be visually displayed, the MULTILINESTRING and MULTILINESTRING M code examples have the same visual representation.

Simplicity is relevant for all linestring type geometries. Multilinestrings are considered simple if all constituent linestrings are simple and the collective set of linestrings doesn’t intersect each other at any point except boundary points. For example, if you create a multilinestring with two intersecting simple linestrings, the resultant multilinestring isn’t simple.
*/

-- WKT: mind the parens
MULTILINESTRING((0 0, 0 1, 1 1), (-1 1, -1 -1))
MULTILINESTRING ZM ((0 0 1 1, 0 1 1 2, 1 1 1 3), (-1 1 1 1, -1 -1 1 2))
MULTILINESTRING M((0 0 1, 0 1 2, 1 1 3), (-1 1 1, -1 -1 2))

-- MULTIPOLYGONS
/*
The WKT of multipolygons has even more parentheses than its singular counterpart. Because you use parentheses to represent each ring of a polygon, you’ll need another set of outer parentheses to represent multipolygons. With multipolygons, we highly recommend that you follow the PostGIS conventions and not omit any inner parentheses for single-ringed polygons.

For a multipolygon to qualify as valid, it must pass two tests: 

	- Each constituent polygon must be valid in its own right. 
	- Constituent polygons can’t overlap. Once you lay down a polygon, subsequent polygons can’t be laid on top.

*/

MULTIPOLYGON( 
	((2.25 0, 1.25 1, 1.25 -1, 2.25 0)), 
	((1 -1, 1 1, 0 0, 1 -1))
)
MULTIPOLYGON Z( 
	((2.25 0 1, 1.25 1 1, 1.25 -1 1, 2.25 0 1)), 
	((1 -1 2, 1 1 2, 0 0 2, 1 -1 2))
)
MULTIPOLYGON ZM( 
	((2.25 0 1 1, 1.25 1 1 2, 1.25 -1 1 1, 2.25 0 1 1)),
	((1 -1 2 1, 1 1 2 2, 0 0 2 3, 1 -1 1 4))
)
MULTIPOLYGON M( 
	((2.25 0 1, 1.25 1 2, 1.25 -1 1, 2.25 0 1)), 
	((1 -1 1, 1 1 2, 0 0 3, 1 -1 4))
)

-- GEOMETRYCOLLECTION
/*
The geometrycollection is a PostGIS geometry subtype that can contain heterogeneous geometries. Unlike multi-geometries, where the constituent geometries must be of the same subtype, geometrycollection can include points, linestrings, polygons, and their collection counterparts. It can even contain other geometrycollections. In short, you can stuff every geometry subtype known to PostGIS into a geometrycollection.

A geometrycollection is considered valid if all the geometries in the collection are valid. It’s invalid if any of the geometries in the collection are invalid.
*/

SELECT ST_AsText(ST_Collect(g))
FROM (
	SELECT ST_GeomFromText('MULTIPOINT(-1 1, 0 0, 2 3)') AS g
	UNION ALL
	SELECT ST_GeomFromText(
		'MULTILINESTRING((0 0, 1 1, 2 2), (0 0, 3 3, 4 4))'
	) AS g
	UNION ALL
	SELECT ST_GeomFromText(
		'POLYGON( 
			(-0.25 -1.25, -0.25 1.25, 2.5 1.25, 2.5 -1.25, -0.25 -1.25),
			(2.25 0, 1.25 1, 1.25 -1, 2.25 0),
			(1-1,11,00,1-1)
		)'
	) AS g
)
--OUTPUT
>>GEOMETRYCOLLECTION( 
	MULTIPOINT(-1 1, 0 0, 2 3), 
	MULTILINESTRING((0 0, 0 1, 1 1), (-1 1, -1 -1)), 
	POLYGON(
		(-0.25 -1.25, -0.25 1.25, 2.5 1.25, 2.5 -1.25, -0.25 -1.25),
		(2.25 0,1.25 1,1.25 -1,2.25 0),
		(1-1,11,00,1-1)
	)
)



-- The M coordinate
/* 

The M coordinate is an additional coordinate added for the convenience of recording measured values taken at various points along spatial coordinates. The benefit of using M to store additional information becomes clear as soon as you move beyond points. Suppose that you have a linestring made up of many points, each with its own measure. Without the M coordinate, you’d always need an additional table to store the measurement data.

The M coordinates of a geometry are unchanged when you transform a geometry to another spatial reference system. All functions of PostGIS that work with M treat the coordinate as linear, allowing you to interpolate along the M dimension.

*/

-- The Z coordinate
/*
PostGIS 2.0 also introduced the nD spatial index, which considers the Z coordinate. The default spatial index ignores the Z coordinate.
*/



-- Polyhedral surfaces
/*
Although polygons make up both multipolygons and polyhedral surfaces, there is one fundamental difference: polygons in multipolygons can’t share edges; polygons in a polyhedral surface almost always do. There are two other notable restrictions in the construction of polyhedral surfaces: polygons can’t overlap, and each edge can be mated with at most one other edge.
*/
-- WKT
SELECT ST_GeomFromText(
	'POLYHEDRALSURFACE Z (
		((12 0 10, 8 8 10, 8 10 20, 12 2 20, 12 0 10)),
		((8 8 10, 0 12 10, 0 14 20, 8 10 20, 8 8 10)),
		((0 12 10, -8 8 10, -8 10 20, 0 14 20, 0 12 10))
	)'
);
-- SFCGAL
SELECT ST_Extrude(ST_GeomFromText(
	'LINESTRING(12 0 10, 8 8 10, 0 12 10,-8 8 10)',
	0, 2, 10
));


-- TIN: Triangular Irregular Network
/*
A subset of polyhedral surfaces where all the constituent polygons must be triangles. TINs are widely used to describe terrain surfaces.

The most common form of triangulation used in GIS is Delaunay triangulation.
*/
-- WKT
SELECT ST_GeomFromText(
	'TIN Z ( 
		((12 2 20, 8 8 10, 8 10 20, 12 2 20)), 
		((12 2 20, 12 0 10, 8 8 10, 12 2 20)),
		((8 10 20, 0 12 10, 0 14 20, 8 10 20)), 
		((8 10 20, 8 8 10, 0 12 10, 8 10 20))
	)'
);



-- CURVED GEOMETRIES
/*
Curved geometries aren’t as mature as other geometries and aren’t widely used.

Few third-party tools, either open source or commercial, currently support curved geometries.

For simplicity, you can think of curved geometries in PostGIS as geometries with arcs. To build an arc, you must have exactly three distinct points. The first and last points denote the starting and ending points of the arc. The point in the middle is called the control point because this point controls the degree of curvature of the arc.
*/

-- CIRCULARSTRING
/*
A series of one or more arcs where the endpoint of one is the starting point of another makes up a geometry called a circularstring.

A circularstring must have an odd number of points. 
*/
-- WKT
ALTER TABLE ch02.my_geometries ADD COLUMN my_circular_strings geometry(CIRCULARSTRING);
INSERT INTO ch02.my_geometries(name, my_circular_strings)
VALUES
	('Circle', 
		ST_GeomFromText('CIRCULARSTRING(0 0, 2 0, 2 2, 0 2, 0 0)')),
	('Half circle',
		ST_GeomFromText('CIRCULARSTRING(2.5 2.5, 4.5 2.5, 4.5 4.5)')),
	('Several arcs',
		ST_GeomFromText('CIRCULARSTRING(5 5, 6 6, 4 8, 7 9, 9.5 9.5, 11 12, 12 12)'));


-- COMPUNDCURVE
/*
CIRCULARSTRINGS and linestrings in series make up a collection geometry subtype called COMPOUNDCURVEs. A polygon constructed using a compoundcurve is called a CURVEPOLYGON.


*/
-- WKT
ALTER TABLE ch02.my_geometries ADD COLUMN my_compound_curves geometry(COMPOUNDCURVE); 
INSERT INTO ch02.my_geometries (name, my_compound_curves) 
VALUES (
	'Road with curve',
	ST_GeomFromText(
		'COMPOUNDCURVE( 
			(2 2, 2.5 2.5), 
			CIRCULARSTRING(2.5 2.5, 4.5 2.5, 3.5 3.5),
			(3.5 3.5, 2.5 4.5, 3 5)
		)'
	) 
);
-- NOTE: As you can see in the WKT in listing, the CIRCULARSTRING portion of the curve is identified as such, and the rest of the components are linestrings. You might be tempted to make everything clearer by adding the word LINESTRING, but refrain from doing so because you’ll get an error.

-- CURVEPOLYGONS
/*
A curvepolygon is a polygon that has exterior or inner rings of circularstrings. 
*/
-- WKT
ALTER TABLE ch02.my_geometries ADD COLUMN my_curve_polygons geometry(CURVEPOLYGON);
INSERT INTO ch02.my_geometries (name, my_curve_polygons)
VALUES
	('Solid circle', 
		ST_GeomFromText('CURVEPOLYGON( 
			CIRCULARSTRING(0 0, 2 0, 2 2, 0 2, 0 0)
	)')),
	('Circles with triangle hole', 
		ST_GeomFromText('CURVEPOLYGON( 
			CIRCULARSTRING(2.5 2.5, 4.5 2.5, 4.5 3.5, 2.5 4.5, 2.5 2.5),
			(3.5 3.5, 3.25 2.25, 4.25 3.25, 3.5 3.5)
	)')),
	('Triangle with arcish hole', 
		ST_GeomFromText('CURVEPOLYGON( 
			(-0.5 7, -1 5, 3.5 5.25, -0.5 7), 
			CIRCULARSTRING(0.25 5.5, -0.25 6.5, -0.5 5.75, 0 5.75, 0.25 5.5)
	)'));



--  coord_dimension
/*
COORD_DIMENSION Coord_dimension is the coordinate dimension of the geometry column; permissible values are 2, 3, and 4. Yes, PostGIS supports up to four dimensions: X, Y, Z, M. Don’t forget M.

In spatial speak, there are two kinds of dimensions: the coordinate dimension and
the geometry dimension: 

	The coordinate dimension defines the number of linearly independent axes in your space. Mathematically speaking, the coordinate dimension is the number of vectors forming the basis. For example, geometries that occupy X, Y, Z or X, Y, M have a coordinate dimension of 3. Those that have X, Y, Z, M have a coordinate dimension of 4.

	The geometry dimension describes the size and shape of a geometry. A flat polygon is a two-dimensional geometry because you can speak in terms of length and width. A linestring is a one-dimensional geometry because only the length is a relevant measure. A point, by definition, has zero dimensions
*/

-- SRID
/*
SRID SRID stands for spatial reference identifier and it’s an integer that relates back to the primary key of the spatial_ref_sys table. PostGIS uses this table to catalog all the spatial reference systems available to the database. The spatial_ref_sys table contains the name of the SRS, the parameters needed to reproject from one SRID to another, and the organization that gave rise to the particular SRID. Even though the spatial_ref_sys table has close to 4,000 entries, you’ll encounter plenty of instances where you have to add SRIDs not already in the table. You can also be adventurous and define your own custom SRS and add it to the spatial_ref_sys table in any PostGIS database. 

Be aware of a similar term in GIS lingo called SRS ID (spatial reference system identifier). This identifier adds the authority that created the SRID. For example, the common WGS 84 lon/lat has an SRID of 4326 but an SRS ID of EPSG:4326, where EPSG stands for European Petroleum Survey Group (www.epsg.org). Most of the SRIDs in PostGIS came from EPSG, so the SRID used in the table is by PostGIS convention the same as the EPSG identifier. Keep in mind that the SRID column in spatial_ref_sys is just a user-input (or in this case PostGIS-distributed) primary key in the spatial_ref_sys table. This isn’t the case with all spatial databases, so from database vendor to database vendor you can’t guarantee that SRID 4326 corresponds to the global SRS EPSG:4326.

Prior to PostGIS 2.0, a value of -1 represented the unknown or unspecified SRID.
Since PostGIS 2.0, the default value is 0 to conform to the SQL/MM standard. Should you use the unknown SRID? The answer is no if you’re working with geographic data. If you know the SRS of your data, and presumably you should if you have real geographic data, then you should explicitly specify it. If you’re using PostGIS for non-geographical purposes, such as modeling a localized architecture plan or demonstrating analytic geometry principles, it’s perfectly fine to keep your spatial reference as unknown. For most functions that require an SRID, you can leave out the SRID and it’ll default to the unknown value. The ST_Transform function is an obvious exception.

Finally, keep in mind that switching SRIDs doesn’t alter the fact that the coordinate system underlying the geometry data type is always Cartesian.
*/

-- CHANGING THE SRID OF AN EXISTING GEOMETRY COLUMN: Should you stamp the wrong SRID on your geometry column, you’ll want to change it to the right SRID. Use the ALTER TABLE syntax as follows:
ALTER TABLE us_states 
ALTER COLUMN geom TYPE geometry(MULTIPOLYGON,4326) 
USING ST_SetSRID(geom,4326);

-- CONVERTING A GEOMETRY COLUMN TO A GEOGRAPHY COLUMN: This example will convert a geometry column called way in osm_roads from its current spatial reference geometry to geography by first transforming and then casting to geography:
ALTER TABLE osm_roads 
ALTER COLUMN way TYPE geography(MULTIPOLYGON,4326)
USING ST_Transform(way,4326)::geography; -- :: = CAST(to_data_type)




-- GEOGRAPHY
/* 
Differences between geography and geometry

Unlike its geometry forebears, geography starts by assuming that all your data is based on a geodetic coordinate system, specifically the WGS 84 lon/lat SRID of 4326. No exceptions. This greatly simplified matters for people using PostGIS on a global scale because lon/lat is a coordinate system familiar to everyone. 

Prior to PostGIS 2.1, geography only supported SRID 4326. In PostGIS 2.1,
geography changed to support any lon/lat-based spatial reference system. 4326 is still the default, and if no SRID is specified, then 4326 is assumed. 

Because the geography data type is specialized for geodetic applications, you’re going to find yourself missing support for all but the basic subtypes of points, linestrings, and polygons. Furthermore, don’t expect much support for anything above 2D space. PostGIS has yet to enter the space age.



-- RASTERS
/*
Rasters organize information using pixels; pixels, sometimes called cells, form the basis of rasters. Unlike when you’re shopping for a color TV, the actual shape and size of the pixels don’t matter for database applications. Each pixel is really a space holder for data, nothing more.

Pixels are positional designations NOT data!! The actual data elements rest in bands (sometimes known as channels or dimensions). On your RGB TV raster, you can have three bands of data—one for each of the primary colors. PostGIS rasters can have as many as 255 bands in PostGIS 2.0, and even more in later versions.

Rasters are more than pretty JPEGs and LCD displays—they’re a powerful way to organize data.

GIS makes frequent use of georeferenced rasters. Pixels in a georeferenced raster
correspond to actual geographical locations, and the physical size of the pixels takes on a real unit of measure. You can even assign an SRID to a georeferenced raster. For example, when flattened out, the globe can be modeled as a raster with 360 vertical columns and 180 horizontal rows for a total of 64,800 pixels. Each pixel is one degree high and one degree wide. This example has conveniently created a raster data structure that has geographic meaning.

-- Properties

PostGIS raster data is stored in a table with a column of type raster. Data is usually evenly tiled so that one row holds the same rectangular size of pixels as other rows. We recommend that you keep each row between 50 and 500 pixels for both width and height. You’ll experience faster processing if you break large rasters into tiles for storage in multiple rows rather than keeping them in a single row. The raster2pgsql loader packaged with PostGIS is capable of taking larger rasters and chunking them into smaller tiles for database storage.

-Width and height: measured in pixels.

-Bands: raster can have multiple bands (up to 255) and minimum 1.

-Band pixel types: Rasters can only store numeric values in their pixels. The number of bands determines the number of values that each pixel can store. For example, a 100-band raster can store 100 values in each pixel; an RGB raster can store 3.

Pixel types describe the type of numbers that a given band in a pixel can accommodate. There are several possible choices:

 1-bit Boolean, abbreviated as 1BB 
 Unsigned integer of 2, 8, 16, or 32 bits, abbreviated as 2BUI, 8BUI, 16BUI, 32BUI 
 Signed integers of 8, 16, or 32 bits, abbreviated as 8BSI, 16BSI, 32BSI 
 Two float types of 32 bits and 64 bits, abbreviated as 32BF and 64BF

The most common pixel type by far is 8BUI. Each band has a single pixel type defined for all pixels. You can’t vary the pixel type except across bands. Use the ST_BandPixelType function to obtain the pixel type of a specific band. 

-Rasters and SRIDs
Georeferenced rasters have spatial coordinates defined within a spatial reference system and therefore have an SRID to denote the SRS. Transformation functions are available to convert rasters from one SRS to another.

- Pixel width and height
For georeferenced rasters, pixels do have heights and widths that reflect units of measure. For example, if you’re using a raster to represent downtown Manhattan’s grid of streets and avenues, the width of your cell would be 274 meters and the height would be 80 meters (the typical area of a city block). 

Two functions are useful for reading off a pixel’s width and height: ST_PixelWidth
and ST_PixelHeight.

- Pixel scale
In order to reference a particular pixel on a raster, you must have some pixel-numbering convention relative to spatial coordinates. This convention is generally positive in the X direction and negative in the Y direction of coordinate space, though it need not be. A raster’s pixel cell numbering always starts at the top-left corner of the tile rectangle, whereas when we talk about coordinate space we generally start numbering from the bottom-left corner. A negative Y pixel scale means increasing pixel row cell numbers correspond to decreasing Y spatial coordinates, and a positive X pixel scale means increasing column cell numbers correspond to increasing X coordinates. 

If you assign a unit grid to your rasters, you can speak in terms of scale for georeferenced rasters. For the Manhattan raster example, the width of each pixel represents 274 meters, so it would be said to have an X scale of 1:274. Similarly, the Y scale is 1:80. You often encounter scales on a printed map. If you use a unit grid of 1 mm to map Manhattan, then each block would occupy 274 by 80 mm on paper, and the map could be said to have a 1:1000 scale.

- Skew X and Y
The skew values are generally 0. Most rasters are aligned with the spatial reference coordinate axis, but on occasion they may be rotated, and the skew angle would define the rotation from the geocoordinate axis.

*/