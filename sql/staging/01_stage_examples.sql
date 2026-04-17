-- ============================================================
-- Example staging script
-- ============================================================
-- Staging scripts clean and prepare raw data for dimensional modeling.
-- This is a template - customize based on your data quality findings.
-- ============================================================

-- Example: Stage customers with basic cleaning
CREATE OR REPLACE VIEW stg_customers AS
SELECT
    customer_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    LOWER(TRIM(email_domain)) AS email_domain,
    COALESCE(loyalty_segment, 'Unknown') AS loyalty_segment,
    TRIM(city) AS city,
    UPPER(TRIM(province)) AS province,
    CAST(join_date AS DATE) AS join_date
FROM raw_dim_customer
WHERE customer_id IS NOT NULL;

-- Example: Stage products
CREATE OR REPLACE VIEW stg_products AS
SELECT
    product_id,
    TRIM(product_name) AS product_name,
    COALESCE(category, 'Unknown') AS category,
    COALESCE(subcategory, 'Unknown') AS subcategory,
    unit_price,
    unit_cost,
    TRIM(brand) AS brand
FROM raw_dim_product
WHERE product_id IS NOT NULL;

-- Add more staging views as needed...
