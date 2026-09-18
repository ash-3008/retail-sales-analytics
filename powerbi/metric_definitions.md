# Power BI Metric Definitions

## Revenue metrics

### Total Product Revenue
Definition: SUM(order_items[price])
Use: Primary KPI on executive dashboard and category analysis
Why: Aligns with the project's definition of product sales revenue rather than payment totals

### Total Freight Value
Definition: SUM(order_items[freight_value])
Use: Logistics / shipping cost analysis
Why: Freight is tracked as a separate operational metric

### Average Order Value
Definition: Total Product Revenue / Total Orders
Use: Business efficiency and customer basket analysis

## Operational metrics

### Total Orders
Definition: DISTINCTCOUNT(orders[order_id])
Use: Volume and throughput KPI

### Delivery Rate %
Definition: Delivered orders / total orders
Use: Delivery performance headline measure

### Cancel Rate %
Definition: Canceled orders / total orders
Use: Fulfillment quality and customer experience monitoring

## Customer experience metrics

### Average Review Score
Definition: AVERAGE(order_reviews[review_score])
Use: Satisfaction indicator

### Positive Review %
Definition: Reviews scoring 4 or 5 / total reviews
Use: Customer sentiment trend

### Negative Review %
Definition: Reviews scoring 1 or 2 / total reviews
Use: Complaint monitoring

## Delivery metrics

### Delivery Delay Days
Definition: DATEDIFF(estimated delivery date, actual delivery date, DAY)
Interpretation: Positive values = late deliveries; negative = early deliveries

### On Time Delivery %
Definition: Delivered orders with Delay Days <= 0 / delivered orders
Use: Operational SLA health

### Late Delivery %
Definition: Delivered orders with Delay Days > 0 / delivered orders
Use: Logistics exception analysis

### Average Delivery Delay Days
Definition: Average Delay Days for delivered orders with complete dates
Use: Distribution of delivery reliability
