-- ============================================================
-- PROJECT 1: Retail Sales Performance Dashboard
-- Dataset  : Sample Superstore (Kaggle)
-- Source   : https://www.kaggle.com/datasets/vivek468/superstore-dataset-final
-- Author   : Akshay Vinod
-- File     : 01_etl_pipeline.sql
-- Desc     : Full ETL — raw ingestion → cleaning → star schema
-- ============================================================

-- ── STEP 1: RAW TABLE ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS raw_superstore (
    row_id          INT,
    order_id        VARCHAR(30),
    order_date      VARCHAR(15),
    ship_date       VARCHAR(15),
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(30),
    country         VARCHAR(50),
    city            VARCHAR(100),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region          VARCHAR(20),
    product_id      VARCHAR(20),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(200),
    sales           DECIMAL(10,4),
    quantity        INT,
    discount        DECIMAL(5,2),
    profit          DECIMAL(10,4)
);

-- ── STEP 2: STAGING — Clean & Cast ──────────────────────────
CREATE TABLE IF NOT EXISTS stg_superstore AS
SELECT
    row_id,
    TRIM(order_id)                                  AS order_id,
    STR_TO_DATE(order_date, '%d/%m/%Y')             AS order_date,
    STR_TO_DATE(ship_date,  '%d/%m/%Y')             AS ship_date,
    TRIM(ship_mode)                                 AS ship_mode,
    TRIM(customer_id)                               AS customer_id,
    TRIM(customer_name)                             AS customer_name,
    TRIM(segment)                                   AS segment,
    TRIM(country)                                   AS country,
    TRIM(city)                                      AS city,
    TRIM(state)                                     AS state,
    postal_code,
    TRIM(region)                                    AS region,
    TRIM(product_id)                                AS product_id,
    TRIM(category)                                  AS category,
    TRIM(sub_category)                              AS sub_category,
    TRIM(product_name)                              AS product_name,
    ROUND(sales, 2)                                 AS sales,
    CASE WHEN quantity < 0 THEN 0
         ELSE quantity END                          AS quantity,
    CASE WHEN discount < 0 THEN 0
         WHEN discount > 1 THEN 0
         ELSE discount END                          AS discount,
    ROUND(profit, 2)                                AS profit,
    ROUND(profit / NULLIF(sales, 0) * 100, 2)       AS profit_margin_pct,
    DATEDIFF(
        STR_TO_DATE(ship_date, '%d/%m/%Y'),
        STR_TO_DATE(order_date,'%d/%m/%Y')
    )                                               AS shipping_days,
    YEAR(STR_TO_DATE(order_date,'%d/%m/%Y'))        AS order_year,
    MONTH(STR_TO_DATE(order_date,'%d/%m/%Y'))       AS order_month,
    QUARTER(STR_TO_DATE(order_date,'%d/%m/%Y'))     AS order_quarter,
    MONTHNAME(STR_TO_DATE(order_date,'%d/%m/%Y'))   AS month_name
FROM raw_superstore
WHERE order_id IS NOT NULL
  AND sales > 0;

-- ── STEP 3: DIMENSION TABLES ─────────────────────────────────

-- Dim: Date
CREATE TABLE IF NOT EXISTS dim_date AS
SELECT DISTINCT
    order_date                      AS date_key,
    order_year                      AS year,
    order_month                     AS month,
    month_name,
    order_quarter                   AS quarter,
    CASE
        WHEN order_month IN (12,1,2) THEN 'Winter'
        WHEN order_month IN (3,4,5)  THEN 'Spring'
        WHEN order_month IN (6,7,8)  THEN 'Summer'
        ELSE 'Fall'
    END                             AS season
FROM stg_superstore;

-- Dim: Customer
CREATE TABLE IF NOT EXISTS dim_customer AS
SELECT DISTINCT
    customer_id,
    customer_name,
    segment,
    city,
    state,
    region,
    country
FROM stg_superstore;

-- Dim: Product
CREATE TABLE IF NOT EXISTS dim_product AS
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM stg_superstore;

-- ── STEP 4: FACT TABLE ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS fact_sales AS
SELECT
    s.row_id,
    s.order_id,
    s.order_date,
    s.ship_date,
    s.ship_mode,
    s.customer_id,
    s.product_id,
    s.region,
    s.state,
    s.city,
    s.segment,
    s.category,
    s.sub_category,
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    s.profit_margin_pct,
    s.shipping_days,
    s.order_year,
    s.order_month,
    s.order_quarter,
    s.month_name
FROM stg_superstore s;
