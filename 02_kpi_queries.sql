-- ============================================================
-- PROJECT 1: Retail Sales Performance Dashboard
-- Dataset  : Sample Superstore (Kaggle)
-- Source   : https://www.kaggle.com/datasets/vivek468/superstore-dataset-final
-- Author   : Akshay Vinod
-- File     : 02_kpi_queries.sql
-- Desc     : Business KPIs — MoM, YoY, rankings, drill-through
-- ============================================================

-- ── KPI 1: Total Revenue, Profit & Margin by Year ───────────
SELECT
    order_year,
    ROUND(SUM(sales), 2)                                        AS total_revenue,
    ROUND(SUM(profit), 2)                                       AS total_profit,
    COUNT(DISTINCT order_id)                                    AS total_orders,
    COUNT(DISTINCT customer_id)                                 AS unique_customers,
    ROUND(SUM(profit) / NULLIF(SUM(sales),0) * 100, 2)         AS profit_margin_pct,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)            AS avg_order_value
FROM fact_sales
GROUP BY order_year
ORDER BY order_year;

-- ── KPI 2: Month-over-Month Revenue Growth (Window) ─────────
WITH monthly AS (
    SELECT
        order_year,
        order_month,
        month_name,
        SUM(sales)   AS revenue,
        SUM(profit)  AS profit
    FROM fact_sales
    GROUP BY order_year, order_month, month_name
)
SELECT
    order_year,
    order_month,
    month_name,
    ROUND(revenue, 2)                                           AS monthly_revenue,
    ROUND(profit, 2)                                            AS monthly_profit,
    ROUND(LAG(revenue) OVER (ORDER BY order_year, order_month), 2)
                                                                AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_year, order_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY order_year, order_month), 0) * 100
    , 2)                                                        AS mom_growth_pct,
    ROUND(AVG(revenue) OVER (
        ORDER BY order_year, order_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                                       AS rolling_3m_avg
FROM monthly
ORDER BY order_year, order_month;

-- ── KPI 3: YoY Revenue by Category ──────────────────────────
WITH yearly_cat AS (
    SELECT
        order_year,
        category,
        SUM(sales)   AS revenue,
        SUM(profit)  AS profit
    FROM fact_sales
    GROUP BY order_year, category
)
SELECT
    a.category,
    ROUND(a.revenue, 2)                                         AS revenue_2021,
    ROUND(b.revenue, 2)                                         AS revenue_2022,
    ROUND((b.revenue - a.revenue) / NULLIF(a.revenue,0)*100,2) AS yoy_growth_pct,
    ROUND(a.profit, 2)                                          AS profit_2021,
    ROUND(b.profit, 2)                                          AS profit_2022
FROM yearly_cat a
JOIN yearly_cat b ON a.category = b.category
WHERE a.order_year = 2021 AND b.order_year = 2022
ORDER BY yoy_growth_pct;

-- ── KPI 4: Revenue & Profit by Region ────────────────────────
SELECT
    region,
    ROUND(SUM(sales), 2)                                        AS total_revenue,
    ROUND(SUM(profit), 2)                                       AS total_profit,
    COUNT(DISTINCT order_id)                                    AS orders,
    COUNT(DISTINCT customer_id)                                 AS customers,
    ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100, 2)             AS margin_pct,
    RANK() OVER (ORDER BY SUM(sales) DESC)                     AS revenue_rank
FROM fact_sales
GROUP BY region
ORDER BY total_revenue DESC;

-- ── KPI 5: Top 3 Underperforming Sub-Categories (Drill-Through)
WITH sub_perf AS (
    SELECT
        category,
        sub_category,
        ROUND(SUM(sales),2)                                     AS revenue,
        ROUND(SUM(profit),2)                                    AS profit,
        ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100,2)          AS margin_pct,
        COUNT(DISTINCT order_id)                                AS orders,
        ROW_NUMBER() OVER (ORDER BY SUM(sales))                AS rev_rank
    FROM fact_sales
    GROUP BY category, sub_category
)
SELECT
    rev_rank,
    category,
    sub_category,
    revenue,
    profit,
    margin_pct,
    orders,
    CASE
        WHEN profit < 0 THEN 'Loss-making — urgent pricing review'
        WHEN margin_pct < 5 THEN 'Very thin margin — review discounting'
        ELSE 'Low volume — targeted promotion recommended'
    END                                                         AS recommendation
FROM sub_perf
WHERE rev_rank <= 3;

-- ── KPI 6: Customer Segment Performance ──────────────────────
SELECT
    segment,
    ROUND(SUM(sales),2)                                         AS total_revenue,
    ROUND(SUM(profit),2)                                        AS total_profit,
    COUNT(DISTINCT order_id)                                    AS orders,
    COUNT(DISTINCT customer_id)                                 AS customers,
    ROUND(AVG(sales),2)                                         AS avg_order_value,
    ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100,2)              AS margin_pct
FROM fact_sales
GROUP BY segment
ORDER BY total_revenue DESC;

-- ── KPI 7: Repeat Customer Rate ──────────────────────────────
WITH cust_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS num_orders
    FROM fact_sales
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                                    AS total_customers,
    SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END)           AS repeat_customers,
    ROUND(
        SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END)*100.0
        / COUNT(*), 2
    )                                                           AS repeat_rate_pct,
    ROUND(AVG(num_orders),2)                                    AS avg_orders_per_customer
FROM cust_orders;

-- ── KPI 8: Regional × Quarter Revenue Heatmap ────────────────
SELECT
    region,
    CONCAT('Q', order_quarter)                                  AS quarter,
    order_year,
    ROUND(SUM(sales),2)                                         AS revenue,
    ROUND(SUM(profit),2)                                        AS profit,
    COUNT(DISTINCT order_id)                                    AS orders
FROM fact_sales
GROUP BY region, order_quarter, order_year
ORDER BY order_year, order_quarter, revenue DESC;

-- ── KPI 9: Top 10 Products by Revenue ────────────────────────
SELECT
    product_name,
    sub_category,
    category,
    ROUND(SUM(sales),2)                                         AS revenue,
    ROUND(SUM(profit),2)                                        AS profit,
    SUM(quantity)                                               AS units_sold,
    ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100,2)              AS margin_pct,
    RANK() OVER (ORDER BY SUM(sales) DESC)                     AS rank_by_revenue
FROM fact_sales
GROUP BY product_name, sub_category, category
ORDER BY revenue DESC
LIMIT 10;

-- ── KPI 10: Ship Mode Performance & Avg Shipping Days ────────
SELECT
    ship_mode,
    COUNT(DISTINCT order_id)                                    AS orders,
    ROUND(AVG(shipping_days),1)                                 AS avg_shipping_days,
    ROUND(SUM(sales),2)                                         AS revenue,
    ROUND(COUNT(DISTINCT order_id)*100.0/SUM(COUNT(DISTINCT order_id)) OVER (),2)
                                                                AS pct_of_orders
FROM fact_sales
GROUP BY ship_mode
ORDER BY avg_shipping_days;
