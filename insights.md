# Retail Sales Analytics — Key Insights

## Executive Summary

This project analyzes the Olist Brazilian E-Commerce public dataset using MySQL and Power BI. The analysis covers customer behavior, orders, product categories, sellers, payments, reviews, delivery performance, and customer retention.

The dataset contains **98,666 orders**, **98,666 distinct customer references**, **32,951 unique products**, and **3,095 sellers** in the analyzed order data.

The project combines exploratory SQL, advanced SQL techniques such as CTEs, window functions and ranking, cohort analysis, and an interactive Power BI dashboard.

---

## 1. Revenue and Order Performance

- **Total Product Revenue:** 13,591,643.70
- **Average Order Value:** 180.24

### Order Status Distribution

| Order Status | Orders |
|---|---:|
| Delivered | 96,478 |
| Shipped | 1,107 |
| Canceled | 625 |
| Unavailable | 609 |
| Invoiced | 314 |

The majority of orders in the analyzed dataset reached the **delivered** status, while shipped, canceled, unavailable, and invoiced orders represent smaller portions of the order-status distribution.

Revenue analysis is based on **product sales price (`order_items.price`)** rather than payment value. This keeps the revenue KPI focused on product sales and avoids treating freight charges and other payment adjustments as product revenue.

---

## 2. Category Performance

The highest-revenue product categories identified through SQL analysis are:

| Category | Revenue |
|---|---:|
| health_beauty | 1,255,695.13 |
| watches_gifts | 1,198,185.21 |
| bed_bath_table | 1,035,964.06 |
| sports_leisure | 979,740.92 |
| computers_accessories | 904,322.02 |

These categories represent important contributors to overall product revenue and are highlighted in the Power BI dashboard for category-level analysis.

The SQL analysis also includes category rankings and monthly category rankings to examine how category performance changes over time.

---

## 3. Customer Behavior and Retention

Customer analysis was performed using `customer_unique_id` so that repeat purchases from the same underlying customer could be identified across different orders.

The analysis includes:

- Customer order frequency
- Repeat customer rate
- Customer first and last purchase
- Time between purchases
- Customer lifetime value
- New versus returning customers
- Customer retention segments
- Cohort-based retention analysis
- Cohort revenue analysis

These analyses provide a view beyond simple order volume by examining how customers interact with the business over their purchasing lifecycle.

The cohort analysis groups customers according to their first purchase month and tracks subsequent purchasing activity across later months.

> **Note:** Exact repeat-purchase, retention, and cohort percentages should be taken directly from the corresponding SQL query results rather than estimated.

---

## 4. Customer Sentiment

The review score distribution is:

| Review Score | Reviews |
|---|---:|
| 5 stars | 57,328 |
| 4 stars | 19,142 |
| 3 stars | 8,179 |
| 2 stars | 3,151 |
| 1 star | 11,424 |

There are **76,470 reviews rated 4 or 5 stars**, representing the majority of the available review scores.

The review analysis can be used alongside delivery and geographic analysis to investigate customer experience patterns.

---

## 5. Geographic Performance

Customer-state analysis was performed to identify differences in revenue contribution across Brazilian states.

The Power BI dashboard includes a **Top 10 customer states by revenue** view, allowing geographic revenue concentration to be examined interactively.

The SQL analysis also includes:

- State revenue ranking
- Delivery performance by customer state

This makes it possible to compare commercial performance with operational delivery performance across different regions.

---

## 6. Payment Behavior

Payment analysis was performed using the `order_payments` table.

The analysis covers:

- Payment method
- Payment value
- Payment installments
- Payment-method distribution

The Power BI dashboard includes a payment-type visualization to show the relative contribution of different payment methods.

Payment value is treated separately from product revenue because payment amounts can include components such as freight and other order-level payment adjustments.

---

## 7. Delivery Performance

Delivery performance was analyzed by comparing the actual customer delivery date with the estimated delivery date for delivered orders.

The Power BI dashboard categorizes orders into:

- **On Time**
- **Late**
- **Not Delivered**

