-- ═════════════════════════════════════════════════════════════════
-- STEP 0: Create and select Database
-- ═════════════════════════════════════════════════════════════════
CREATE DATABASE IF NOT EXISTS psx_dashboard;
USE psx_dashboard;

-- Drop existing tables in reverse dependency order
DROP TABLE IF EXISTS fact_sector_daily;
DROP TABLE IF EXISTS fact_stock_prices;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_company;
DROP TABLE IF EXISTS dim_sector;

-- ═════════════════════════════════════════════════════════════════
-- STEP 1: Create dim_sector
-- ═════════════════════════════════════════════════════════════════
CREATE TABLE dim_sector (
    sector_id   INT PRIMARY KEY AUTO_INCREMENT,
    sector_name VARCHAR(50) NOT NULL UNIQUE
);

-- ═════════════════════════════════════════════════════════════════
-- STEP 2: Create dim_company
-- ═════════════════════════════════════════════════════════════════
CREATE TABLE dim_company (
    company_id   INT PRIMARY KEY AUTO_INCREMENT,
    sector_id    INT NOT NULL,
    ticker       VARCHAR(20) NOT NULL UNIQUE,
    company_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (sector_id)
        REFERENCES dim_sector(sector_id)
);

-- ═════════════════════════════════════════════════════════════════
-- STEP 3: Create dim_date (Backticks applied to reserved keywords)
-- ═════════════════════════════════════════════════════════════════
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY AUTO_INCREMENT,
    `date` DATE NOT NULL UNIQUE,
    `year` INT NOT NULL,
    `month` INT NOT NULL,
    quarter INT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    year_month_str VARCHAR(10) NOT NULL
);
-- ═════════════════════════════════════════════════════════════════
-- STEP 4: Create fact_stock_prices	
-- ═════════════════════════════════════════════════════════════════
CREATE TABLE fact_stock_prices (
    stock_fact_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id    INT NOT NULL,
    date_id       INT NOT NULL,
    open_price    DECIMAL(10,2),
    high_price    DECIMAL(10,2),
    low_price     DECIMAL(10,2),
    close_price   DECIMAL(10,2),
    volume        BIGINT,
    daily_return  DECIMAL(8,4),
    FOREIGN KEY (company_id)
        REFERENCES dim_company(company_id),
    FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id)
);

-- ═════════════════════════════════════════════════════════════════
-- STEP 5: Create fact_sector_daily
-- ═════════════════════════════════════════════════════════════════
CREATE TABLE fact_sector_daily (
    sector_fact_id   INT PRIMARY KEY AUTO_INCREMENT,
    sector_id        INT NOT NULL,
    date_id          INT NOT NULL,
    avg_close        DECIMAL(10,2),
    avg_daily_return DECIMAL(8,4),
    total_volume     BIGINT,
    avg_volatility   DECIMAL(8,4),
    stock_count      INT,
    FOREIGN KEY (sector_id)
        REFERENCES dim_sector(sector_id),
    FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id)
);

select * from psx_dashboard.dim_sector;
select * from psx_dashboard.fact_sector_daily;
select * from psx_dashboard.fact_stock_prices;
select * from psx_dashboard.dim_date;
select * from psx_dashboard.dim_company;



