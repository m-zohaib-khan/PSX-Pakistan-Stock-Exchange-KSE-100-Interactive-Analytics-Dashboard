USE psx_dashboard;

-- ═════════════════════════════════════════════════════════════════
-- QUERY 1: Sector Performance Leaderboard
-- Measures overall return, volatility, and rank gap per sector
-- ═════════════════════════════════════════════════════════════════
WITH sector_metrics AS (
    SELECT 
        s.sector_name AS sector,
        COUNT(DISTINCT c.company_id) AS companies,
        ROUND(AVG(f.avg_daily_return) * 252 * 100, 2) AS annual_return_pct,
        ROUND(AVG(f.avg_volatility) * SQRT(252) * 100, 2) AS annual_volatility_pct
    FROM fact_sector_daily f
    JOIN dim_sector s ON f.sector_id = s.sector_id
    LEFT JOIN dim_company c ON s.sector_id = c.sector_id
    GROUP BY s.sector_name
),
ranked_sectors AS (
    SELECT 
        sector,
        annual_return_pct,
        annual_volatility_pct,
        ROUND(annual_return_pct / NULLIF(annual_volatility_pct, 0), 2) AS sharpe_ratio,
        companies,
        RANK() OVER (ORDER BY annual_return_pct DESC) AS return_rank,
        RANK() OVER (ORDER BY annual_return_pct / NULLIF(annual_volatility_pct, 0) DESC) AS sharpe_rank
    FROM sector_metrics
)
SELECT 
    sector,
    annual_return_pct,
    annual_volatility_pct,
    sharpe_ratio,
    companies,
    return_rank,
    sharpe_rank,
    ABS(CAST(return_rank AS SIGNED) - CAST(sharpe_rank AS SIGNED)) AS rank_gap
FROM ranked_sectors
ORDER BY sharpe_ratio DESC;


-- ═════════════════════════════════════════════════════════════════
-- QUERY 2: Monthly Return by Sector
-- Aggregates monthly performance metrics per sector using dim_date
-- ═════════════════════════════════════════════════════════════════
SELECT
    s.sector_name                        AS sector,
    d.year_month_str                     AS yearmonth,
    ROUND(SUM(f.avg_daily_return) * 100, 2) AS monthly_return_pct,
    ROUND(AVG(f.avg_volatility), 4)      AS avg_volatility,
    SUM(f.total_volume)                  AS monthly_volume
FROM fact_sector_daily f
JOIN dim_sector s ON f.sector_id = s.sector_id
JOIN dim_date d   ON f.date_id = d.date_id
GROUP BY s.sector_name, d.year_month_str
ORDER BY s.sector_name, d.year_month_str;


-- ═════════════════════════════════════════════════════════════════
-- QUERY 3: 52-Week High/Low Analysis
-- Calculates company price boundaries over the trailing 52 weeks
-- ═════════════════════════════════════════════════════════════════
SELECT
    s.sector_name                        AS sector,
    c.ticker,
    c.company_name                       AS company,
    MAX(f.high_price)                    AS week52_high,
    MIN(f.low_price)                     AS week52_low,
    ROUND(
        (MAX(f.high_price) - MIN(f.low_price)) / 
        NULLIF(MIN(f.low_price), 0) * 100
    , 2)                                 AS price_range_pct
FROM fact_stock_prices f
JOIN dim_company c ON f.company_id = c.company_id
JOIN dim_sector s  ON c.sector_id = s.sector_id
JOIN dim_date d    ON f.date_id = d.date_id
WHERE d.`date` >= (SELECT DATE_SUB(MAX(`date`), INTERVAL 52 WEEK) FROM dim_date)
GROUP BY s.sector_name, c.ticker, c.company_name
ORDER BY s.sector_name, price_range_pct DESC;


-- ═════════════════════════════════════════════════════════════════
-- QUERY 4: Volume Trend (Institutional Activity)
-- Measures month-over-month volume fluctuations per sector
-- ═════════════════════════════════════════════════════════════════
WITH monthly_vol AS (
    SELECT
        s.sector_name       AS sector,
        d.year_month_str    AS yearmonth,
        SUM(f.total_volume) AS volume
    FROM fact_sector_daily f
    JOIN dim_sector s ON f.sector_id = s.sector_id
    JOIN dim_date d   ON f.date_id = d.date_id
    GROUP BY s.sector_name, d.year_month_str
)
SELECT
    sector,
    yearmonth,
    volume,
    LAG(volume) OVER (
        PARTITION BY sector 
        ORDER BY yearmonth
    ) AS prev_month_volume,
    ROUND(
        (volume - LAG(volume) OVER (PARTITION BY sector ORDER BY yearmonth)) / 
        NULLIF(LAG(volume) OVER (PARTITION BY sector ORDER BY yearmonth), 0) * 100
    , 2) AS volume_change_pct
FROM monthly_vol
ORDER BY sector, yearmonth;


-- ═════════════════════════════════════════════════════════════════
-- QUERY 5: Best & Worst Performing Months per Sector
-- Ranks individual sector months by performance
-- ═════════════════════════════════════════════════════════════════
WITH monthly_returns AS (
    SELECT
        s.sector_name                        AS sector,
        d.year_month_str                     AS yearmonth,
        ROUND(SUM(f.avg_daily_return) * 100, 2) AS monthly_return
    FROM fact_sector_daily f
    JOIN dim_sector s ON f.sector_id = s.sector_id
    JOIN dim_date d   ON f.date_id = d.date_id
    GROUP BY s.sector_name, d.year_month_str
)
SELECT
    sector,
    yearmonth,
    monthly_return,
    RANK() OVER (
        PARTITION BY sector 
        ORDER BY monthly_return DESC
    ) AS best_rank,
    RANK() OVER (
        PARTITION BY sector 
        ORDER BY monthly_return ASC
    ) AS worst_rank
FROM monthly_returns
ORDER BY sector, monthly_return DESC;


-- ═════════════════════════════════════════════════════════════════
-- QUERY 6: Risk-Return Quadrant Classification
-- Categorizes sectors into investment risk profile quadrants
-- ═════════════════════════════════════════════════════════════════
WITH sector_summary_calc AS (
    SELECT 
        s.sector_name AS sector,
        ROUND(AVG(f.avg_daily_return) * 252 * 100, 2) AS annual_return_pct,
        ROUND(AVG(f.avg_volatility) * SQRT(252) * 100, 2) AS annual_volatility_pct
    FROM fact_sector_daily f
    JOIN dim_sector s ON f.sector_id = s.sector_id
    GROUP BY s.sector_name
)
SELECT
    sector,
    annual_return_pct,
    annual_volatility_pct,
    ROUND(annual_return_pct / NULLIF(annual_volatility_pct, 0), 2) AS sharpe_ratio,
    CASE
        WHEN annual_return_pct > 20 AND annual_volatility_pct < 25
            THEN '⭐ IDEAL — High Return Low Risk'
        WHEN annual_return_pct > 20 AND annual_volatility_pct >= 25
            THEN '⚠️ AGGRESSIVE — High Return High Risk'
        WHEN annual_return_pct <= 20 AND annual_volatility_pct < 25
            THEN '🛡️ DEFENSIVE — Low Return Low Risk'
        ELSE '❌ AVOID — Low Return High Risk'
    END AS investment_quadrant
FROM sector_summary_calc
ORDER BY sharpe_ratio DESC;
