NCR Mandi-to-Doorstep Markup Analytics
Quantifying supply-chain markup between Delhi NCR wholesale mandis and quick-commerce retail prices for 11 fresh-produce SKUs.
Project Objective
Identify markup magnitude, volatility, and price-lag patterns across the NCR wholesale-to-doorstep chain to surface direct-sourcing and pricing opportunities for q-commerce category teams.
Methodology Snapshot

Mandi data: Agmarknet 2.0, 7 Nov 2025 to 21 May 2026, 3 NCR mandis (Azadpur, Gazipur, Keshopur)
Retail data: Manual capture across Blinkit, Zepto, Instamart, 3 NCR pincodes (110001, 122001, 201301), 10 days
Analysis: Star schema in MySQL, markup %, volatility, mandi-to-retail lag, hypothesis tests
Output: Power BI dashboard + 1-page executive memo

Final SKU Panel (11)
Onion, Tomato, Potato, Cauliflower, Capsicum, Cabbage, Bottle gourd, Brinjal, Carrot, Pumpkin, Spinach.
Selection rules: strict canonical spelling + 3-mandi coverage. 6 candidates rejected. See docs/methodology.md and data/reference/rejected_skus.csv for full audit trail.
Stack
SQL (MySQL, star schema), Python (Colab, pandas), Power BI (dashboard + DAX), Excel (retail logging)
Project Status

 Day 1: Data source validated, SKU panel locked, repo scaffolded
 Day 2: Bulk mandi data load, star schema design, MySQL setup
 Day 3-4: Retail price logging in progress, SQL transformations
 Day 5: Hypothesis tests, markup calculations
 Day 6: Power BI dashboard build
 Day 7: Executive memo + documentation
 Day 8: Polish + buffer

Repo Structure
ncr-mandi-qcomm-markup-analytics/
├── data/
│   ├── raw/              # Source CSVs (gitignored)
│   ├── processed/        # Cleaned data (gitignored)
│   └── reference/        # SKU master, mandi master, rejection log
├── sql/
│   ├── schema/           # DDL for star schema
│   └── analysis/         # Analytical queries
├── notebooks/            # Colab notebooks (ETL, EDA, tests)
├── powerbi/              # .pbix dashboard file
└── docs/
    ├── methodology.md
    └── executive-memo.md
Contact
Prachi | DTU DSM MBA Business Analytics (May 2026)
