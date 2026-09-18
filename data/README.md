# Data Folder README

## Contents
This folder stores the local project dataset files used for the Retail Sales Analytics portfolio project.

### Raw data directory
- `data/raw/`

The raw dataset is the Olist Brazilian E-Commerce Public Dataset and contains the source CSV files for the project. These files are intentionally excluded from Git via `.gitignore` and should remain local to the workstation.

### Required raw files
- olist_orders_dataset.csv
- olist_order_items_dataset.csv
- olist_products_dataset.csv
- olist_customers_dataset.csv
- olist_order_payments_dataset.csv
- olist_order_reviews_dataset.csv
- olist_sellers_dataset.csv
- olist_geolocation_dataset.csv
- product_category_name_translation.csv

## Data handling rules
- Do not upload raw CSV files to GitHub.
- Keep the dataset local and reproducible from the source folder.
- Use SQL import scripts in `sql/` for table loading.
- The imported MySQL tables are the canonical project data model.
- Keep the raw data unchanged; apply any transformations via scripts or staging tables only when needed.

## Review import note
The `order_reviews` file contains multiline quoted comments and escaped commas. The import pipeline uses a parser-backed normalization step to preserve all valid records without corrupting the file.
