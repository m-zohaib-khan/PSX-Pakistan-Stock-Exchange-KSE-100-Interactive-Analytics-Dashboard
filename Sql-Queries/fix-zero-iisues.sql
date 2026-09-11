USE psx_dashboard;

-- ══════════════════════════════════════════════
-- STEP 1: CHECK BEFORE FIXING
-- See how many bad rows exist
-- ══════════════════════════════════════════════

-- Check fact_stock_prices
SELECT
    COUNT(*)                                    AS total_rows,
    SUM(CASE WHEN volume = 0
        THEN 1 ELSE 0 END)                      AS zero_volume_rows,
    SUM(CASE WHEN daily_return = 0
        THEN 1 ELSE 0 END)                      AS zero_return_rows,
    SUM(CASE WHEN volume = 0
             AND daily_return = 0
             AND open_price = close_price
        THEN 1 ELSE 0 END)                      AS non_trading_rows
FROM fact_stock_prices;

-- Check fact_sector_daily
SELECT
    COUNT(*)                                    AS total_rows,
    SUM(CASE WHEN avg_daily_return = 0
        THEN 1 ELSE 0 END)                      AS zero_return_rows,
    SUM(CASE WHEN total_volume = 0
        THEN 1 ELSE 0 END)                      AS zero_volume_rows,
    SUM(CASE WHEN avg_daily_return = 0
             AND total_volume = 0
        THEN 1 ELSE 0 END)                      AS non_trading_rows
FROM fact_sector_daily;


-- ══════════════════════════════════════════════
-- STEP 2: DELETE FROM fact_stock_prices
-- Remove non-trading day rows
-- ══════════════════════════════════════════════

DELETE FROM fact_stock_prices
WHERE
    volume = 0
    AND daily_return = 0
    AND open_price = high_price
    AND high_price = low_price
    AND low_price  = close_price;

-- Check how many rows deleted
SELECT ROW_COUNT() AS rows_deleted_from_fact_stock_prices;


-- ══════════════════════════════════════════════
-- STEP 3: DELETE FROM fact_sector_daily
-- Remove non-trading day rows
-- ══════════════════════════════════════════════

DELETE FROM fact_sector_daily
WHERE
    avg_daily_return = 0
    AND total_volume = 0;

-- Check how many rows deleted
SELECT ROW_COUNT() AS rows_deleted_from_fact_sector_daily;


-- ══════════════════════════════════════════════
-- STEP 4: VERIFY AFTER FIXING
-- Confirm zeros are gone
-- ══════════════════════════════════════════════

-- Verify fact_stock_prices
SELECT
    COUNT(*)                                    AS remaining_rows,
    SUM(CASE WHEN volume = 0
        THEN 1 ELSE 0 END)                      AS zero_volume_remaining,
    SUM(CASE WHEN daily_return = 0
        THEN 1 ELSE 0 END)                      AS zero_return_remaining,
    MIN(volume)                                 AS min_volume,
    MAX(volume)                                 AS max_volume,
    ROUND(MIN(daily_return), 4)                AS min_return,
    ROUND(MAX(daily_return), 4)                AS max_return
FROM fact_stock_prices;

-- Verify fact_sector_daily
SELECT
    COUNT(*)                                    AS remaining_rows,
    SUM(CASE WHEN avg_daily_return = 0
        THEN 1 ELSE 0 END)                      AS zero_return_remaining,
    SUM(CASE WHEN total_volume = 0
        THEN 1 ELSE 0 END)                      AS zero_volume_remaining,
    ROUND(MIN(avg_daily_return), 4)            AS min_return,
    ROUND(MAX(avg_daily_return), 4)            AS max_return,
    MIN(total_volume)                           AS min_volume
FROM fact_sector_daily;


-- ══════════════════════════════════════════════
-- STEP 5: FINAL CLEAN CHECK
-- Should return 0 rows if fix worked
-- ══════════════════════════════════════════════

-- This should return EMPTY result
SELECT
    stock_fact_id,
    company_id,
    open_price,
    close_price,
    volume,
    daily_return
FROM fact_stock_prices
WHERE
    volume = 0
    OR daily_return = 0
LIMIT 10;

-- This should also return EMPTY result
SELECT
    sector_fact_id,
    sector_id,
    avg_daily_return,
    total_volume
FROM fact_sector_daily
WHERE
    avg_daily_return = 0
    OR total_volume = 0
LIMIT 10;