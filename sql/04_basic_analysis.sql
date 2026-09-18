USE retail_sales_analytics;

-- ============================================================
-- PHASE 4: BASIC EXPLORATORY / BUSINESS ANALYSIS
-- Olist Brazilian E-Commerce Dataset
-- ============================================================


-- ============================================================
-- 1. OVERALL BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    COUNT(DISTINCT oi.seller_id) AS unique_sellers,
    ROUND(SUM(oi.price), 2) AS total_product_revenue,
    ROUND(AVG(order_totals.order_value), 2) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
) order_totals
    ON o.order_id = order_totals.order_id;


-- ============================================================
-- 2. ORDERS BY STATUS
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- 3. MONTHLY REVENUE TREND
-- ============================================================

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;


-- ============================================================
-- 4. MONTHLY ORDER VOLUME
-- ============================================================

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM orders
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;


-- ============================================================
-- 5. TOP 10 PRODUCT CATEGORIES BY REVENUE
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.order_item_id = 1) AS approximate_items
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 6. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 7. TOP 10 CUSTOMER STATES BY REVENUE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 8. PAYMENT METHOD ANALYSIS
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS payment_transactions,
    COUNT(DISTINCT order_id) AS unique_orders,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- ============================================================
-- 9. PAYMENT INSTALLMENT ANALYSIS
-- ============================================================

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- ============================================================
-- 10. REVIEW SCORE DISTRIBUTION
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- ============================================================
-- 11. AVERAGE REVIEW SCORE
-- ============================================================

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score,
    COUNT(*) AS total_reviews,
    SUM(review_score >= 4) AS positive_reviews,
    SUM(review_score <= 2) AS negative_reviews,
    ROUND(
        SUM(review_score >= 4) * 100.0 / COUNT(*),
        2
    ) AS positive_review_percentage
FROM order_reviews;


-- ============================================================
-- 12. REVENUE BY PRODUCT CATEGORY
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC;


-- ============================================================
-- 13. AVERAGE ORDER VALUE BY MONTH
-- ============================================================

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(oi.price + oi.freight_value)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;


-- ============================================================
-- 14. FREIGHT VS PRODUCT PRICE
-- ============================================================

SELECT
    ROUND(SUM(price), 2) AS total_product_value,
    ROUND(SUM(freight_value), 2) AS total_freight_value,
    ROUND(
        SUM(freight_value) * 100.0 / SUM(price),
        2
    ) AS freight_as_percentage_of_product_value
FROM order_items;


-- ============================================================
-- 15. ORDER DELIVERY PERFORMANCE
-- ============================================================

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days,
    ROUND(
        AVG(
            DATEDIFF(
                order_estimated_delivered_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_estimated_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;


-- ============================================================
-- 16. ON-TIME VS LATE DELIVERIES
-- ============================================================

SELECT
    CASE
        WHEN order_delivered_customer_date
             <= order_estimated_delivered_date
        THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivered_date IS NOT NULL
GROUP BY
    CASE
        WHEN order_delivered_customer_date
             <= order_estimated_delivered_date
        THEN 'On Time'
        ELSE 'Late'
    END;


-- ============================================================
-- END OF PHASE 4
-- ============================================================
