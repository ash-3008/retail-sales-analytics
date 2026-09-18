# Retail Sales Analytics

## Importing order reviews

The Olist reviews CSV contains quoted commas, escaped quotes, and multiline
comment fields. Use the parser-backed normalizer before importing; do not
validate this file by splitting physical lines or commas.

```powershell
python scripts\import_order_reviews.py `
  data\raw\olist_order_reviews_dataset.csv `
  C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\olist_order_reviews_mysql.tsv `
  --report scripts\order_reviews_import_report.json

$env:MYSQL_PWD = '<your-password>'
Get-Content -Raw sql\02_data_import.sql |
  & 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' `
    --protocol=TCP -u root retail_sales_analytics
```

The normalizer flattens embedded CR/LF characters in comment fields to spaces
and preserves tabs, commas, quotes, and other text. Empty CSV fields become
SQL `NULL`. The table uses `(review_id, order_id)` as its primary key because
the source has repeated `review_id` values assigned to different orders.

## Revenue definition for dashboard and analysis

For the dashboard and KPI logic, define:

- Total Product Revenue = SUM(order_items.price)
- Freight revenue is analyzed separately and is not part of the primary revenue KPI
- `order_payments.payment_value` is not used as the primary revenue metric for this dashboard

This keeps the dashboard aligned with product sales revenue rather than payment totals, which may include fees, installments, or non-product components.