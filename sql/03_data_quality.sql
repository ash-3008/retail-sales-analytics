USE retail_sales_analytics;

-- ============================================================
-- PHASE 3: DATA QUALITY & VALIDATION
-- Retail Sales Analytics - Olist E-Commerce Dataset
-- ============================================================


-- ============================================================
-- 1. ROW COUNT VALIDATION
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items
UNION ALL
SELECT 'products', COUNT(*)
FROM products
UNION ALL
SELECT 'sellers', COUNT(*)
FROM sellers
UNION ALL
SELECT 'order_payments', COUNT(*)
FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*)
FROM order_reviews
UNION ALL
SELECT 'geolocation', COUNT(*)
FROM geolocation
UNION ALL
SELECT 'category_translation', COUNT(*)
FROM category_translation;


-- ============================================================
-- 2. NULL / MISSING VALUE CHECKS
-- ============================================================

SELECT
    'customers' AS table_name,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(customer_unique_id IS NULL) AS null_customer_unique_id,
    SUM(customer_city IS NULL) AS null_city,
    SUM(customer_state IS NULL) AS null_state
FROM customers;

SELECT
    'orders' AS table_name,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(order_status IS NULL) AS null_status,
    SUM(order_purchase_timestamp IS NULL) AS null_purchase_timestamp,
    SUM(order_approved_at IS NULL) AS null_approved_at,
    SUM(order_delivered_carried_date IS NULL) AS null_carrier_date,
    SUM(order_delivered_customer_date IS NULL) AS null_delivery_date,
    SUM(order_estimated_delivered_date IS NULL) AS null_estimated_delivery_date
FROM orders;

SELECT
    'order_items' AS table_name,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(seller_id IS NULL) AS null_seller_id,
    SUM(price IS NULL) AS null_price,
    SUM(freight_value IS NULL) AS null_freight_value
FROM order_items;

SELECT
    'products' AS table_name,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(product_category_name IS NULL) AS null_category,
    SUM(product_weight_g IS NULL) AS null_weight,
    SUM(product_length_cm IS NULL) AS null_length,
    SUM(product_height_cm IS NULL) AS null_height,
    SUM(product_width_cm IS NULL) AS null_width
FROM products;

SELECT
    'sellers' AS table_name,
    SUM(seller_id IS NULL) AS null_seller_id,
    SUM(seller_city IS NULL) AS null_city,
    SUM(seller_state IS NULL) AS null_state
FROM sellers;

SELECT
    'order_payments' AS table_name,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(payment_type IS NULL) AS null_payment_type,
    SUM(payment_value IS NULL) AS null_payment_value
FROM order_payments;

SELECT
    'order_reviews' AS table_name,
    SUM(review_id IS NULL) AS null_review_id,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(review_score IS NULL) AS null_review_score
FROM order_reviews;


-- ============================================================
-- 3. DUPLICATE PRIMARY / BUSINESS KEYS
-- ============================================================

-- Customers
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Orders
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Products
SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Sellers
SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- Order items
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- Payments
SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;


-- Reviews
-- Composite key is intentionally (review_id, order_id)
SELECT
    review_id,
    order_id,
    COUNT(*) AS duplicate_count
FROM order_reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. FOREIGN KEY / ORPHAN RECORD CHECKS
-- ============================================================

-- Orders without a matching customer
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order items without a matching order
SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order items without a matching product
SELECT COUNT(*) AS orphan_item_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Order items without a matching seller
SELECT COUNT(*) AS orphan_item_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- Payments without a matching order
SELECT COUNT(*) AS orphan_payments
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Reviews without a matching order
SELECT COUNT(*) AS orphan_reviews
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 5. REVIEW SCORE VALIDATION
-- ============================================================

-- Valid review scores should be between 1 and 5
SELECT
    review_score,
    COUNT(*) AS review_count
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


SELECT COUNT(*) AS invalid_review_scores
FROM order_reviews
WHERE review_score < 1
   OR review_score > 5
   OR review_score IS NULL;


-- ============================================================
-- 6. PRICE / PAYMENT VALUE VALIDATION
-- ============================================================

-- Negative item prices
SELECT COUNT(*) AS negative_item_prices
FROM order_items
WHERE price < 0;


