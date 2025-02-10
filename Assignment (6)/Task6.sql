CREATE TABLE EnergyConsumption (
    Date DATE,
    Building VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    "Energy Type" VARCHAR(255),
    Consumption NUMERIC(10, 2),
    "Price Per Unit" NUMERIC(10, 2)
);


COPY EnergyConsumption FROM 'A:/Data/Projects/DEPI/Assignment (6)/energy_consumption.csv' DELIMITER ',' CSV HEADER;


-- SELECT * FROM EnergyConsumption ;





-- Step 1: Create the Building table
CREATE TABLE Building (
    Building_id SERIAL PRIMARY KEY,  -- Unique identifier for each building
    BuildingName VARCHAR(255) NOT NULL,        -- Name of the building
    City VARCHAR(255) NOT NULL,                -- City of the building
    State VARCHAR(255) NOT NULL,               -- State of the building
    Country VARCHAR(255) NOT NULL              -- Country of the building
);

-- Step 2: Create the 'Price' table
CREATE TABLE Price (
    price_id SERIAL PRIMARY KEY,  -- Unique identifier for each price entry
    energy_type VARCHAR(100) NOT NULL,  -- Type of energy (e.g., electricity, gas)
    price_per_unit DECIMAL(10,2) NOT NULL -- Cost per unit of energy
);

-- Step 3: Create the 'Consumption Amount' table
CREATE TABLE Consumption_Amount (
    consumption_id SERIAL PRIMARY KEY,  -- Unique identifier for each consumption record
    building_id INT REFERENCES Building(building_id),  -- Foreign key to Building table
    price_id INT REFERENCES Price(price_id),  -- Foreign key to Price table
    consumption_date DATE NOT NULL,  -- Date of consumption
    amount DECIMAL(10,2) NOT NULL  -- Amount of energy consumed
);

-- Step 4: Insert unique buildings into 'Building' table
INSERT INTO Building (buildingName, City, State, Country)
SELECT DISTINCT building, city, state, country
FROM EnergyConsumption;


-- Step 5: Insert unique prices into 'Price' table
INSERT INTO Price (energy_type, price_per_unit)
SELECT DISTINCT "Energy Type", "Price Per Unit"
FROM EnergyConsumption;

-- Step 6: Insert data into 'Consumption Amount' table
-- INSERT INTO Consumption_Amount (building_id, price_id, consumption_date, amount)
-- SELECT 
--     b.building_id, 
--     p.price_id, 
--     e.date, 
--     e.consumption
-- FROM EnergyConsumption e
-- JOIN Building b ON e.building = b.buildingname AND e.city = b.city AND e.state = b.state AND e.country = b.country
-- JOIN Price p ON e."Energy Type" = p.energy_type AND e."Price Per Unit" = p.price_per_unit;


-- Step 6.1: Using INNER JOIN
INSERT INTO Consumption_Amount (building_id, price_id, consumption_date, amount)
SELECT 
    (SELECT building_id FROM Building WHERE e.building = buildingname AND e.city = city AND e.state = state AND e.country = country) AS building_id,
    (SELECT price_id FROM Price WHERE e."Energy Type" = energy_type AND e."Price Per Unit" = price_per_unit) AS price_id,
    e.date, 
    e.consumption
FROM EnergyConsumption e;







SELECT * FROM Building;

SELECT * FROM Price;

SELECT * FROM Consumption_Amount;

-- SELECT * FROM Consumption_Amount LIMIT 10;









-- SELECT e.building, b.building_id, e."Energy Type", p.price_id 
-- FROM EnergyConsumption e
-- LEFT JOIN Building b ON e.building = b.buildingname AND e.city = b.city AND e.state = b.state AND e.country = b.country
-- LEFT JOIN Price p ON e."Energy Type" = p.energy_type AND e."Price Per Unit" = p.price_per_unit
-- WHERE b.building_id IS NULL OR p.price_id IS NULL;






-- CREATE INDEX idx_building_name ON Building(buildingname);
-- CREATE INDEX idx_price_energy ON Price(energy_type);



-- SELECT buildingname, city, state, country, COUNT(*) 
-- FROM Building 
-- GROUP BY buildingname, city, state, country




-- top Buildings with Highest Energy Consumption
SELECT b.buildingname, SUM(c.amount) AS total_consumption
FROM Consumption_Amount c
JOIN Building b ON c.building_id = b.building_id
GROUP BY b.buildingname
ORDER BY total_consumption DESC
LIMIT 5;


-- WITH ConsumptionTotals AS (
--     SELECT building_id, SUM(amount) AS total_consumption
--     FROM Consumption_Amount
--     GROUP BY building_id
-- )
-- SELECT b.buildingname, c.total_consumption
-- FROM ConsumptionTotals c
-- JOIN Building b ON c.building_id = b.building_id
-- ORDER BY c.total_consumption DESC
-- LIMIT 5;





















