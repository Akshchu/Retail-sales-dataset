# Retail Sales Performance — Stakeholder Report
**Author:** Akshay Vinod  
**Dataset:** Sample Superstore | Source: [Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)  
**Period:** 2019–2022 | **Records:** 9,994 transactions  
**Tools:** Power BI · SQL (MySQL) · DAX · Excel

---

## Executive Summary

This report presents findings from an end-to-end analysis of the Sample Superstore dataset — a widely used retail benchmark covering 4 years of US sales across 3 product categories, 4 regions, and 3 customer segments. An interactive Power BI dashboard was built on a SQL-based ETL pipeline, exposing executive-level KPIs and drill-through views on underperforming segments.

---

## Key Performance Indicators

| Metric | Value |
|---|---|
| **Total Revenue** | $7.59M |
| **Total Profit** | $894K |
| **Profit Margin** | 11.8% |
| **Unique Orders** | 9,983 |
| **Unique Customers** | 793 |
| **Avg Order Value** | $761 |

---

## Findings

### 1. Revenue Trend (2019–2022)
Revenue grew steadily year-over-year, with 2022 being the strongest year. Q4 consistently outperformed all other quarters, driven by holiday-season Electronics and Office Supplies demand. The 3-month rolling average shows a persistent upward trend with low volatility.

### 2. Regional Performance
The **West** region leads in both revenue and total orders. The **South** region, while fourth in revenue, shows the highest profit margin among all regions — suggesting a premium product mix or lower discounting behaviour.

### 3. Category Performance
- **Technology** — highest revenue; Phones and Copiers drive most of the volume
- **Office Supplies** — highest margin sub-categories (Paper, Labels, Envelopes)
- **Furniture** — Tables and Bookcases are **loss-making sub-categories** (negative profit)

### 4. Top 3 Underperforming Sub-Categories (Drill-Through)

| Rank | Sub-Category | Category | Revenue | Profit | Recommendation |
|---|---|---|---|---|---|
| 1 | Fasteners | Office Supplies | $3.0K | $0.4K | Thin margin; bundle with Binders/Paper |
| 2 | Envelopes | Office Supplies | $16.5K | $2.6K | Low volume; include in bulk-stationery offers |
| 3 | Labels | Office Supplies | $12.5K | $1.7K | Low AOV; cross-sell with Office Supplies bundles |

> **Note:** Tables sub-category has the **worst profit margin (−8%)** of all sub-categories and is the primary driver of Furniture losses. This requires immediate pricing and cost review.

---

## Recommendations

1. **Discontinue or reprice Tables** — the sub-category generates negative profit across all regions. Review vendor costs or apply minimum price floors.
2. **Bundle low-revenue Office Supplies** (Fasteners, Labels, Envelopes) into stationery packs to increase average order value and reduce per-unit fulfilment cost.
3. **Double down on Technology in the West region** — highest revenue + highest margin combination. Increase inventory allocation for Q4.
4. **Reduce discounting in Furniture** — average discount of 22% in this category erodes margins. A 5% reduction in discount rate would add ~$45K in profit annually.

---

*Charts: see `01_dashboard_overview.png` and `02_underperformer_drillthrough.png`*  
*SQL: see `sql/01_etl_pipeline.sql` and `sql/02_kpi_queries.sql`*  
*Power BI DAX: see `sql/03_dax_measures.dax`*
