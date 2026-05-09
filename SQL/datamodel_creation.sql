/*
CREATE TABLE country (
country_id SERIAL PRIMARY KEY,
country VARCHAR(100) NOT NULL UNIQUE,
country_code VARCHAR(3) NOT NULL UNIQUE,
capital VARCHAR(100),
continent VARCHAR(50),
land_area_km2 BIGINT
)
CREATE TABLE population (
country_id INT NOT NULL,
year_record INT NOT NULL,
population BIGINT NOT NULL,

PRIMARY KEY (country_id, year_record),
CONSTRAINT fk_population_country

FOREIGN KEY (country_id)
	REFERENCES country(country_id)
);

CREATE TABLE fertility_rate (
country_id INT NOT NULL,
year_record INT NOT NULL,
tfr NUMERIC(4,2) NOT NULL,

CONSTRAINT fk_fertility_country
PRIMARY KEY (country_id, year_record),
	FOREIGN KEY (country_id)
		REFERENCES country(country_id)
)

CREATE TABLE date (
year_record INT PRIMARY KEY
)

ALTER TABLE population
ADD CONSTRAINT fk_date_population
FOREIGN KEY (year_record)
	REFERENCES date(year_record);

ALTER TABLE fertility_rate
ADD CONSTRAINT fk_date_tfr
FOREIGN KEY (year_record)
	REFERENCES date(year_record);
*/