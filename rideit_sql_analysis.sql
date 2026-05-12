-- ============================================================
-- RIDE IT — Driver Engagement & Marketplace Performance
-- MySQL Analysis Script
-- Dataset: rideit_drivers + rideit_drivers_activity
-- Period: Jan–Jun 2020 | Author: Neela Vinay
-- ============================================================

-- ─────────────────────────────────────────────
-- SETUP (MySQL)
-- ─────────────────────────────────────────────
-- Note: Replace with your actual table creation or LOAD DATA syntax
-- LOAD DATA INFILE 'rideit_drivers.csv' INTO TABLE drivers FIELDS TERMINATED BY ',';

-- ─────────────────────────────────────────────
-- 1. FLEET OVERVIEW
-- ─────────────────────────────────────────────
SELECT
    COUNT(DISTINCT d.id_driver)           AS total_drivers,
    COUNT(DISTINCT a.id_driver)           AS drivers_with_activity,
    COUNT(DISTINCT a.active_date)         AS operating_days,
    SUM(a.rides)                          AS total_rides_completed,
    SUM(a.offers)                         AS total_offers_sent,
    SUM(a.bookings)                       AS total_bookings,
    SUM(a.bookings_cancelled_by_driver)   AS driver_cancellations,
    SUM(a.bookings_cancelled_by_passenger) AS passenger_cancellations
FROM drivers d
LEFT JOIN activity a ON d.id_driver = a.id_driver;
/*
Total drivers:        36,972
Total rides:       5,895,654
Total offers:     25,380,625
Offer-to-ride:         23.2%
*/

-- ─────────────────────────────────────────────
-- 2. CORE ENGAGEMENT FUNNEL
-- ─────────────────────────────────────────────
SELECT
    SUM(offers)                                                     AS offers,
    SUM(bookings)                                                   AS bookings,
    ROUND(SUM(bookings) * 100.0 / NULLIF(SUM(offers), 0), 1)        AS acceptance_rate_pct,
    SUM(rides)                                                      AS completed_rides,
    ROUND(SUM(rides) * 100.0 / NULLIF(SUM(bookings), 0), 1)         AS completion_rate_pct,
    SUM(bookings_cancelled_by_driver)                               AS driver_cancels,
    ROUND(SUM(bookings_cancelled_by_driver) * 100.0 / NULLIF(SUM(bookings), 0), 1)
                                                                    AS driver_cancel_rate_pct,
    SUM(bookings_cancelled_by_passenger)                            AS pax_cancels,
    ROUND(SUM(bookings_cancelled_by_passenger) * 100.0 / NULLIF(SUM(bookings), 0), 1)
                                                                    AS pax_cancel_rate_pct,
    ROUND(SUM(rides) * 100.0 / NULLIF(SUM(offers), 0), 1)           AS offer_to_ride_pct
FROM activity;
/*
Acceptance rate:    28.4%   ← critical gap: 71.6% offers rejected
Completion rate:    82.1%
Driver cancel:       7.8%
Pax cancel:         10.6%
Offer-to-ride:      23.2%
*/

-- ─────────────────────────────────────────────
-- 3. MONTHLY TREND — COVID IMPACT DETECTION
-- ─────────────────────────────────────────────
-- Changed: strftime() -> DATE_FORMAT()
SELECT
    DATE_FORMAT(active_date, '%Y-%m')                               AS month,
    COUNT(DISTINCT id_driver)                                       AS active_drivers,
    SUM(rides)                                                      AS total_rides,
    ROUND(SUM(rides) * 1.0 / COUNT(DISTINCT id_driver), 1)          AS rides_per_driver,
    ROUND(SUM(bookings) * 100.0 / NULLIF(SUM(offers), 0), 1)        AS acceptance_rate_pct,
    ROUND(SUM(rides) * 100.0 / NULLIF(SUM(bookings), 0), 1)         AS completion_rate_pct
