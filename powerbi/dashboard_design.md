# Dashboard Design Specification

## Page 1: Executive Overview
Purpose: Top-level story for review and stakeholder communication

Visuals:
- Card: Total Product Revenue
- Card: Total Orders
- Card: Average Order Value
- Card: Delivery Rate %
- Line chart: Revenue by Month
- Bar chart: Orders by Status
- Horizontal bar: Top 10 Categories by Revenue

Recommended slicers:
- Order month
- Customer state
- Seller state

## Page 2: Category and Product Performance
Purpose: Show where revenue is created and what drives mix

Visuals:
- Treemap or bar chart: Revenue by Product Category
- Table: Top 10 Products by Revenue
- Matrix: Category x Month revenue trend
- Bar chart: Seller Revenue by Seller ID

Recommended slicers:
- Product category
- Month
- Seller city/state

## Page 3: Delivery and Operations
Purpose: Quantify shipping, fulfillment, and customer experience quality

Visuals:
- Card: On Time Delivery %
- Card: Average Delivery Delay Days
- Donut: Delivery status breakdown
- Bar chart: Late delivery by state
- Table: Seller delivery lag summary
- Bar chart: Review Score Distribution

Recommended slicers:
- Order month
- Customer state
- Seller state

## Page 4: Customer and Cohort View (optional)
Purpose: Explain repeat ordering and retention behavior

Visuals:
- Cohort table: first purchase month vs purchase month
- Bar chart: cohort retention
- KPI: repeat customer rate

## Layout guidance
- Use a light theme with dark accents for KPIs
- Keep titles short and business-friendly
- Place filters on the left panel
- Keep the executive page under 5 main visuals
- Combine detailed drill-downs into secondary pages

## Report story
The dashboard should answer these portfolio questions:
1. How large is the business and which categories are most valuable?
2. Is delivery quality supporting revenue growth?
3. Are customers satisfied with product and service experience?
4. Which segments or sellers require operational focus?
