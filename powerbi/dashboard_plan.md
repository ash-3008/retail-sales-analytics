# Power BI Dashboard Plan

## Objective
Create an executive-facing retail sales dashboard for Olist that answers three core questions:

1. How much product revenue is the business generating?
2. Which categories and sellers drive growth?
3. How well are orders delivered and how satisfied are customers?

## Recommended Pages

### 1) Executive Summary
Primary audience: leadership / portfolio reviewers

Key visuals:
- Total Product Revenue (card)
- Total Orders (card)
- Average Order Value (card)
- Revenue by Month (line chart)
- Orders by Status (stacked bar / donut)
- Top 10 Categories by Revenue (horizontal bar)

Focus:
- Clear KPI headline numbers
- Trend recognition over time
- Simple category performance snapshot

### 2) Category and Product Performance
Primary audience: merchandising / commercial teams

Key visuals:
- Revenue by Category (clustered bar)
- Product Revenue by Top Items (table)
- Category Contribution % (stacked bar or treemap)
- Seller Performance Rank (table)

Focus:
- Product mix and category concentration
- High-value products and sellers
- Commercial opportunity analysis

### 3) Delivery and Customer Experience
Primary audience: operations / logistics / customer success

Key visuals:
- Delivered On Time % (card)
- Average Delivery Delay Days (card)
- Delivery Status Distribution (donut)
- Delay by State or Seller (matrix)
- Review Score Distribution (bar chart)
- Review Score by Month (line or clustered column)

Focus:
- Operational performance
- Customer satisfaction and experience quality
- Geographic or seller-level delivery issues

### 4) Customer and Cohort View (optional if space allows)
Primary audience: growth / retention analysis

Key visuals:
- Repeat Customer Rate
- Monthly Cohort Activity
- Customer Retention by Month

Focus:
- Retention and loyalty analysis
- Repeat order behavior after first purchase

## Dataset Usage
Use the following tables in Power BI:
- customers
- orders
- order_items
- order_payments
- order_reviews
- products
- sellers
- category_translation

Do not load `geolocation` into the main dashboard because it is not needed for the executive visual layer and adds unnecessary size.

## Relationship Setup
Use active single-direction relationships:
- customers.customer_id -> orders.customer_id
- orders.order_id -> order_items.order_id
- products.product_id -> order_items.product_id
- sellers.seller_id -> order_items.seller_id
- orders.order_id -> order_payments.order_id
- orders.order_id -> order_reviews.order_id

## KPI Definition Rule
Use the following definition consistently across all dashboard pages:
- Total Product Revenue = SUM(order_items[price])
- Freight is a separate operational metric and should not be blended into the primary revenue KPI

## Recommended Design Principles
- Keep executive page minimal and readable
- Use consistent corporate colors and left-to-right flow
- Avoid overloading pages with too many slicers
- Add month and state filters for drill-down analysis
- Maintain business language in report titles and tooltips
