--DATA MODELING (SCHEMA)

BEGIN;

CREATE TABLE dim_countries (
    country_code VARCHAR(3),
    country_name VARCHAR(50) UNIQUE NOT NULL,
    capital VARCHAR(50),
    continent VARCHAR(50),
    land_area_km2 NUMERIC(12,2),

    CONSTRAINT pk_countries_cc PRIMARY KEY (country_code)
);

CREATE TABLE dim_year (
    year_record INT,

    CONSTRAINT pk_year PRIMARY KEY (year_record)
);

CREATE TABLE fact_population (
    population_id SERIAL,
    country_code VARCHAR(3) NOT NULL,
    year_record INT NOT NULL,
    population_count BIGINT,

    CONSTRAINT composite_key_year_population PRIMARY KEY (country_code, year_record),
    CONSTRAINT fk_countries_population FOREIGN KEY (country_code) REFERENCES dim_countries(country_code),
    CONSTRAINT fk_year_population FOREIGN KEY (year_record) REFERENCES dim_year(year_record) 
);

CREATE TABLE fact_fertility_rate (
    tfr_id SERIAL,
    country_code VARCHAR(3) NOT NULL,
    year_record INT NOT NULL, 
    tfr NUMERIC(4,2),

    CONSTRAINT composite_key_year_tfr PRIMARY KEY (country_code, year_record),
    CONSTRAINT fk_countries_fertility_rate FOREIGN KEY (country_code) REFERENCES dim_countries(country_code),
    CONSTRAINT fk_year_fertility_rate FOREIGN KEY (year_record) REFERENCES dim_year(year_record)
);

COMMIT;

--USERS, PRIVILIGES, ROLES AND ACCESS MANAGMENT (SECURITY MEASURES)

REVOKE ALL
ON SCHEMA world_population
FROM PUBLIC;

GRANT USAGE
ON SCHEMA world_population
TO etl_agents;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA world_population
TO etl_agents;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA world_population
TO etl_agents;

ALTER DATABASE neondb SET SEARCH_PATH TO world_population, public;

-- COUNTRIES WITH MISSING POP DATA

SELECT dc.country_name, dy.year_record, fp.population_count FROM world_population.dim_countries AS dc
JOIN world_population.fact_population AS fp ON fp.country_code = dc.country_code
JOIN world_population.dim_year AS dy ON fp.year_record = dy.year_record
WHERE fp.population_count IS NULL

-- POP ABSOLUTE GROWTH CHANGE

WITH population_with_lag AS (
    SELECT 
        dc.country_name,
        dc.country_code,
        dy.year_record,
        fp.population_count,

        LAG(fp.population_count) OVER (
            PARTITION BY dc.country_code 
            ORDER BY dy.year_record
        ) AS prev_year_population

    FROM world_population.fact_population fp
    JOIN world_population.dim_countries dc
        ON dc.country_code = fp.country_code
    JOIN world_population.dim_year dy
        ON dy.year_record = fp.year_record
)

SELECT 
    country_name,
    year_record,
    population_count,
    prev_year_population,
    population_count - prev_year_population AS yoy_absolute_change
FROM population_with_lag;