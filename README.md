# NCR Mandi-to-Doorstep Markup Analytics

Quantifying the price gap between wholesale mandi rates and quick-commerce retail prices across 11 fresh-produce SKUs in Delhi NCR.

**Stack:** MySQL · Excel · Power BI
**Data:** 4,102 wholesale price records (Agmarknet 2.0, Government of India) + a 99-point manual retail audit
**Output:** Three-page Power BI dashboard, each page answering one category-management question

---

## Problem Statement

Quick-commerce platforms operating in Delhi NCR source fresh produce from the same three wholesale mandis and price it within minutes of each other. Consumers accept Rs 44 for a 250g pack of capsicum without reference to what that produce cost at the mandi gate that morning.

No public analysis quantifies three things a category or pricing function needs to know:

1. How much markup actually sits between the wholesale gate and the customer's door
2. Whether sourcing location materially changes a platform's input cost
3. Which SKUs combine high margin with high stockout exposure

Without those, sourcing and pricing decisions are made on intuition. This project builds the quantification from public government data and a controlled retail audit.

---

## Questions

Each dashboard page answers exactly one question.

| Page | Question |
|---|---|
| **Sourcing** | Where should a q-commerce platform buy its produce? |
| **Markup** | How much markup sits between the mandi and the doorstep? |
| **Stockout Risk** | Which SKUs carry both high margin and high stockout risk? |

---

## Data

### Wholesale — Agmarknet 2.0 (Government of India)

| | |
|---|---|
| Records | 4,102 daily modal prices |
| Window | 8 Nov 2025 – 21 May 2026 |
| Mandis | Azadpur APMC (North), Gazipur APMC (East), Keshopur APMC (West) |
| Method | Per-SKU CSV export, stacked and unit-converted in Excel (Rs/quintal → Rs/kg) |

### Retail — manual audit

| | |
|---|---|
| Records | 99 price points (91 valid, 8 stockouts) |
| Capture | 11 Jun 2026, 5:00 PM IST — single standardised window |
| Platforms | Blinkit, Zepto, Instamart |
| Locations | Connaught Place, Cyber Hub Gurgaon, Sector 18 Noida, Preet Vihar Delhi |
| Normalisation | All prices converted to Rs/kg to control for pack-size variation |

---

## Method

### SKU selection

17 candidates were tested against two rules. Both had to pass.

1. **Canonical naming** — the Agmarknet commodity name must match standard spelling with no parenthetical qualifiers, so joins are unambiguous
2. **Complete mandi coverage** — all three mandis must report the SKU, or cross-mandi comparison breaks

Six were rejected. Cucumber and Mushroom failed on naming (`Cucumbar(Kheera)`, `Mashrooms`); Lemon, Garlic and Beetroot on incomplete coverage; Raddish on non-canonical spelling. The full rejection log with row counts is in `data/rejected_skus.csv`.

Final panel: Onion, Tomato, Potato, Cauliflower, Capsicum, Cabbage, Bottle gourd, Brinjal, Carrot, Pumpkin, Spinach.

### Design decisions

**Why a single-day retail capture.** A longitudinal panel would be stronger, but manual capture across three apps and four locations is not sustainable daily. A single standardised evening window controls for intra-day dynamic pricing, which is the larger confound. Stated as a limitation rather than glossed over.

**Why Rs/kg normalisation.** Pack sizes differ across platforms for identical SKUs — a 200g spinach pack and a 1kg onion pack are not comparable at listed price. Normalising makes cross-platform comparison valid, and it surfaced the Spinach anomaly below.

**Why latest-date benchmarking.** Retail prices are compared against wholesale prices on 21 May 2026, the most recent available date, rather than a six-month average. Averaging would understate markup during periods of falling wholesale prices.

**Why two flat tables, not a star schema.** At 4,201 total rows, dimensional modelling adds complexity without analytical benefit. Two documented tables keep joins reproducible and queries auditable.

---

## Findings

### Sourcing gap

Azadpur is the cheapest source for **10 of 11 SKUs**, averaging **Rs 14.56/kg** against **Rs 19.84** at Keshopur — a **36% gap on identical produce**.

