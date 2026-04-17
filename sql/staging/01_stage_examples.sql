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
    TRIM(customer_name) as customer_name,
    LOWER(TRIM(email)) as email,
    COALESCE(segment, 'Unknown') as segment,
    TRIM(city) as city,
    UPPER(TRIM(province)) as province,
    CAST(registration_date AS DATE) as registration_date,
    COALESCE(is_active, true) as is_active
FROM raw_dim_customer
WHERE customer_id IS NOT NULL;

-- Example: Stage products
CREATE OR REPLACE VIEW stg_products AS
SELECT
    product_id,
    TRIM(product_name) as product_name,
    COALESCE(category, 'Unknown') as category,
    COALESCE(subcategory, 'Unknown') as subcategory,
    unit_price,
    unit_cost,
    TRIM(brand) as brand,
    supplier_id,
    COALESCE(is_active, true) as is_active
FROM raw_dim_product
WHERE product_id IS NOT NULL;

-- Add more staging views as needed...
