# Supply Chain Analytics Dashboard

**Turning 180,000+ raw e-commerce orders into decisions a supply chain team can actually act on.**

Built end-to-end across Excel, Python, SQL, and Power BI.

---

## 🧩   Overview

A complete analytics project on a global e-commerce supply chain dataset (2015–2018, ~180,000 order records, 5 markets). It answers four questions a real operations team would care about:

- Which markets, categories, and products actually drive revenue and profit?
- Is delivery performance meeting customer expectations?
- Is the discounting strategy helping sales or quietly killing margin?
- How many customers come back — and how many are one-time buyers?

---

## 🎯 The Problem

Supply chain data is easy to collect and hard to trust. Before any of these questions can be answered, the data has to be cleaned, joined correctly across five related tables, and interrogated with real business logic — not just dropped into a dashboard template. This project follows that full path.

---

## 🛠️ Built With

| Stage | Tool |
|---|---|
| Extraction & deduplication | Excel |
| Cleaning & preprocessing | Python (pandas) |
| Database & analysis | SQL |
| Business queries | SQL |
| Dashboard & storytelling | Power BI + DAX |

---

## 🔁 The Workflow

```
Excel  →  Python  →  SQL  →  Power BI
extract    clean      analyze   visualize
& dedupe   & prep      (12 queries)  (3-page report)
```

**Excel** — pulled and de-duplicated the raw data first.
**Python** — null audits, date standardization, feature prep.
**SQL** — 12 business-focused queries using joins, `CASE WHEN` segmentation, window functions (`RANK()`, `LAG()`), CTEs, correlated subqueries, and null-based data quality checks.
**Power BI** — a 3-page report (Executive Dashboard, Sales Analysis, Profitability & Delivery Analysis) with consistent slicers, combo charts, and heatmap matrices.

Full SQL script with comments: `04_SQL_Queries/`

---

## 📊 Key DAX Measures

```dax
Total Sales      = SUM(orders[Total Sales])
Total Orders     = DISTINCTCOUNT(orders[Order Id])
Total Profit     = SUM(orders[Benefit per order])
Profit Margin    = DIVIDE([Total Profit], [Total Sales]) * 100
Avg Discount %   = AVERAGE(orders[Order Item Discount Rate]) * 100
Avg Order Value  = DIVIDE([Total Sales], [Total Orders], 0)

Late Delivery Risk % = 
    DIVIDE(SUM(shipping[Late_delivery_risk]), COUNTROWS(shipping)) * 100
```

---

## 💡 Top Findings

- **Fishing** is the top category by a wide margin — ~$6.9M in sales.
- One product alone accounts for ~$6.93M — the catalog's single most important SKU.
- **Late-delivery risk sits at 54–56% almost every month** — a systemic issue, not a bad week.
- Several regions cancel orders at a rate clearly above company average.
- A meaningful share of the catalog has **zero recorded sales**.
- A large portion of customers buy once and never return.
- The on-time delivery KPI reads unusually low — **flagged for validation**, not reported as final.

---

## ✅ Recommendations

- Validate the on-time delivery measure before it's used in reporting.
- Cap discounts in categories where margin clearly drops as discount rises.
- Launch a retention campaign for one-time buyers.
- Protect the Fishing category and top 10 products with focused inventory/marketing.
- Investigate fulfillment in high-cancellation regions.
- Retire catalog categories with no sales activity.
- Set delivery SLAs per shipping mode, based on actual performance data.

---

## 📁 Repository Structure

```text
Supply-Chain-Analytics-Excel-Python-SQL-Power-BI/
├── Dashboard/              Interactive Power BI file
├── Excel_work/             Cleaned data and Excel analysis
├── Python_work/            Jupyter notebooks (EDA & preprocessing)
├── Report/                 Documentation & executive summary
├── SQL_work/                SQL scripts (DB creation & queries)
├── dashboard_pdf/          Exported PDF of the dashboard
└── DataCoSupplyChainDataset.xlsx   Raw dataset
```

## 👤 Author

**Ashwin Gothwal**
