# Retail Sales & Inventory Intelligence System

An end-to-end data analytics project for a bicycle retail company operating 3 stores across New York, California and Texas. Built using Excel, MySQL and Power BI.

---

## 🔗 Live Dashboard
[View Power BI Dashboard](https://app.powerbi.com/view?r=eyJrIjoiYzMyYmIzMGMtZGIzZi00ZGQxLWFiNjktYzdmYTNiYmQzYjcwIiwidCI6ImQxZjE0MzQ4LWYxYjUtNGEwOS1hYzk5LTdlYmYyMTNjYmM4MSIsImMiOjEwfQ%3D%3D)

---

## Dataset
9 tables — orders, order items, customers, products, brands, categories, stores, staffs, stocks
| Metric | Value |
|---|---|
| Orders | 1,615 |
| Customers | 1,445 |
| Products | 321 |
| Order Line Items | 4,722 |
| Date Range | Jan 2016 – Mar 2018 |

---

## What Was Built

**Excel** — Cleaned all 9 raw CSV files, handled null values, standardized date formats, added computed columns, and performed exploratory data analysis with descriptive statistics, null analysis, outlier detection and pivot summaries.

**MySQL** — Designed a relational schema with foreign key constraints, wrote 12 analytical queries covering store revenue, staff performance, category profitability, delayed shipments, inventory health and customer segmentation. Created 5 SQL views as the data layer for Power BI.

**Power BI** — Built a 5-page interactive dashboard connected to the SQL views with DAX measures, synced slicers, drill-through, and time intelligence for year-over-year and month-over-month comparisons.

---

## Key Findings

- **Baldwin Bikes (NY) generates 70.6% of total revenue** despite being 1 of 3 stores — a concentration risk the business needs to address
- **100% of customers are one-time buyers** — not a single repeat purchase across 3 years, pointing to a complete absence of customer retention
- **166 products at critical stock levels** across all stores, including in the highest margin category — Electric Bikes

---

## Dashboard Pages
| Page | What It Shows |
|---|---|
| Executive Overview | Revenue KPIs, monthly trend, category breakdown |
| Store & Regional Performance | Store revenue comparison, brand matrix, YoY growth |
| Staff & Operations | Staff leaderboard, orders handled, delayed shipments |
| Inventory Health | Critical stock items, stock vs sales scatter, RAG status |
| Customer Intelligence | Customer segments, top spenders, geographic distribution |

---

## Files in This Repository
| File | Description |
|---|---|
| `Retail_Sales_Final_Workbook.xlsx` | Cleaned data and EDA in Excel |
| `01_create_tables.sql` | Database schema with FK constraints |
| `02_insert_lookup_data.sql` | Lookup table inserts |
| `03_verify_row_counts.sql` | Data validation queries |
| `04_analytical_queries.sql` | 12 business analysis queries |
| `05_views.sql` | 5 SQL views for Power BI |
| `Retail_Intelligence_Dashboard.pbix` | Power BI dashboard file |
| `Retail_Project_Final_Report.docx` | Full project report |

---

## Tools Used
`Excel` `MySQL` `MySQL Workbench` `Power BI` `DAX` `SQL Window Functions`
