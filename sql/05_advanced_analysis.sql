USE retail_sales_analytics;

-- ============================================================
-- PHASE 5: ADVANCED SQL ANALYSIS
-- Dataset: Olist Brazilian E-Commerce
-- MySQL 8+
-- ============================================================


-- ============================================================
-- 1. MONTH-OVER-MONTH REVENUE GROWTH
-- Business Question:
-- How does monthly revenue change compared with the previous month?
--
-- Technique:
-- CTE + LAG()
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),
revenue_with_previous AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    order_month,
    revenue,
    previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS mom_growth_percentage
FROM revenue_with_previous
ORDER BY order_month;


-- ============================================================
-- 2. MONTH-OVER-MONTH ORDER GROWTH
-- Business Question:
-- Is the number of orders increasing or decreasing each month?
--
-- Technique:
-- CTE + LAG()
-- ============================================================

WITH monthly_orders AS (
    SELECT
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
        COUNT(*) AS total_orders
    FROM orders
    WHERE order_status NOT IN ('canceled', 'unavailable')
    GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
),
orders_with_previous AS (
    SELECT
        order_month,
        total_orders,
        LAG(total_orders) OVER (
            ORDER BY order_month
        ) AS previous_month_orders
    FROM monthly_orders
)
SELECT
    order_month,
    total_orders,
    previous_month_orders,
    total_orders - previous_month_orders AS order_change,
    ROUND(
        (total_orders - previous_month_orders)
        / NULLIF(previous_month_orders, 0) * 100,
        2
    ) AS mom_growth_percentage
FROM orders_with_previous
ORDER BY order_month;


-- ============================================================
-- 3. TOP 3 PRODUCT CATEGORIES BY REVENUE EACH MONTH
-- Business Question:
-- Which product categories performed best in each month?
--
-- Technique:
-- CTE + RANK()
-- ============================================================

WITH monthly_category_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m'),
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
),
ranked_categories AS (
    SELECT
        order_month,
        category,
        revenue,
        RANK() OVER (
            PARTITION BY order_month
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM monthly_category_revenue
)
SELECT
    order_month,
    category,
    revenue,
    revenue_rank
FROM ranked_categories
WHERE revenue_rank <= 3
ORDER BY order_month, revenue_rank;


-- ============================================================
-- 4. CATEGORY REVENUE CONTRIBUTION
-- Business Question:
-- What percentage of total revenue comes from each category?
--
-- Technique:
-- CTE + SUM() OVER()
-- ============================================================

WITH category_revenue AS (
    SELECT
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
)
SELECT
    category,
    revenue,
    ROUND(
        revenue / SUM(revenue) OVER () * 100,
        2
    ) AS revenue_contribution_percentage
FROM category_revenue
ORDER BY revenue DESC;


-- ============================================================
-- 5. SELLER PERFORMANCE RANKING
-- Business Question:
-- Which sellers generate the highest sales revenue?
--
-- Technique:
-- CTE + RANK()
-- ============================================================

WITH seller_revenue AS (
    SELECT
        s.seller_id,
        s.seller_city,
        s.seller_state,
        ROUND(SUM(oi.price), 2) AS revenue,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        COUNT(*) AS items_sold
    FROM sellers s
    JOIN order_items oi
        ON s.seller_id = oi.seller_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY
        s.seller_id,
        s.seller_city,
        s.seller_state
),
ranked_sellers AS (
    SELECT
        seller_id,
        seller_city,
        seller_state,
        revenue,
        total_orders,
        items_sold,
        RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM seller_revenue
)
SELECT
    revenue_rank,
    seller_id,
    seller_city,
    seller_state,
    revenue,
    total_orders,
    items_sold
FROM ranked_sellers
WHERE revenue_rank <= 20
ORDER BY revenue_rank;


-- ============================================================
-- 6. CUSTOMER ORDER FREQUENCY
-- Business Question:
-- How many customers purchased once versus multiple times?
--
-- Important:
-- customer_unique_id represents the actual customer across orders.
--
-- Technique:
-- CTE + CASE classification
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        WHEN order_count = 2 THEN 'Two orders'
        WHEN order_count >= 3 THEN '3+ orders'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER () * 100,
        2
    ) AS percentage_of_customers
FROM customer_orders
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        WHEN order_count = 2 THEN 'Two orders'
        WHEN order_count >= 3 THEN '3+ orders'
    END
ORDER BY customers DESC;