FROM activity
GROUP BY month
ORDER BY month;
/*
Jan: 30,600 drivers | 1.74M rides | 56.7 rides/driver | 21.8% acceptance
Feb: 31,227 drivers | 1.88M rides | 60.3 rides/driver | 26.7% acceptance
Mar: 30,272 drivers |  902K rides | 29.8 rides/driver | 34.8% acceptance  ← COVID drop
Apr: 12,312 drivers |  252K rides | 20.5 rides/driver | 50.7% acceptance  ← lowest volume
May: 18,165 drivers |  467K rides | 25.7 rides/driver | 42.2% acceptance  ← recovery begins
Jun: 22,764 drivers |  655K rides | 28.8 rides/driver | 43.3% acceptance
*/

-- ─────────────────────────────────────────────
-- 4. DRIVER SEGMENTATION — PER-DRIVER METRICS
-- ─────────────────────────────────────────────
WITH driver_stats AS (
    SELECT
        a.id_driver,
        COUNT(DISTINCT a.active_date)                                AS active_days,
        SUM(a.rides)                                                 AS total_rides,
        SUM(a.offers)                                                AS total_offers,
        SUM(a.bookings)                                              AS total_bookings,
        SUM(a.bookings_cancelled_by_driver)                          AS driver_cancels,
        ROUND(SUM(a.rides) * 1.0 / NULLIF(COUNT(DISTINCT a.active_date), 0), 2)
                                                                     AS rides_per_day,
        ROUND(SUM(a.bookings) * 100.0 / NULLIF(SUM(a.offers), 0), 1)
                                                                     AS acceptance_rate,
        ROUND(SUM(a.rides) * 100.0 / NULLIF(SUM(a.bookings), 0), 1)
                                                                     AS completion_rate,
        ROUND(SUM(a.bookings_cancelled_by_driver) * 100.0 / NULLIF(SUM(a.bookings), 0), 1)
                                                                     AS driver_cancel_rate
    FROM activity a
    GROUP BY a.id_driver
)
SELECT
    AVG(active_days)        AS avg_active_days,
    AVG(total_rides)        AS avg_total_rides,
    AVG(rides_per_day)      AS avg_rides_per_day,
    AVG(acceptance_rate)    AS avg_acceptance_rate,
    AVG(completion_rate)    AS avg_completion_rate,
    AVG(driver_cancel_rate) AS avg_driver_cancel_rate
FROM driver_stats;
/*
Avg active days:       49.7
Avg total rides:       160.3
Avg rides/active day:    2.88
Avg acceptance rate:   39.1%
Avg completion rate:   82.1%
Avg driver cancel:      7.5%
*/

-- ─────────────────────────────────────────────
-- 5. PERFORMANCE BY SERVICE TYPE (TAXI vs PHV)
-- ─────────────────────────────────────────────
WITH driver_stats AS (
    SELECT
        a.id_driver,
        COUNT(DISTINCT a.active_date)                                AS active_days,
        SUM(a.rides)                                                 AS total_rides,
        SUM(a.bookings)                                              AS total_bookings,
        SUM(a.offers)                                                AS total_offers,
        SUM(a.bookings_cancelled_by_driver)                          AS driver_cancels
    FROM activity a
    GROUP BY a.id_driver
)
SELECT
    d.service_type,
    COUNT(d.id_driver)                                               AS driver_count,
    ROUND(AVG(ds.total_rides * 1.0 / NULLIF(ds.active_days, 0)), 2) AS avg_rides_per_day,
    ROUND(AVG(ds.total_bookings * 100.0 / NULLIF(ds.total_offers, 0)), 1)
                                                                     AS avg_acceptance_rate,
    ROUND(AVG(ds.total_rides * 100.0 / NULLIF(ds.total_bookings, 0)), 1)
                                                                     AS avg_completion_rate,
    ROUND(AVG(ds.driver_cancels * 100.0 / NULLIF(ds.total_bookings, 0)), 1)
                                                                     AS avg_cancel_rate
