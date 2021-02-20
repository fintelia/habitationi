DROP TABLE lots;
DROP TABLE meta_parcels;

create table lots AS select min(PID) as pid,
 GISID as gisid,
 count(PID) as props_in_lot,
 count(distinct BldgNum) as buildings,
 sum(Interior_NumUnits) as units,
 sum(LandArea) as lot_size,
 sum(Interior_LivingArea) as living_size,
 sum(Interior_Bedrooms) as bedrooms,
 address_only as address,
 min(PropertyClass) as type,
 cast(sum(AssessedValue) as integer) as assessed_value,
 cast(sum(PropertyTaxAmount) as float) as tax,
 cast(CASE WHEN Condition_YearBuilt != '0' THEN min(cast(Condition_YearBuilt as integer)) ELSE -1 END as integer) as year_built,
 max(cast(substr(SALEDATE, -4) as integer)) as sale_year,
 cast(sum(CASE WHEN PropertyClass != 'CONDO-BLDG' THEN SalePrice ELSE 0 END) as integer) as sale_price,
 max(Exterior_NumStories) as num_stories,
 max(Exterior_WallHeight) as story_height,
 sum(Parking_Open)+sum(Parking_Covered)+sum(Parking_Garage) as parking_spaces,
 max(Zoning) as zone
from properties 
group by GISID;

-- Create the table joining the parcel data with Geo data.
create table meta_parcels as select * from lots LEFT JOIN parcels on lots.gisid = parcels.ml;
INSERT INTO geometry_columns VALUES ('meta_parcels', 'GEOMETRY', 0, 2, 4326, 'WKB');