-- -- Drop tables if they exist to avoid duplication issues
-- DROP TABLE IF EXISTS energy_consumptions CASCADE;
-- DROP TABLE IF EXISTS rates CASCADE;
-- DROP TABLE IF EXISTS building_master CASCADE;
-- DROP TABLE IF EXISTS energy_costs CASCADE;

-- Create Building Master Table (Primary Key on 'building')
CREATE TABLE building_master (
    building VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- Create Energy Consumptions Table
CREATE TABLE energy_consumptions (
    date TIMESTAMP NOT NULL,
    building VARCHAR(10) NOT NULL,
    water_consumption INT DEFAULT 0,
    electricity_consumption INT DEFAULT 0,
    gas_consumption INT DEFAULT 0,
    PRIMARY KEY (date, building),
    FOREIGN KEY (building) REFERENCES building_master(building) ON DELETE CASCADE
);

-- Create Energy Rates Table
CREATE TABLE rates (
    year INT NOT NULL,
    energy_type VARCHAR(20) NOT NULL,
    price_per_unit NUMERIC NOT NULL,
    PRIMARY KEY (year, energy_type)
);

-- Create Indexes for Faster Queries
CREATE INDEX idx_energy_date ON energy_consumptions(date);
CREATE INDEX idx_energy_building ON energy_consumptions(building);
CREATE INDEX idx_rates_year_type ON rates(year, energy_type);

-- Import Data from CSV Files
COPY building_master FROM 'A:\Data\Projects\DEPI\Project 1\Data\Building Master.csv' DELIMITER ',' CSV HEADER;
COPY energy_consumptions FROM 'A:\Data\Projects\DEPI\Project 1\Data\Energy Consumptions Dataset.csv' 
DELIMITER ',' 
CSV HEADER
WHERE date IS NOT NULL;
COPY rates FROM 'A:\Data\Projects\DEPI\Project 1\Data\Rates.csv' DELIMITER ',' CSV HEADER;


-- select * from energy_consumptions;






-- Create a Table for Calculated Monthly Energy Costs
CREATE TABLE energy_costs AS
SELECT 
    ec.date,
    ec.building,
    bm.city,
    bm.country,
    COALESCE(ec.water_consumption * rw.price_per_unit, 0) AS water_cost,
    COALESCE(ec.electricity_consumption * re.price_per_unit, 0) AS electricity_cost,
    COALESCE(ec.gas_consumption * rg.price_per_unit, 0) AS gas_cost
FROM 
    energy_consumptions ec
JOIN 
    building_master bm ON ec.building = bm.building
LEFT JOIN 
    rates rw ON EXTRACT(YEAR FROM ec.date) = rw.year AND rw.energy_type = 'Water'
LEFT JOIN 
    rates re ON EXTRACT(YEAR FROM ec.date) = re.year AND re.energy_type = 'Electricity'
LEFT JOIN 
    rates rg ON EXTRACT(YEAR FROM ec.date) = rg.year AND rg.energy_type = 'Gas';


-- SELECT * FROM energy_costs;




-- Create a Table for Monthly Aggregated Consumption and Costs
CREATE TABLE monthly_energy_summary AS
SELECT 
    ec.building,
    DATE_TRUNC('month', ec.date) AS month,
    SUM(ec.water_consumption) AS total_water,
    SUM(ec.electricity_consumption) AS total_electricity,
    SUM(ec.gas_consumption) AS total_gas,
    SUM(COALESCE(ec.water_consumption * rw.price_per_unit, 0)) AS total_water_cost,
    SUM(COALESCE(ec.electricity_consumption * re.price_per_unit, 0)) AS total_electricity_cost,
    SUM(COALESCE(ec.gas_consumption * rg.price_per_unit, 0)) AS total_gas_cost
FROM 
    energy_consumptions ec
JOIN 
    building_master bm ON ec.building = bm.building
LEFT JOIN 
    rates rw ON EXTRACT(YEAR FROM ec.date) = rw.year AND rw.energy_type = 'Water'
LEFT JOIN 
    rates re ON EXTRACT(YEAR FROM ec.date) = re.year AND re.energy_type = 'Electricity'
LEFT JOIN 
    rates rg ON EXTRACT(YEAR FROM ec.date) = rg.year AND rg.energy_type = 'Gas'
GROUP BY ec.building, month;


-- SELECT * FROM monthly_energy_summary;

select * from energy_consumptions;
SELECT * FROM monthly_energy_summary;
SELECT * FROM energy_costs;



-- -- Top 5 Buildings with Highest Electricity
-- SELECT building, SUM(electricity_consumption) AS total_electricity
-- FROM energy_consumptions
-- GROUP BY building
-- ORDER BY total_electricity DESC
-- LIMIT 5;



-- SELECT 
--     bm.city, 
--     SUM(ec.water_consumption + ec.electricity_consumption + ec.gas_consumption) AS total_consumption
-- FROM energy_consumptions ec
-- JOIN building_master bm ON ec.building = bm.building
-- GROUP BY bm.city
-- ORDER BY total_consumption DESC
-- LIMIT 5;

































