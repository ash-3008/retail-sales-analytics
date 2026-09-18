CREATE DATABASE IF NOT EXISTS retail_sales_analytics;
USE retail_sales_analytics;

-- ============================================================
-- PHASE 1: DATABASE SCHEMA
-- Retail Sales Analytics - Olist E-Commerce Dataset
-- ============================================================

CREATE TABLE customers (
    customer_id VARCHAR(32) NOT NULL,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix CHAR(5) DEFAULT NULL,
    customer_city VARCHAR(100) DEFAULT NULL,
    customer_state CHAR(2) DEFAULT NULL,
    PRIMARY KEY (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE orders (
    order_id VARCHAR(32) NOT NULL,
    customer_id VARCHAR(32) NOT NULL,
    order_status VARCHAR(20) DEFAULT NULL,
    order_purchase_timestamp DATETIME DEFAULT NULL,
    order_approved_at DATETIME DEFAULT NULL,
    order_delivered_carried_date DATETIME DEFAULT NULL,
    order_delivered_customer_date DATETIME DEFAULT NULL,
    order_estimated_delivered_date DATETIME DEFAULT NULL,
    PRIMARY KEY (order_id),
    KEY idx_orders_customer (customer_id),
    KEY idx_orders_purchase_date (order_purchase_timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE products (
    product_id VARCHAR(32) NOT NULL,
    product_category_name VARCHAR(100) DEFAULT NULL,
    product_name_lenght INT DEFAULT NULL,
    product_description_lenght INT DEFAULT NULL,
    product_photos_qty INT DEFAULT NULL,
    product_weight_g DECIMAL(10,2) DEFAULT NULL,
    product_length_cm DECIMAL(10,2) DEFAULT NULL,
    product_height_cm DECIMAL(10,2) DEFAULT NULL,
    product_width_cm DECIMAL(10,2) DEFAULT NULL,
    PRIMARY KEY (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE sellers (
    seller_id VARCHAR(32) NOT NULL,
    seller_zip_code_prefix CHAR(5) DEFAULT NULL,
    seller_city VARCHAR(100) DEFAULT NULL,
    seller_state CHAR(2) DEFAULT NULL,
    PRIMARY KEY (seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE order_items (
    order_id VARCHAR(32) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(32) NOT NULL,
    seller_id VARCHAR(32) NOT NULL,
    shipping_limit_date DATETIME DEFAULT NULL,
    price DECIMAL(10,2) DEFAULT NULL,
    freight_value DECIMAL(10,2) DEFAULT NULL,
    PRIMARY KEY (order_id, order_item_id),
    KEY idx_items_product (product_id),
    KEY idx_items_seller (seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE order_payments (
    order_id VARCHAR(32) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30) DEFAULT NULL,
    payment_installments INT DEFAULT NULL,
    payment_value DECIMAL(10,2) DEFAULT NULL,
    PRIMARY KEY (order_id, payment_sequential)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE order_reviews (
    review_id VARCHAR(32) NOT NULL,
    order_id VARCHAR(32) NOT NULL,
    review_score INT DEFAULT NULL,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME DEFAULT NULL,
    review_answer_timestamp DATETIME DEFAULT NULL,
    PRIMARY KEY (review_id, order_id),
    KEY idx_reviews_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE category_translation (
    product_category_name VARCHAR(100) NOT NULL,
    product_category_name_english VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (product_category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE geolocation (
    geolocation_zip_code_prefix CHAR(5) NOT NULL,
    geolocation_lat DECIMAL(12,8) DEFAULT NULL,
    geolocation_lng DECIMAL(12,8) DEFAULT NULL,
    geolocation_city VARCHAR(100) DEFAULT NULL,
    geolocation_state CHAR(2) DEFAULT NULL,
    KEY idx_geo_zip (geolocation_zip_code_prefix)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