FROM drivers d
JOIN driver_stats ds ON d.id_driver = ds.id_driver
GROUP BY d.service_type;
/*
PHV: 4.64 rides/day | 82.6% completion  ← outperforms TAXI by 80%
TAXI: 2.58 rides/day | 82.4% completion
*/

-- ─────────────────────────────────────────────
-- 6. COUNTRY PERFORMANCE — DE vs ES
-- ─────────────────────────────────────────────
WITH driver_stats AS (
    SELECT
        a.id_driver,
        COUNT(DISTINCT a.active_date)                                AS active_days,
        SUM(a.rides)                                                 AS total_rides,
        SUM(a.bookings)                                              AS total_bookings,
        SUM(a.offers)                                                AS total_offers,
        SUM(a.bookings_cancelled_by_driver)                          AS driver_cancels
    FROM activity a
    GROUP BY a.id_driver
)
SELECT
    d.country_code,
    COUNT(d.id_driver)                                               AS drivers,
    ROUND(AVG(ds.total_rides * 1.0 / NULLIF(ds.active_days, 0)), 2) AS avg_rides_per_day,
    ROUND(AVG(ds.total_bookings * 100.0 / NULLIF(ds.total_offers, 0)), 1)
                                                                     AS avg_acceptance_rate,
    ROUND(AVG(ds.driver_cancels * 100.0 / NULLIF(ds.total_bookings, 0)), 1)
                                                                     AS avg_cancel_rate
FROM drivers d
JOIN driver_stats ds ON d.id_driver = ds.id_driver
GROUP BY d.country_code;
/*
ES: 3.30 rides/day | higher cancel rate (8.8%)
DE: 2.72 rides/day | lower cancel rate (7.0%) — better reliability
*/

-- ─────────────────────────────────────────────
-- 7. GOLD STATUS IMPACT ON ENGAGEMENT
-- ─────────────────────────────────────────────
WITH driver_stats AS (
    SELECT
        a.id_driver,
        COUNT(DISTINCT a.active_date)                                AS active_days,
        SUM(a.rides)                                                 AS total_rides,
        SUM(a.bookings)                                              AS total_bookings,
        SUM(a.offers)                                                AS total_offers
    FROM activity a
    GROUP BY a.id_driver
)
SELECT
    CASE
        WHEN d.gold_level_count = 0        THEN '0 — None'
        WHEN d.gold_level_count BETWEEN 1 AND 2 THEN '1-2 — Low'
        WHEN d.gold_level_count BETWEEN 3 AND 5 THEN '3-5 — Mid'
        ELSE '6+ — High'
    END                                                              AS gold_tier,
    COUNT(d.id_driver)                                               AS drivers,
    ROUND(AVG(ds.total_rides * 1.0 / NULLIF(ds.active_days, 0)), 2) AS avg_rides_per_day,
    ROUND(AVG(ds.total_bookings * 100.0 / NULLIF(ds.total_offers, 0)), 1)
                                                                     AS avg_acceptance_rate
FROM drivers d
JOIN driver_stats ds ON d.id_driver = ds.id_driver
GROUP BY gold_tier
ORDER BY avg_rides_per_day DESC;
/*
6+ gold weeks: 3.24 rides/day   ← 55% more productive than zero-gold drivers
0 gold weeks:  2.09 rides/day
*/

-- ─────────────────────────────────────────────
-- 8. MARKETING CONSENT IMPACT
-- ─────────────────────────────────────────────
WITH driver_stats AS (
    SELECT
        a.id_driver,
        COUNT(DISTINCT a.active_date)   AS active_days,
        SUM(a.rides)                    AS total_rides
    FROM activity a
    GROUP BY a.id_driver
)
SELECT
    d.receive_marketing,
    COUNT(d.id_driver)                                               AS drivers,
    ROUND(AVG(ds.total_rides), 0)                                    AS avg_total_rides,
    ROUND(AVG(ds.total_rides * 1.0 / NULLIF(ds.active_days, 0)), 2) AS avg_rides_per_day