The SQL analysis also examines overall delivery performance and delivery performance by customer state.

This provides an operational perspective that complements the revenue and customer analyses.

> **Note:** Exact on-time and late delivery percentages should be taken from the final SQL/Power BI results rather than estimated.

---

## 8. Advanced SQL Analysis

The project uses several advanced SQL techniques to answer business questions that go beyond basic aggregation.

### Common Table Expressions (CTEs)

CTEs were used to break complex analysis into logical stages, including:

- Monthly revenue calculations
- Customer lifetime value
- Customer purchase history
- Cohort analysis
- Category rankings

### Window Functions

Window functions were used for:

- Month-over-month revenue growth
- Month-over-month order growth
- Purchase-gap analysis using `LAG`
- Customer ranking
- Category ranking
- Revenue contribution calculations

### Ranking Functions

Ranking functions were used to identify:

- Top product categories
- Top products
- Top sellers
- Top states
- Monthly category leaders

These techniques make the analysis more suitable for a portfolio project because they demonstrate practical SQL beyond simple `GROUP BY` queries.

---

## 9. Power BI Dashboard

The Power BI dashboard combines the SQL analysis into an interactive business-reporting view.

### Main KPIs

- Total Revenue
- Total Orders
- Total Customers
- Average Order Value

### Main Visualizations

- Monthly Revenue Trend
- Top 10 Revenue Categories
- Top 10 Revenue States
- Payment Type Analysis
- Delivery Performance
- New vs Returning Customers

### Interactive Filters

- Order purchase date
- Customer state

The dashboard is designed to provide a high-level overview first while allowing users to explore revenue, geographic, payment, delivery, and customer-related patterns.

---

## 10. Key Business Takeaways

Based on the completed analysis:

- Product sales revenue provides the primary commercial KPI for the project.
- A relatively small group of product categories contributes substantially to overall revenue.
- Customer analysis shows the importance of distinguishing new customers from returning customers rather than evaluating performance only through total order volume.
- Review scores provide an additional customer-experience dimension that can be analyzed alongside operational metrics.
- Geographic analysis allows revenue and delivery performance to be examined by customer state.
- Payment analysis provides insight into how customers complete their purchases.
- Delivery analysis adds an operational perspective to the commercial dashboard.
- Cohort and retention analysis can be used to investigate longer-term customer behavior.

---

## 11. Project Scope

The project demonstrates an end-to-end analytics workflow:

1. Raw e-commerce dataset collection
2. Relational database design
3. MySQL table creation
4. CSV data ingestion
5. Data-quality validation
6. Exploratory SQL analysis
7. Advanced SQL analysis
8. Customer and cohort analysis
9. Power BI dashboard development
10. Portfolio documentation

The project intentionally separates **data preparation and analytical querying in MySQL** from **visual exploration and dashboarding in Power BI**.

---

## 12. Data and Metric Notes

### Revenue

Product revenue is calculated using:

`SUM(order_items.price)`

Payment value is not used as the primary revenue KPI because it can contain freight and other payment-related amounts.

### Customers

Customer-level analysis uses:

`customer_unique_id`

rather than only `customer_id`, allowing repeat purchases associated with the same customer to be analyzed correctly.

### Delivery Status

Delivery performance is evaluated using the actual customer delivery date and estimated delivery date for delivered orders.

### Reviews

Review analysis uses the available review scores from the Olist dataset. Review comments and scores are treated as customer-experience data rather than direct measures of revenue.

### Dataset

The project uses the **Olist Brazilian E-Commerce public dataset** containing orders, order items, products, customers, sellers, payments, reviews, geolocation data, and product-category translations.

---

## Conclusion

The Retail Sales Analytics project demonstrates how an e-commerce dataset can be transformed into actionable analytical views using **MySQL, advanced SQL, and Power BI**.

The project covers both **commercial metrics** such as revenue, orders, categories, sellers, and payments and **customer/operational metrics** such as retention, reviews, geography, and delivery performance.

The resulting dashboard and SQL analysis provide a portfolio-ready example of an end-to-end data analytics workflow.