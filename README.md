# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** 🚀  
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. 
---
## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:


1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---
# SQL Data Warehouse Project (Azure Data Factory + SQL Server)

## 📌 Overview
Designed and implemented a multi‑layer data warehouse solution to analyze sales trends, customer segments, and product contributions for strategic decision‑making. The project integrates **Azure Data Factory pipelines** with **SQL Server** to deliver automated ETL workflows and advanced analytics.

## ⚙️ Tech Stack
- **Databases**: SQL Server (Azure SQL Database)
- **Cloud Services**: Azure Data Factory (ADF)
- **ETL Activities**: Copy, Delete, Stored Procedure, If Condition, ForEach, Trigger
- **SQL Techniques**: Joins, CTEs, Window Functions, Views, Stored Procedures, CASE statements

## 🔄 Workflow
1. **Data Ingestion**: 60,000+ CRM & ERP records ingested into Azure SQL Database.
2. **ETL Automation**: Pipelines orchestrated in ADF for data cleaning, transformation, and scheduling.
3. **Data Modeling**: Multi‑layer warehouse design (staging → core → reporting).
4. **Analytics**: Time‑series, cumulative, and comparative analysis using advanced SQL queries.
5. **Business Insights**: Delivered KPI dashboards and reports for leadership.

## 📊 Key Insights
- December identified as peak month; February lowest sales.
- Bikes category contributed 96% of revenue.
- Majority customers segmented as **New**, followed by **Regular** and **VIP**.
- Product cost distribution skewed toward the $100 range.

## ✅ Recommendations
- Strengthen seasonal campaigns in peak months.
- Diversify beyond Bikes category to reduce dependency.
- Design loyalty programs to convert New/Regular customers into VIPs.
- Optimize pricing strategies for mid‑range products.

## 🚀 Impact
This project demonstrates the ability to:
- Build scalable **ETL pipelines** in Azure Data Factory.
- Apply **advanced SQL** for deep business analysis.
- Translate raw data into **actionable insights** that support organizational growth.

