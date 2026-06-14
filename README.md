# NCR Mandi-to-Doorstep Markup Analytics

**How much does fresh produce actually cost at the mandi gate vs what NCR consumers pay on Blinkit, Zepto, and Instamart?**

This project quantifies the wholesale-to-retail markup for 11 fresh-produce SKUs across Delhi NCR, using government mandi price data and a controlled retail price audit across 3 q-commerce platforms and 4 NCR locations.

---

## Problem Statement

Q-commerce platforms have normalised paying Rs 44 for a 250g pack of Capsicum. Consumers accept this without questioning the underlying supply chain economics. This project surfaces the actual mandi-to-doorstep markup structure for a Category Manager to act on: which SKUs carry the highest margin, which mandi offers the cheapest sourcing point, and where is availability risk concentrated.

---

## Methodology

### Data Source 1: Wholesale Mandi Prices
- **Source**: Agmarknet 2.0 (agmarknet.gov.in), Government of India
- **Window**: 8 Nov 2025 to 21 May 2026 (post Agmarknet 2.0 go-live)
- **Mandis**: Azadpur APMC (North Delhi), Gazipur APMC (East Delhi), Keshopur APMC (West Delhi)
- **Records**: 4,102 daily modal price observations
- **Unit**: Rs per kg (converted from Rs/Quintal in Excel)

### Data Source 2: Retail Price Audit
- **Method**: Manual app capture across Blinkit, Zepto, Instamart
- **Date**: 11 Jun 2026, 5 PM IST (standardised evening window)
- **Locations**: Connaught Place (110001), Cyber Hub Gurgaon (122001), Sector 18 Noida (201301), Preet Vihar Delhi (110092)
- **Note**: Zepto does not service CP (110001) directly. Preet Vihar (110092) used as substitute and documented.
- **Records**: 99 price points (91 valid, 8 OOS)
- **Unit**: Price per kg normalised from listed pack price in Excel

### SKU Selection Rules
17 candidate SKUs were tested against two filters:
1. Canonical Agmarknet spelling (no parentheses or non-standard variants)
2. Full coverage across all 3 mandis in the data window

6 candidates rejected. Final panel of 11 SKUs: Onion, Tomato, Potato, Cauliflower, Capsicum, Cabbage, Bottle gourd, Brinjal, Carrot, Pumpkin, Spinach.

### Markup Calculation
Retail price benchmarked against NCR average mandi modal price on the last available Agmarknet date (21 May 2026). 21-day gap between mandi data cutoff and retail audit is acknowledged as a methodology limitation.

---

## Tools

| Tool | Purpose |
|---|---|
| Agmarknet 2.0 | Government wholesale price data source |
| Excel | Data cleaning, unit conversion, retail price log, pack-size normalisation |
| MySQL | Flat-table database (mandi_prices + retail_prices), 4 analytical queries |
| Power BI | 2-page dashboard with direct MySQL connection |

---

## Key Findings

**1. Cauliflower carries the highest avg markup at 851%**
Driven by Zepto Noida pricing at Rs 277/kg vs Rs 27/kg mandi cost. Capsicum follows at 478-984% across platforms. Even commodity staples like Onion carry 110-243% markup.

**2. Instamart prices staples closest to wholesale cost**
Consistently the lowest markup platform across Staple category SKUs. Blinkit leads on Premium SKU markup.

**3. Azadpur APMC is the cheapest sourcing point for 10 of 11 SKUs**
Cabbage at Keshopur costs 104% more than Azadpur. Potato at Keshopur costs 53% more. Dark stores supplied from Azadpur have a structural cost advantage before logistics even begins. Exception: Cauliflower is cheapest at Keshopur (Rs 18.80/kg vs Rs 19.45 at Azadpur).

**4. Capsicum has the highest availability risk**
OOS on Instamart at 2 of 3 capture locations. Combined with its 686-984% markup when in stock, Capsicum represents both the highest margin and highest availability risk SKU in the fresh produce category.

**5. Capsicum price swung from Rs 6/kg to Rs 65/kg at Gazipur over 6 months**
Retail price held at Rs 120-176/kg throughout. Mandi price drops are not being passed to consumers.

---

## SQL Queries

4 business-oriented queries covering:
- **Q1**: 6-month mandi price baseline per SKU per mandi
- **Q2**: Cross-mandi price gap and sourcing premium %
- **Q3**: Retail markup % by SKU and platform vs latest mandi price
- **Q4**: OOS rate by SKU and platform

See `sql/ncr_markup_queries.sql`

---

## Dashboard

2-page Power BI dashboard:

**Page 1: Markup Analysis**
Answers: Which SKUs and platforms have the highest markup over mandi cost?

**Page 2: Sourcing Intelligence**
Answers: Which mandi is cheapest per SKU, and how much could be saved by sourcing smarter?

---

## Repo Structure

```
ncr-mandi-qcomm-markup-analytics/
├── data/
│   ├── mandi_prices.csv          # 4,102 mandi price records
│   ├── retail_prices.csv         # 99 retail audit records
│   └── rejected_skus.csv         # 6 rejected candidates with reasons
├── sql/
│   └── ncr_markup_queries.sql    # DDL + 4 analytical queries
├── powerbi/
│   └── NCR_Markup_Analytics.pbix # Power BI dashboard
├── docs/
│   └── methodology.md            # Data decisions and caveats
└── README.md
```

---

## Data Limitations

- Mandi data window constrained by Agmarknet 2.0 go-live (Nov 2025). Pre-migration data not available from the new portal.
- Retail audit is cross-sectional (single day) not longitudinal. Markup volatility over time cannot be measured from retail side.
- 21-day gap between last mandi data point (21 May 2026) and retail audit (11 Jun 2026).
- Pack sizes vary across platforms for the same SKU, requiring per-kg normalisation which is documented in the Excel data file.

---

## Author

Prachi | MBA Business Analytics

GitHub: github.com/Prachi0259
