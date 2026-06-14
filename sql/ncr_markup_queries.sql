-- ============================================================
-- NCR Mandi-to-Doorstep Markup Analytics
-- File    : sql/ncr_markup_queries.sql
-- Author  : Prachi | DTU DSM MBA 2026
-- Date    : 11 Jun 2026
-- Stack   : MySQL 8.x
--
-- CONTENTS
-- Part 1 : Database and table setup (DDL)
-- Part 2 : Q1 Mandi price baseline
-- Part 3 : Q2 Cross-mandi price gap
-- Part 4 : Q3 Markup by SKU and platform
-- Part 5 : Q4 OOS rate by SKU and platform
-- Part 6 : Verification
--
-- DATA
-- mandi_prices  : 4,102 rows | Agmarknet 2.0 | Nov 2025 to May 2026
-- retail_prices : 99 rows   | Manual audit  | 11 Jun 2026, 5 PM IST
--
-- NOTE ON Q3 AND Q4
-- Retail audit (11 Jun 2026) is 21 days after last Agmarknet
-- data point (21 May 2026). Markup is benchmarked against
-- the last available mandi date, not a same-day comparison.
-- This limitation is documented in docs/methodology.md.
-- ============================================================


-- ============================================================
-- PART 1 : DATABASE AND TABLE SETUP
-- Run this section only on a fresh setup.
-- Tables are already created if you are running queries only.
-- ============================================================

CREATE DATABASE IF NOT EXISTS ncr_markup
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ncr_markup;


CREATE TABLE IF NOT EXISTS mandi_prices (
    id                INT           NOT NULL AUTO_INCREMENT,
    arrival_date      DATE          NOT NULL,
    sku_name          VARCHAR(50)   NOT NULL,
    category          VARCHAR(20)   NOT NULL,
    mandi_name        VARCHAR(50)   NOT NULL,
    zone              VARCHAR(10)   NOT NULL,
    min_price_rs_kg   DECIMAL(10,2) NOT NULL,
    max_price_rs_kg   DECIMAL(10,2) NOT NULL,
    modal_price_rs_kg DECIMAL(10,2) NOT NULL,
    arrival_qty_mt    DECIMAL(10,2) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_mandi (sku_name, mandi_name, arrival_date)
) COMMENT = 'Wholesale mandi prices. Agmarknet 2.0. Nov 2025 to May 2026. 4102 rows.';


CREATE TABLE IF NOT EXISTS retail_prices (
    id               INT           NOT NULL AUTO_INCREMENT,
    capture_date     DATE          NOT NULL,
    platform         VARCHAR(20)   NOT NULL,
    area_name        VARCHAR(50)   NOT NULL,
    city             VARCHAR(20)   NOT NULL,
    sku_name         VARCHAR(50)   NOT NULL,
    category         VARCHAR(20)   NOT NULL,
    listed_price_rs  DECIMAL(10,2) NOT NULL,
    pack_size_g      INT           NOT NULL,
    price_per_kg     DECIMAL(10,2) NOT NULL,
    discount_flag    CHAR(1)       NOT NULL DEFAULT 'N',
    out_of_stock     CHAR(1)       NOT NULL DEFAULT 'N',
    PRIMARY KEY (id),
    UNIQUE KEY uq_retail (sku_name, platform, area_name, capture_date)
) COMMENT = 'Retail prices. Manual audit. 11 Jun 2026. 3 platforms x 4 areas x 11 SKUs. 99 rows.';


-- ============================================================
-- Q1 : MANDI PRICE BASELINE
--
-- Business question:
-- What is the 6-month average wholesale cost per SKU
-- at each NCR mandi?
--
-- Purpose:
-- Establishes the cost anchor for all markup calculations.
-- Volatility column identifies SKUs with most unpredictable
-- wholesale cost, informing dynamic pricing strategy.
-- ============================================================

USE ncr_markup;

SELECT
    sku_name,
    category,
    mandi_name,
    zone,
    COUNT(*)                            AS days_reported,
    ROUND(AVG(modal_price_rs_kg), 2)    AS avg_modal_rs_kg,
    ROUND(MIN(modal_price_rs_kg), 2)    AS min_modal_rs_kg,
    ROUND(MAX(modal_price_rs_kg), 2)    AS max_modal_rs_kg,
    ROUND(STDDEV(modal_price_rs_kg), 2) AS price_stddev,
    ROUND(
        (MAX(modal_price_rs_kg) - MIN(modal_price_rs_kg))
        / MIN(modal_price_rs_kg) * 100
    , 1)                                AS price_swing_pct
FROM mandi_prices
GROUP BY sku_name, category, mandi_name, zone
ORDER BY sku_name, zone;


