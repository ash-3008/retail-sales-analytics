USE retail_sales_analytics;

-- ============================================================
-- PHASE 6: COHORT & CUSTOMER ANALYSIS
-- ============================================================


-- ============================================================
-- 1. CUSTOMER FIRST PURCHASE MONTH
-- Business Question:
-- When did each customer make their first purchase?
-- Technique:
-- MIN() + DATE_FORMAT()
-- ============================================================

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    first_purchase_date,
    DATE_FORMAT(first_purchase_date, '%Y-%m') AS first_purchase_month
FROM customer_first_purchase
ORDER BY first_purchase_date;


-- ============================================================
-- 2. CUSTOMER COHORT ASSIGNMENT
-- Business Question:
-- Which cohort does each customer belong to?
-- Technique:
-- CTE
-- ============================================================

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    DATE_FORMAT(first_purchase_date, '%Y-%m') AS cohort_month
FROM customer_first_purchase
ORDER BY cohort_month;


-- ============================================================
-- 3. COHORT SIZE
-- Business Question:
-- How many customers joined each monthly cohort?
-- Technique:
-- CTE + COUNT()
-- ============================================================

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    DATE_FORMAT(first_purchase_date, '%Y-%m') AS cohort_month,
    COUNT(*) AS cohort_customers
FROM customer_first_purchase
GROUP BY DATE_FORMAT(first_purchase_date, '%Y-%m')
ORDER BY cohort_month;


-- ============================================================
-- 4. CUSTOMER PURCHASE MONTHS
-- Business Question:
-- In which months did each customer purchase?
-- Technique:
-- DISTINCT + DATE_FORMAT()
-- ============================================================

SELECT DISTINCT
    c.customer_unique_id,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
ORDER BY customer_unique_id, purchase_month;


-- ============================================================
-- 5. COHORT RETENTION BY MONTH
-- Business Question:
-- How many customers from each cohort remained active
-- in subsequent months?
-- Technique:
-- CTE + TIMESTAMPDIFF() + GROUP BY
-- ============================================================

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

customer_activity AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
),

cohort_activity AS (
    SELECT
        f.customer_unique_id,
        DATE_FORMAT(f.first_purchase_date, '%Y-%m') AS cohort_month,
        a.purchase_month
    FROM customer_first_purchase f
    JOIN customer_activity a
        ON f.customer_unique_id = a.customer_unique_id
)

SELECT
    cohort_month,
    purchase_month,
    COUNT(DISTINCT customer_unique_id) AS active_customers
FROM cohort_activity
GROUP BY cohort_month, purchase_month
ORDER BY cohort_month, purchase_month;


-- ============================================================
-- 6. COHORT MONTH NUMBER
-- Business Question:
-- How many months after joining did customers remain active?
-- Technique:
-- TIMESTAMPDIFF()
-- ============================================================

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

customer_activity AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS purchase_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
),

cohort_activity AS (
    SELECT
        f.customer_unique_id,
        DATE_FORMAT(f.first_purchase_date, '%Y-%m-01') AS cohort_month,
        a.purchase_month
    FROM customer_first_purchase f
    JOIN customer_activity a
        ON f.customer_unique_id = a.customer_unique_id
)

SELECT
    cohort_month,
    purchase_month,
    TIMESTAMPDIFF(
        MONTH,
        cohort_month,
        purchase_month
    ) AS months_since_first_purchase,
    COUNT(DISTINCT customer_unique_id) AS active_customers
FROM cohort_activity
GROUP BY
    cohort_month,
    purchase_month,
    TIMESTAMPDIFF(
        MONTH,
        cohort_month,
        purchase_month
    )
ORDER BY
    cohort_month,
    months_since_first_purchase;


-- ============================================================
-- 7. COHORT RETENTION PERCENTAGE
-- Business Question:
-- What percentage of each cohort returns in later months?
-- Technique:
-- CTE + percentage calculation
-- ============================================================

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

cohort_size AS (
    SELECT
        DATE_FORMAT(first_purchase_date, '%Y-%m-01') AS cohort_month,
        COUNT(*) AS cohort_customers
    FROM customer_first_purchase
    GROUP BY DATE_FORMAT(first_purchase_date, '%Y-%m-01')
),

customer_activity AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS purchase_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
),

cohort_activity AS (
    SELECT
        f.customer_unique_id,
        DATE_FORMAT(f.first_purchase_date, '%Y-%m-01') AS cohort_month,
        a.purchase_month
    FROM customer_first_purchase f
    JOIN customer_activity a
        ON f.customer_unique_id = a.customer_unique_id
),

retention AS (
    SELECT
        ca.cohort_month,
        TIMESTAMPDIFF(
            MONTH,
            ca.cohort_month,
            ca.purchase_month
        ) AS months_since_first_purchase,
        COUNT(DISTINCT ca.customer_unique_id) AS active_customers
    FROM cohort_activity ca
    GROUP BY
        ca.cohort_month,
        TIMESTAMPDIFF(
            MONTH,
            ca.cohort_month,
            ca.purchase_month
        )
)

SELECT
    r.cohort_month,
    r.months_since_first_purchase,
    r.active_customers,
    cs.cohort_customers,
    ROUND(
        r.active_customers * 100.0 / cs.cohort_customers,
        2
    ) AS retention_percentage
FROM retention r
JOIN cohort_size cs
    ON r.cohort_month = cs.cohort_month