-- ============================================================
-- 7. REPEAT CUSTOMER RATE
-- Business Question:
-- What percentage of customers made more than one purchase?
--
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
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN order_count > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    SUM(
        CASE
            WHEN order_count = 1 THEN 1
            ELSE 0
        END
    ) AS one_time_customers,

    ROUND(
        SUM(
            CASE
                WHEN order_count > 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS repeat_customer_rate_percentage
FROM customer_orders;


-- ============================================================
-- 8. CUSTOMER LIFETIME VALUE
-- Business Question:
-- Which customers have generated the most revenue?
--
-- Revenue definition:
-- Product price only.
--
-- Technique:
-- CTE + aggregation + ranking
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS lifetime_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
),
ranked_customers AS (
    SELECT
        customer_unique_id,
        total_orders,
        lifetime_revenue,
        RANK() OVER (
            ORDER BY lifetime_revenue DESC
        ) AS customer_rank
    FROM customer_revenue
)
SELECT
    customer_rank,
    customer_unique_id,
    total_orders,
    lifetime_revenue
FROM ranked_customers
WHERE customer_rank <= 20
ORDER BY customer_rank;


-- ============================================================
-- 9. CUSTOMER FIRST AND LAST PURCHASE
-- Business Question:
-- When did customers first and most recently purchase?
--
-- Technique:
-- CTE + MIN/MAX
-- ============================================================

WITH customer_lifecycle AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase,
        MAX(o.order_purchase_timestamp) AS last_purchase,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    first_purchase,
    last_purchase,
    total_orders,
    DATEDIFF(
        last_purchase,
        first_purchase
    ) AS customer_lifetime_days
FROM customer_lifecycle
WHERE total_orders > 1
ORDER BY customer_lifetime_days DESC;


-- ============================================================
-- 10. TIME BETWEEN CUSTOMER PURCHASES
-- Business Question:
-- How many days typically pass between repeat purchases?
--
-- Technique:
-- CTE + LAG()
-- ============================================================

WITH customer_purchase_history AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        LAG(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS previous_purchase
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
repeat_purchases AS (
    SELECT
        customer_unique_id,
        order_id,
        order_purchase_timestamp,
        previous_purchase,
        DATEDIFF(
            order_purchase_timestamp,
            previous_purchase
        ) AS days_since_previous_purchase
    FROM customer_purchase_history
    WHERE previous_purchase IS NOT NULL
)
SELECT
    ROUND(
        AVG(days_since_previous_purchase),
        2
    ) AS average_days_between_purchases,

    MIN(days_since_previous_purchase)
        AS minimum_days_between_purchases,

    MAX(days_since_previous_purchase)
        AS maximum_days_between_purchases
FROM repeat_purchases;


-- ============================================================
-- 11. STATE REVENUE RANKING
-- Business Question:
-- Which Brazilian states generate the most revenue?
--
-- Technique:
-- CTE + RANK()
-- ============================================================

WITH state_revenue AS (
    SELECT
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_state
),
ranked_states AS (
    SELECT
        customer_state,
        total_orders,
        revenue,
        RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM state_revenue
)
SELECT
    revenue_rank,
    customer_state,
    total_orders,
    revenue
FROM ranked_states
ORDER BY revenue_rank;


-- ============================================================
-- 12. DELIVERY PERFORMANCE BY CUSTOMER STATE
-- Business Question:
-- Which states experience longer delivery times?
--
-- Technique:
-- CTE + conditional aggregation
-- ============================================================

WITH delivery_data AS (
    SELECT
        c.customer_state,
        o.order_id,
        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp
        ) AS delivery_days
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_purchase_timestamp IS NOT NULL
)
SELECT
    customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    MIN(delivery_days) AS fastest_delivery_days,
    MAX(delivery_days) AS slowest_delivery_days
FROM delivery_data
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY average_delivery_days DESC;


-- ============================================================
-- 13. CATEGORY AVERAGE ORDER VALUE
-- Business Question:
-- Which categories generate the highest average order value?
--
-- Technique:
-- CTE + order-level aggregation
--
-- Important:
-- First aggregate items at order level to avoid counting
-- individual products as separate orders.
-- ============================================================

WITH order_category_value AS (
    SELECT
        o.order_id,
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        SUM(oi.price) AS order_category_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY
        o.order_id,
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
)
SELECT
    category,
    COUNT(*) AS category_orders,
    ROUND(
        AVG(order_category_revenue),
        2
    ) AS average_category_order_value,
    ROUND(
        SUM(order_category_revenue),
        2
    ) AS total_category_revenue
FROM order_category_value
GROUP BY category
ORDER BY average_category_order_value DESC;


-- ============================================================
-- 14. REVENUE VS FREIGHT COST
-- Business Question:
-- Which categories have relatively high shipping/freight costs?
--
-- Technique:
-- CTE + aggregation
-- ============================================================

WITH category_costs AS (
    SELECT
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        SUM(oi.price) AS product_revenue,
        SUM(oi.freight_value) AS freight_cost
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
)
SELECT
    category,
    ROUND(product_revenue, 2) AS product_revenue,
    ROUND(freight_cost, 2) AS freight_cost,
    ROUND(
        freight_cost / NULLIF(product_revenue, 0) * 100,
        2
    ) AS freight_to_revenue_percentage
FROM category_costs
ORDER BY freight_to_revenue_percentage DESC;


-- ============================================================
-- 15. MONTHLY REVENUE RANKING
-- Business Question:
-- Which months were the strongest revenue periods?
--
-- Technique:
-- CTE + DENSE_RANK()
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        )
)
SELECT
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank,
    order_month,
    revenue
FROM monthly_revenue
ORDER BY revenue_rank;


-- ============================================================
-- END OF PHASE 5
-- ============================================================