-- ============================================================
-- Q2 : CROSS-MANDI PRICE GAP
--
-- Business question:
-- Which mandi offers the cheapest wholesale price per SKU,
-- and how much of a premium do other mandis charge?
--
-- Purpose:
-- Surfaces direct sourcing opportunity. Azadpur is cheapest
-- for 10 of 11 SKUs. Cauliflower is the exception where
-- Keshopur is cheapest. A dark store sourcing from Keshopur
-- on Potato pays 53% more than one sourcing from Azadpur.
-- ============================================================

USE ncr_markup;

SELECT
    a.sku_name,
    a.category,
    a.mandi_name,
    a.zone,
    ROUND(a.avg_price, 2)                   AS avg_modal_rs_kg,
    ROUND(b.min_price, 2)                   AS cheapest_mandi_rs_kg,
    ROUND(a.avg_price - b.min_price, 2)     AS premium_over_cheapest_rs,
    ROUND(
        (a.avg_price - b.min_price)
        / b.min_price * 100
    , 1)                                    AS premium_over_cheapest_pct
FROM (
    SELECT
        sku_name,
        category,
        mandi_name,
        zone,
        AVG(modal_price_rs_kg) AS avg_price
    FROM mandi_prices
    GROUP BY sku_name, category, mandi_name, zone
) a
JOIN (
    SELECT
        sku_name,
        MIN(avg_m) AS min_price
    FROM (
        SELECT
            sku_name,
            mandi_name,
            AVG(modal_price_rs_kg) AS avg_m
        FROM mandi_prices
        GROUP BY sku_name, mandi_name
    ) x
    GROUP BY sku_name
) b ON a.sku_name = b.sku_name
ORDER BY a.sku_name, a.avg_price;


-- ============================================================
-- Q3 : MARKUP BY SKU AND PLATFORM
--
-- Business question:
-- How much are Blinkit, Zepto, and Instamart marking up
-- each SKU relative to the NCR mandi wholesale average?
--
-- Purpose:
-- Core analytical output. Identifies highest-margin SKUs
-- and platform-level pricing behaviour. Instamart prices
-- staples closest to wholesale. Blinkit leads on premium
-- SKU markup.
--
-- Baseline: NCR average mandi price on last Agmarknet date
-- (21 May 2026). See methodology note at top of file.
-- ============================================================

USE ncr_markup;

SELECT
    r.sku_name,
    r.category,
    r.platform,
    COUNT(*)                                        AS observations,
    ROUND(AVG(r.price_per_kg), 2)                   AS avg_retail_rs_kg,
    ROUND(AVG(m.avg_mandi_rs_kg), 2)                AS avg_mandi_rs_kg,
    ROUND(
        AVG(r.price_per_kg) - AVG(m.avg_mandi_rs_kg)
    , 2)                                            AS avg_markup_rs,
    ROUND(
        (AVG(r.price_per_kg) - AVG(m.avg_mandi_rs_kg))
        / AVG(m.avg_mandi_rs_kg) * 100
    , 1)                                            AS avg_markup_pct
FROM retail_prices r
JOIN (
    SELECT
        sku_name,
        AVG(modal_price_rs_kg) AS avg_mandi_rs_kg
    FROM mandi_prices
    WHERE arrival_date = (
        SELECT MAX(arrival_date) FROM mandi_prices
    )
    GROUP BY sku_name
) m ON r.sku_name = m.sku_name
WHERE r.out_of_stock = 'N'
GROUP BY r.sku_name, r.category, r.platform
ORDER BY avg_markup_pct DESC;


-- ============================================================
-- Q4 : OOS RATE BY SKU AND PLATFORM
--
-- Business question:
-- Which SKUs go out of stock most often on which platform?
--
-- Purpose:
-- OOS on high-margin SKUs like Capsicum is a double loss:
-- no sale and no margin. Availability is a hidden supply
-- chain cost. Capsicum is OOS on Instamart at 66.7% of
-- capture locations.
-- ============================================================

USE ncr_markup;

SELECT
    sku_name,
    category,
    platform,
    COUNT(*)                                                AS total_observations,
    SUM(CASE WHEN out_of_stock = 'Y' THEN 1 ELSE 0 END)    AS oos_count,
    ROUND(
        SUM(CASE WHEN out_of_stock = 'Y' THEN 1 ELSE 0 END)
        / COUNT(*) * 100
    , 1)                                                    AS oos_rate_pct
FROM retail_prices
GROUP BY sku_name, category, platform
ORDER BY oos_rate_pct DESC, sku_name;


-- ============================================================
-- PART 6 : VERIFICATION
-- Run after loading data to confirm expected row counts.
-- Expected: mandi_prices = 4102, retail_prices = 99
-- ============================================================

USE ncr_markup;

SELECT 'mandi_prices'  AS table_name, COUNT(*) AS row_count FROM mandi_prices
UNION ALL
SELECT 'retail_prices', COUNT(*) FROM retail_prices;