FROM drivers d
JOIN driver_stats ds ON d.id_driver = ds.id_driver
GROUP BY d.receive_marketing;
/*
Marketing TRUE:  184.6 avg rides | 3.16 rides/day
Marketing FALSE: 103.0 avg rides | 2.23 rides/day
→ Marketing-opted drivers are 79% more productive
*/

-- ─────────────────────────────────────────────
-- 9. CHURN PROXY — Inactive 30+ Days (Jun 2020)
-- ─────────────────────────────────────────────
WITH last_seen AS (
    SELECT
        id_driver,
        MAX(active_date)                                             AS last_active_date
    FROM activity
    GROUP BY id_driver
)
SELECT
    CASE
        WHEN last_active_date >= '2020-06-01' THEN 'Active (Jun)'
        WHEN last_active_date >= '2020-05-01' THEN 'At Risk (May)'
        WHEN last_active_date >= '2020-04-01' THEN 'Dormant (Apr)'
        ELSE 'Churned (pre-Apr)'
    END                                                              AS driver_status,
    COUNT(id_driver)                                                 AS driver_count,
    ROUND(COUNT(id_driver) * 100.0 / SUM(COUNT(id_driver)) OVER(), 1)
                                                                     AS pct_of_fleet
FROM last_seen
GROUP BY driver_status
ORDER BY driver_count DESC;
-- 37.9% of drivers inactive 30+ days = churn risk cohort for retention campaigns

-- ─────────────────────────────────────────────
-- 10. ENGAGEMENT SCORE — Composite KPI
--     Score = (acceptance_rate * 0.3) +
--             (completion_rate * 0.4) +
--             ((1 - cancel_rate) * 0.2) +
--             (normalised_rides_per_day * 0.1)
-- ─────────────────────────────────────────────
WITH driver_stats AS (
    SELECT
        a.id_driver,
        COUNT(DISTINCT a.active_date)                                AS active_days,
        SUM(a.rides)                                                 AS total_rides,
        ROUND(SUM(a.bookings) * 1.0 / NULLIF(SUM(a.offers), 0), 4)   AS acceptance_rate,
        ROUND(SUM(a.rides) * 1.0 / NULLIF(SUM(a.bookings), 0), 4)    AS completion_rate,
        ROUND(SUM(a.bookings_cancelled_by_driver) * 1.0 / NULLIF(SUM(a.bookings), 0), 4)
                                                                     AS cancel_rate
    FROM activity a
    GROUP BY a.id_driver
),
scored AS (
    SELECT
        ds.id_driver,
        d.service_type,
        d.country_code,
        d.gold_level_count,
        d.receive_marketing,
        ds.active_days,
        ds.total_rides,
        ds.acceptance_rate,
        ds.completion_rate,
        ds.cancel_rate,
        ROUND(
            (ds.acceptance_rate * 0.30) +
            (ds.completion_rate * 0.40) +
            ((1.0 - ds.cancel_rate) * 0.20) +
            (LEAST(ds.total_rides * 1.0 / NULLIF(ds.active_days, 0), 10.0) / 10.0 * 0.10),
        4)                                                           AS engagement_score
    FROM driver_stats ds
    JOIN drivers d ON ds.id_driver = d.id_driver
)
SELECT
    service_type,
    country_code,
    CASE WHEN gold_level_count = 0 THEN 'No Gold' ELSE 'Gold Achieved' END AS gold_status,
    CASE WHEN receive_marketing THEN 'Marketing ON' ELSE 'Marketing OFF' END AS marketing,
    COUNT(id_driver)                                                 AS drivers,
    ROUND(AVG(engagement_score), 4)                                  AS avg_engagement_score,
    ROUND(AVG(total_rides), 0)                                       AS avg_rides
FROM scored
GROUP BY service_type, country_code, gold_status, marketing
ORDER BY avg_engagement_score DESC
LIMIT 20;