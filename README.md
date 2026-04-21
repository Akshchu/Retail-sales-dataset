# Project 1: Retail Sales Performance Dashboard

**Author:** Akshay Vinod  
**Dataset:** Sample Superstore | [Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)  
**Tools:** SQL (MySQL) · Power BI · DAX · Excel  
**Records:** 9,994 transactions · 2019–2022

## Dataset Columns Used
`Order ID`, `Order Date`, `Ship Date`, `Ship Mode`, `Customer ID`, `Segment`, `Region`, `State`, `Category`, `Sub-Category`, `Product Name`, `Sales`, `Quantity`, `Discount`, `Profit`

## How to Reproduce
```sql
-- 1. Create DB and load data
CREATE DATABASE superstore;
USE superstore;
-- Load CSV via MySQL Workbench or:
LOAD DATA INFILE '/path/to/SampleSuperstore.csv'
INTO TABLE raw_superstore
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. Run ETL
SOURCE sql/01_etl_pipeline.sql;

-- 3. Run KPI queries
SOURCE sql/02_kpi_queries.sql;
```

## Power BI Setup
1. Connect Power BI Desktop to MySQL
2. Import `fact_sales`, `dim_date`, `dim_customer`, `dim_product`
3. Create relationships on `order_date → date_key`, `customer_id`, `product_id`
4. Paste each DAX block from `sql/03_dax_measures.dax` as a New Measure

## Files
| File | Description |
|---|---|
| `sql/01_etl_pipeline.sql` | Raw → Staging → Star Schema |
| `sql/02_kpi_queries.sql` | 10 KPI queries |
| `sql/03_dax_measures.dax` | Power BI DAX measures |
| `data/SampleSuperstore.csv` | Dataset (schema-matched placeholder) |
| `reports/01_dashboard_overview.png` | Dashboard screenshot |
| `reports/02_underperformer_drillthrough.png` | Drill-through view |
| `reports/stakeholder_report.md` | One-page stakeholder report |