-- Zero item prices
SELECT COUNT(*) AS zero_item_prices
FROM order_items
WHERE price = 0;


-- Negative freight values
SELECT COUNT(*) AS negative_freight_values
FROM order_items
WHERE freight_value < 0;


-- Negative payment values
SELECT COUNT(*) AS negative_payment_values
FROM order_payments
WHERE payment_value < 0;


-- Zero payment values
SELECT COUNT(*) AS zero_payment_values
FROM order_payments
WHERE payment_value = 0;


-- ============================================================
-- 7. ORDER STATUS VALIDATION
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- 8. DATE CONSISTENCY CHECKS
-- ============================================================

-- Approval should not normally happen before purchase
SELECT COUNT(*) AS approval_before_purchase
FROM orders
WHERE order_approved_at IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_approved_at < order_purchase_timestamp;


-- Carrier handoff should not happen before approval
SELECT COUNT(*) AS carrier_before_approval
FROM orders
WHERE order_delivered_carried_date IS NOT NULL
  AND order_approved_at IS NOT NULL
  AND order_delivered_carried_date < order_approved_at;


-- Customer delivery should not happen before carrier handoff
SELECT COUNT(*) AS delivery_before_carrier
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_carried_date IS NOT NULL
  AND order_delivered_customer_date < order_delivered_carried_date;


-- Estimated delivery should normally be after purchase
SELECT COUNT(*) AS estimated_delivery_before_purchase
FROM orders
WHERE order_estimated_delivered_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_estimated_delivered_date < order_purchase_timestamp;


-- ============================================================
-- 9. PRODUCT DATA VALIDATION
-- ============================================================

-- Negative product dimensions
SELECT
    SUM(product_weight_g < 0) AS negative_weight,
    SUM(product_length_cm < 0) AS negative_length,
    SUM(product_height_cm < 0) AS negative_height,
    SUM(product_width_cm < 0) AS negative_width
FROM products;


-- Product category distribution
SELECT
    COUNT(*) AS total_products,
    SUM(product_category_name IS NULL) AS products_without_category,
    COUNT(DISTINCT product_category_name) AS distinct_categories
FROM products;


-- ============================================================
-- 10. CUSTOMER DATA VALIDATION
-- ============================================================

-- Number of unique customers
SELECT
    COUNT(*) AS customer_records,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;


-- Customers associated with multiple customer records
SELECT
    customer_unique_id,
    COUNT(*) AS customer_record_count
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY customer_record_count DESC;


-- ============================================================
-- 11. ORDER ITEM VALIDATION
-- ============================================================

SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    AVG(price) AS average_price,
    MIN(freight_value) AS minimum_freight,
    MAX(freight_value) AS maximum_freight,
    AVG(freight_value) AS average_freight
FROM order_items;


-- ============================================================
-- 12. PAYMENT TYPE VALIDATION
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS payment_count,
    SUM(payment_value) AS total_payment_value,
    AVG(payment_value) AS average_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- ============================================================
-- 13. REVIEW QUALITY SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_reviews,
    COUNT(DISTINCT review_id) AS distinct_review_ids,
    COUNT(DISTINCT order_id) AS reviewed_orders,
    AVG(review_score) AS average_review_score,
    SUM(review_score = 5) AS five_star_reviews,
    SUM(review_score = 1) AS one_star_reviews
FROM order_reviews;


-- ============================================================
-- 14. FINAL DATA QUALITY SUMMARY
-- ============================================================

SELECT
    'Customers' AS table_name,
    COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT
    'Orders',
    COUNT(*)
FROM orders

UNION ALL

SELECT
    'Order Items',
    COUNT(*)
FROM order_items

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM products

UNION ALL

SELECT
    'Sellers',
    COUNT(*)
FROM sellers

UNION ALL

SELECT
    'Payments',
    COUNT(*)
FROM order_payments

UNION ALL

SELECT
    'Reviews',
    COUNT(*)
FROM order_reviews

UNION ALL

SELECT
    'Geolocation',
    COUNT(*)
FROM geolocation

UNION ALL

SELECT
    'Category Translation',
    COUNT(*)
FROM category_translation;
