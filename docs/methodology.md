# Methodology: NCR Mandi-to-Doorstep Markup Analytics

## Objective

Quantify the wholesale-to-retail price markup for 11 fresh-produce SKUs across Delhi NCR q-commerce platforms. Surface direct-sourcing and pricing opportunities for a q-commerce category team.

---

## Data Source 1: Wholesale Mandi Prices

**Source**: Agmarknet 2.0 portal (agmarknet.gov.in), Government of India
**Data window**: 8 November 2025 to 21 May 2026
**Constraint**: Agmarknet 2.0 went live on 7 November 2025. Pre-migration historical data is not available from the new portal. The methodology generalises to longer windows once historical data is reconciled.

**Mandis selected**:
- Azadpur APMC, North Delhi
- Fruit and Vegetable Market, Gazipur APMC, East Delhi
- Keshopur APMC, West Delhi

**Fields captured**: State, District, Market, Commodity Group, Commodity, Variety, Grade, Min Price, Max Price, Modal Price (Rs/Quintal), Arrival Quantity (Metric Tonnes), Arrival Date

**Unit conversion**: Source data is in Rs per Quintal. Converted to Rs per kg in Excel by dividing by 100. All downstream analysis uses Rs per kg.

**Download method**: Manual export from Agmarknet 2.0 portal, one CSV per commodity, NCT of Delhi state, all markets selected. 11 separate downloads, one per SKU.

**Total records**: 4,102 rows across 11 SKUs, 3 mandis, approximately 195 calendar days.

**Coverage note**: Mandis do not report every calendar day. Average coverage is 65 to 75% of calendar days per mandi per SKU. Missing days are not forward-filled. Raw data is used as reported.

---

## Data Source 2: Retail Price Audit

**Method**: Manual capture from Blinkit, Zepto, and Instamart mobile apps
**Date**: 11 June 2026
**Time window**: 5 PM IST (standardised to control for intra-day dynamic pricing)
**Design**: Cross-sectional snapshot, not a longitudinal panel

**Locations**:
- 110001, Connaught Place, Central Delhi (Blinkit and Instamart only)
- 122001, Cyber Hub Gurgaon, South Gurgaon (all 3 platforms)
- 201301, Sector 18 Noida, Noida (all 3 platforms)
- 110092, Preet Vihar, East Delhi (Zepto only, see note below)

**Zepto serviceability note**: Zepto does not service Connaught Place (110001) directly. Preet Vihar (110092) was used as the Central Delhi substitute for Zepto captures. This is documented in the retail data file and in the database.

**Fields captured**: Platform, area name, city, SKU name, category, listed price (Rs), pack size (grams), discount flag (Y/N), out of stock flag (Y/N)

**Unit normalisation**: Price per kg calculated in Excel using the formula: listed price divided by pack size in grams, multiplied by 1000. OOS rows have price per kg set to zero.

**Total records**: 99 rows (11 SKUs x 3 platforms x 3 pincodes = 99). 8 OOS observations recorded.

**Benchmark date gap**: Retail prices were captured on 11 June 2026. The last available Agmarknet mandi data point is 21 May 2026. The 21-day gap means retail prices are benchmarked against the last available mandi price, not a same-day comparison. This is a known limitation, documented here and in the SQL query comments.

---

## SKU Selection

### Candidate pool
17 SKUs were tested against the Agmarknet 2.0 portal.

### Selection rules
Both rules must pass for a SKU to be included.

**Rule 1: Canonical spelling**
The commodity name on Agmarknet must match standard English spelling with no parentheses, qualifiers, or non-standard variants. This eliminates naming ambiguity in SQL joins and downstream analysis.

**Rule 2: 3-mandi coverage**
All three target mandis (Azadpur, Gazipur, Keshopur) must have at least one price record in the data window. SKUs failing this rule break cross-mandi hypothesis comparisons.

### Final panel: 11 SKUs
Onion, Tomato, Potato, Cauliflower, Capsicum, Cabbage, Bottle gourd, Brinjal, Carrot, Pumpkin, Spinach

### Rejected candidates: 6 SKUs
See data/rejected_skus.csv for full audit trail.

---

## Database Design

Two flat tables in MySQL database ncr_markup:

**mandi_prices**: 4,102 rows. Grain: one row per SKU per mandi per date.
**retail_prices**: 99 rows. Grain: one row per SKU per platform per location per date.

No star schema. No foreign key constraints between tables. Joins are performed in SQL queries using sku_name as the join key.

---

## Analytical Framework

**Q1: Mandi price baseline**
6-month average, min, max, and standard deviation of modal price per SKU per mandi. Establishes the wholesale cost anchor.

**Q2: Cross-mandi price gap**
Average modal price per SKU per mandi compared against the cheapest mandi. Surfaces direct sourcing opportunity.

**Q3: Markup by SKU and platform**
Average retail price per kg vs NCR average mandi price on the last available date. Markup % = (retail - mandi) / mandi x 100.

**Q4: OOS rate by SKU and platform**
Count of OOS observations as a percentage of total observations per SKU per platform.

---

## Known Limitations

1. Mandi data window is 6.5 months, constrained by Agmarknet 2.0 go-live date.
2. Retail audit is a single-day cross-sectional snapshot. Retail price volatility over time cannot be measured.
3. 21-day gap between last mandi data and retail audit date.
4. Pack size varies across platforms for the same SKU. Per-kg normalisation addresses this but assumes linear pricing.
5. Discount prices are logged but not used in markup calculation. Markup is calculated on listed price.
6. Dark store to mandi mapping is not confirmed. NCR average across all 3 mandis is used as the wholesale proxy.
