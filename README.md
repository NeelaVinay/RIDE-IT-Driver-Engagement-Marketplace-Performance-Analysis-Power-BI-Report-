# 🚗 RIDE IT — Driver Engagement & Marketplace Performance Analysis
### 36,972 Drivers | 5.9M Rides | 1.8M Activity Records | Jan–Jun 2020
### Stack: Power BI · SQL · Excel

> **Identified a 71.6% offer rejection rate and 37.9% driver churn risk, with PHV drivers outperforming TAXI by 80% on rides/day — enabling targeted dispatch, segment-specific retention, and an evidence-backed engagement scoring framework.**

---

## 📌 Business Problem

RIDE IT's Supply Product team needed to understand what drives — and kills — driver engagement across two countries and two service types. With a 23.2% offer-to-ride conversion rate, more than 3 in 4 ride requests were not resulting in completed trips.

**Key questions answered:**
- What metrics should be monitored to measure engagement over time?
- Which driver segments perform well — and what needs fixing?
- What product or operational changes can address the gaps?

---

## 📊 Dataset Overview

| File | Records | Description |
|---|---|---|
| `rideit_drivers.csv` | 36,972 | Driver profiles: rating, gold status, country, service type, marketing consent |
| `rideit_drivers_activity.csv` | 1,828,412 rows | Daily activity: offers, bookings, cancellations, completed rides |

**Coverage:** January 1 – June 30, 2020 | **Markets:** Germany (DE), Spain (ES) | **Service types:** TAXI, PHV

---

## 🎯 Engagement Metrics Framework

| Metric | Definition | Fleet Average |
|---|---|---|
| **Acceptance Rate** | Bookings / Offers | **28.4%** |
| **Completion Rate** | Rides / Bookings | **81.8%** |
| **Driver Cancellation Rate** | Driver Cancels / Bookings | **7.8%** |
| **Passenger Cancellation Rate** | Pax Cancels / Bookings | **10.6%** |
| **Rides per Active Day** | Total Rides / Active Days | **2.88** |
| **Offer-to-Ride Rate** | Rides / Offers | **23.2%** |
| **Engagement Score** | Weighted composite (see below) | — |

### Engagement Score Formula
```
Engagement Score = 
(0.18 * [Activity Rate]) +
(0.09 * [Acceptance Rate]) +
(0.43 * [Completion Rate]) +
(0.05 * [Gold Frequency per Week]) -
(0.18 * [Driver Cancellation Rate])

---

## 🔍 Key Findings (All Data-Validated)

### 📅 Monthly Trend — COVID Impact Captured

| Month | Active Drivers | Total Rides | Rides/Driver | Acceptance Rate |
|---|---|---|---|---|
| Jan 2020 | 30,600 | 1,735,215 | 56.7 | 21.8% |
| Feb 2020 | 31,227 | 1,883,956 | 60.3 | 26.7% |
| Mar 2020 | 30,272 | 902,161 | **29.8** | 34.8% |
| Apr 2020 | **12,312** | **251,971** | 20.5 | 50.7% |
| May 2020 | 18,165 | 467,230 | 25.7 | 42.2% |
| Jun 2020 | 22,764 | 655,121 | 28.8 | 43.3% |

*March–April: COVID-19 lockdown — 60% drop in ride volume, 18,000 fewer active drivers*

### 🏎️ Service Type — PHV Significantly Outperforms TAXI

| Metric | TAXI | PHV | Δ |
|---|---|---|---|
| Rides / Active Day | 2.58 | **4.64** | **+80%** |
| Completion Rate | 82.4% | 82.6% | +0.2pp |
| Driver Cancel Rate | 7.5% | 7.4% | −0.1pp |
| Driver Count | 31,321 | 5,651 | — |

### 🌍 Country — Spain Higher Volume, Germany Better Reliability

| Metric | Germany (DE) | Spain (ES) |
|---|---|---|
| Rides / Active Day | 2.72 | **3.30** |
| Driver Cancel Rate | **7.0%** | 8.8% |
| Driver Count | 25,802 | 11,170 |

### ⭐ Gold Status → +55% Productivity

| Gold Tier | Drivers | Rides/Day |
|---|---|---|
| None (0 weeks) | — | 2.09 |
| Low (1–2 weeks) | — | 2.42 |
| Mid (3–5 weeks) | — | 2.60 |
| **High (6+ weeks)** | — | **3.24** |

### 📣 Marketing Consent → +42% Activity

| Status | Avg Rides (6m) | Rides/Day |
|---|---|---|
| Opted Out | 103.0 | 2.23 |
| **Opted In** | **184.6** | **3.16** |

### ⚠️ Churn Risk — 37.9% of Fleet At Risk

- **13,920 drivers** (37.9%) showed no activity in the final 30 days
- Majority of at-risk drivers concentrated in Apr–May dormancy window (COVID-driven)

### 🔢 Ride Completion Funnel (6 Months)

```
Offers Sent:          25,380,625  (100%)
    ↓ 28.4% accepted
    
Bookings:              7,204,586
    ↓ 7.8% cancelled by driver, 10.6% by pax
    
Completed Rides:       5,895,654  (23.2% offer-to-ride)
```

---

## 🛠️ Tech Stack

| Tool | Usage |
|---|---|
| **Power BI** | KPI dashboards, DAX engagement score, monthly trend visuals, segment slicers |
| **SQL** | Funnel analysis, segment queries, churn detection, engagement scoring |
| **Excel** | Data Cleaning, Power Query data prep |

---
📁 Repository Structure

├── rideit_drivers.csv                          # 36,972 driver profiles
├── rideit_drivers_activity.csv                 # 1.8M daily activity rows
├── rideit_drivers_activity(Jan).xlsx           # Monthly activity split
├── rideit_drivers_activity(Feb).xlsx
├── rideit_drivers_activity(Mar-Apr).xlsx
├── rideit_drivers_activity(May-June).xlsx
├── RideIt_Data_Analysis_Report.pbix            # Power BI dashboard
├── sql/
│   └── rideit_analysis.sql                     # 10 SQL queries: funnel, segments, churn, scoring
└── README.md
```

---

## 🚀 Recommendations

1. **Fix the acceptance rate gap** — at 28.4%, 71.6% of offers go unfilled. Investigate dispatch radius, time-of-day mismatches, and offer fatigue
2. **Expand PHV supply** — 80% higher productivity per driver vs TAXI; target PHV recruitment in DE market
3. **Retain gold-status drivers** — they deliver 55% more rides/day; build Gold→Platinum tier program to prevent attrition
4. **Re-engage 13,920 churned drivers** — segment by service type and country; targeted win-back campaigns post-COVID
5. **Increase marketing consent rates** — opted-in drivers average 42% more rides; audit consent UX in onboarding flow
6. **Reduce driver cancellations in ES** — 8.8% cancel rate vs 7.0% in DE; investigate reasons (bad matches, pricing, geography)

---

-- ─────────────────────────────────────────────
-- SETUP (MySQL)
-- ─────────────────────────────────────────────
-- Note: Replace with your actual table creation or LOAD DATA syntax
-- LOAD DATA INFILE 'rideit_drivers.csv' INTO TABLE drivers FIELDS TERMINATED BY ',';

Power BI: Open `.pbix` in Power BI Desktop → use slicers for country, service type, month.

---

## 👤 Author

**Neela Vinay** — Data Analyst | Power BI Developer  
📧 [neelavinni9@gmail.com] | 🔗 https://www.linkedin.com/in/vinay-neela/ 

---
*Data period: Jan–Jun 2020 | MIT License*