The premium is widest on high-volume staples:

| SKU | Keshopur premium over Azadpur |
|---|---|
| Cabbage | 104% |
| Bottle gourd | 74% |
| Carrot | 68% |
| Potato | 53% |
| Capsicum | 50% |

Cauliflower is the sole exception, 3.3% cheaper at Keshopur.

### Markup structure

Average markup across the panel is **440% over wholesale**. Capsicum is highest at **885%**, Onion lowest at **203%** — meaning even a commodity staple carries triple its wholesale cost at the doorstep. Markup is structural, not confined to premium SKUs.

### Platform pricing

| Platform | Avg markup over wholesale |
|---|---|
| Zepto | 472% |
| Blinkit | 454% |
| Instamart | 375% |

Zepto prices **26% higher** above wholesale than Instamart across the same SKU set.

### Wholesale volatility

Capsicum swung from **Rs 6 to Rs 65/kg** over six months — a 983% range and the highest in the panel. Tomato follows at 643%. Retail prices did not track these swings.

### Stockout concentration

Eight stockouts across 99 observations (**8.1%**). Capsicum and Spinach were each out of stock at **66.7% of Instamart locations** — the two highest-margin SKUs carrying the highest availability risk.

### Pack-size distortion

Spinach reached **1,740% markup on a single observation** (Blinkit, Noida) driven by a 200g pack, against a **713% SKU average**. Reported as a peak, never as a headline — the gap is itself the finding about why per-kg normalisation is required.

---

## Recommendation

**Capsicum is the highest-leverage intervention target.** It sits at the intersection of highest markup (885%), highest stockout exposure (66.7% of Instamart locations), and highest wholesale volatility (Rs 6–65/kg).

A platform losing the sale on its highest-margin SKU loses twice. Sourcing Capsicum from Azadpur, where it is 50% cheaper than Keshopur, would improve margin headroom and reduce the supply gaps driving those stockouts.

---

## Dashboard

| Page | Question | Answer |
|---|---|---|
| Sourcing | Where should a platform buy? | Azadpur — cheapest for 10 of 11 SKUs |
| Markup | How much markup sits in between? | 440% average, 885% peak (Capsicum) |
| Stockout Risk | Which SKUs are high margin and high risk? | Capsicum, then Spinach |

<!-- Add screenshots here:
![Sourcing](assets/page1_sourcing.png)
![Markup](assets/page2_markup.png)
![Stockout Risk](assets/page3_stockout_risk.png)
-->

---

## Repository

```
├── data/
│   ├── mandi_prices.csv          4,102 wholesale records
│   ├── retail_prices.csv         99 retail observations
│   └── rejected_skus.csv         6 rejected candidates with rationale
├── sql/
│   └── ncr_markup_queries.sql    Schema + 4 analytical queries
├── powerbi/
│   └── NCR_Markup_Analytics.pbix
├── assets/
│   └── (dashboard screenshots)
├── docs/
│   └── methodology.md            Full data decisions and caveats
└── README.md
```

### SQL queries

| Query | Answers |
|---|---|
| Q1 | Six-month wholesale baseline per SKU per mandi |
| Q2 | Cross-mandi price gap and sourcing premium |
| Q3 | Retail markup by SKU and platform |
| Q4 | Stockout rate by SKU and platform |

---

## Limitations

- **Wholesale window is 6.5 months**, limited by the Agmarknet 2.0 platform migration (Nov 2025 go-live). Pre-migration data is not retrievable from the new portal.
- **Retail audit is cross-sectional**, not longitudinal — retail-side price volatility over time cannot be measured from this data.
- **21-day gap** between the last wholesale record (21 May) and the retail capture (11 Jun).
- **Dark-store sourcing is not publicly disclosed.** The NCR average across three mandis is used as a wholesale proxy; actual per-store sourcing may differ.
- **Zepto does not service Connaught Place.** Preet Vihar was substituted for that platform's Central Delhi capture and is documented in the retail dataset.

---

**Prachi**