ORDER BY
    r.cohort_month,
    r.months_since_first_purchase;


-- ============================================================
-- 8. REPEAT PURCHASE GAP
-- Business Question:
-- How long does it take customers to make another purchase?
-- Technique:
-- LAG() window function
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        LAG(o.order_purchase_timestamp)
            OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp
            ) AS previous_purchase
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
)

SELECT
    customer_unique_id,
    order_id,
    order_purchase_timestamp,
    previous_purchase,
    DATEDIFF(
        order_purchase_timestamp,
        previous_purchase
    ) AS days_since_previous_purchase
FROM customer_orders
WHERE previous_purchase IS NOT NULL
ORDER BY customer_unique_id, order_purchase_timestamp;


-- ============================================================
-- 9. CUSTOMER RETENTION SEGMENTS
-- Business Question:
-- How many customers are one-time vs repeat buyers?
-- Technique:
-- CTE + CASE
-- ============================================================

WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        WHEN order_count BETWEEN 2 AND 3 THEN 'Repeat Customer'
        ELSE 'Loyal Customer'
    END AS customer_segment,
    COUNT(*) AS customers
FROM customer_order_counts
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        WHEN order_count BETWEEN 2 AND 3 THEN 'Repeat Customer'
        ELSE 'Loyal Customer'
    END
ORDER BY customers DESC;


-- ============================================================
-- 10. CUSTOMER LIFETIME REVENUE
-- Business Question:
-- Which customers generate the most revenue?
-- Technique:
-- CTE + aggregation
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS lifetime_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    total_orders,
    ROUND(lifetime_revenue, 2) AS lifetime_revenue
FROM customer_revenue
ORDER BY lifetime_revenue DESC
LIMIT 20;


-- ============================================================
-- 11. CUSTOMER VALUE SEGMENTS
-- Business Question:
-- How is the customer base distributed by lifetime revenue?
-- Technique:
-- CTE + CASE
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS lifetime_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN lifetime_revenue < 100 THEN 'Low Value'
        WHEN lifetime_revenue < 500 THEN 'Medium Value'
        WHEN lifetime_revenue < 1000 THEN 'High Value'
        ELSE 'Very High Value'
    END AS value_segment,
    COUNT(*) AS customers,
    ROUND(AVG(lifetime_revenue), 2) AS average_lifetime_revenue
FROM customer_revenue
GROUP BY
    CASE
        WHEN lifetime_revenue < 100 THEN 'Low Value'
        WHEN lifetime_revenue < 500 THEN 'Medium Value'
        WHEN lifetime_revenue < 1000 THEN 'High Value'
        ELSE 'Very High Value'
    END
ORDER BY average_lifetime_revenue;


-- ============================================================
-- 12. CUSTOMER ORDER FREQUENCY DISTRIBUTION
-- Business Question:
-- How frequently do customers purchase?
-- Technique:
-- Aggregation + CASE
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    order_count,
    COUNT(*) AS customers
FROM customer_orders
GROUP BY order_count
ORDER BY order_count;


-- ============================================================
-- 13. MONTHLY NEW VS RETURNING CUSTOMERS
-- Business Question:
-- Is monthly customer activity driven by new or returning buyers?
-- Technique:
-- CTE + MIN() + CASE
-- ============================================================

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

monthly_customer_activity AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
)

SELECT
    m.purchase_month,
    COUNT(
        DISTINCT CASE
            WHEN DATE_FORMAT(f.first_purchase_date, '%Y-%m')
                 = m.purchase_month
            THEN m.customer_unique_id
        END
    ) AS new_customers,
    COUNT(
        DISTINCT CASE
            WHEN DATE_FORMAT(f.first_purchase_date, '%Y-%m')
                 < m.purchase_month
            THEN m.customer_unique_id
        END
    ) AS returning_customers
FROM monthly_customer_activity m
JOIN customer_first_purchase f
    ON m.customer_unique_id = f.customer_unique_id
GROUP BY m.purchase_month
ORDER BY m.purchase_month;


-- ============================================================
-- 14. CUSTOMER RETENTION SUMMARY
-- Business Question:
-- What is the overall repeat-purchase behavior?
-- Technique:
-- CTE + conditional aggregation
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN order_count = 1 THEN 1
            ELSE 0
        END
    ) AS one_time_customers,

    SUM(
        CASE
            WHEN order_count > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    ROUND(
        SUM(
            CASE
                WHEN order_count > 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_percentage

FROM customer_orders;


-- ============================================================
-- 15. CUSTOMER COHORT REVENUE
-- Business Question:
-- Which acquisition cohorts generated the most revenue?
-- Technique:
-- CTE + cohort assignment + aggregation
-- ============================================================

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    DATE_FORMAT(
        f.first_purchase_date,
        '%Y-%m'
    ) AS cohort_month,
    COUNT(DISTINCT f.customer_unique_id) AS customers,
    ROUND(SUM(r.revenue), 2) AS cohort_revenue,
    ROUND(
        SUM(r.revenue)
        / COUNT(DISTINCT f.customer_unique_id),
        2
    ) AS revenue_per_customer
FROM customer_first_purchase f
JOIN customer_revenue r
    ON f.customer_unique_id = r.customer_unique_id
GROUP BY
    DATE_FORMAT(
        f.first_purchase_date,
        '%Y-%m'
    )
ORDER BY cohort_month;


-- ============================================================
-- END OF PHASE 6
-- ============================================================