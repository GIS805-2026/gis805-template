-- ============================================================
-- PATTERN : basket analysis via self-join (market-basket pairs)
-- ============================================================
-- This template shows how to find which products are bought
-- together using a SELF-JOIN on the same fact table.
--
-- A self-join means joining a table to ITSELF. Here, we join
-- fact_sales to fact_sales on the same order, but for DIFFERENT
-- products. The result is every pair of products that appeared
-- in the same shopping basket.
--
-- This is a common retail analytics question:
--   "Which products are frequently purchased together?"
--
-- PREREQUISITE : fact_sales loaded with a grain of one row per
-- order line (order_number + product_key = unique).
--
-- Compare with:
--   - 02_fact_with_grain.sql  : the fact table this pattern queries
--   - 06_fact_sales_reference.sql : full annotated fact_sales
--   - docs/worked-examples/s04-junk-dim-walkthrough.md
-- ============================================================

-- ------------------------------------------------------------
-- Step 1 : Understand the self-join
-- ------------------------------------------------------------
-- In French : "Pour chaque commande, relie chaque produit aux
-- AUTRES produits de la meme commande."
--
-- f1 = first product in the basket
-- f2 = second product in the basket
-- f1.order_number = f2.order_number  → same basket
-- f1.product_key < f2.product_key    → avoid duplicates (A,B not B,A)

-- ------------------------------------------------------------
-- Step 2 : Basic pair detection
-- ------------------------------------------------------------
-- Question : "Which product pairs appear in the same basket?"

SELECT
    f1.product_key AS product_a,
    f2.product_key AS product_b,
    COUNT(*)       AS times_bought_together
FROM fact_sales f1
JOIN fact_sales f2
    ON  f1.order_number = f2.order_number   -- same basket
    AND f1.product_key  < f2.product_key    -- no duplicates, no self-pair
GROUP BY f1.product_key, f2.product_key
ORDER BY times_bought_together DESC
LIMIT 20;

-- Reading this in French :
-- "Pour chaque paire de produits differents dans la meme commande,
--  compte combien de fois ils apparaissent ensemble.
--  Trie du plus frequent au moins frequent. Montre les 20 premiers."

-- ------------------------------------------------------------
-- Step 3 : Add product names (JOIN to dim_product)
-- ------------------------------------------------------------
-- The previous query returns product_keys. To see actual names,
-- join to dim_product twice (once for each product in the pair).

SELECT
    pa.name          AS product_a_name,
    pa.category      AS product_a_category,
    pb.name          AS product_b_name,
    pb.category      AS product_b_category,
    COUNT(*)         AS times_bought_together
FROM fact_sales f1
JOIN fact_sales f2
    ON  f1.order_number = f2.order_number
    AND f1.product_key  < f2.product_key
JOIN dim_product pa ON f1.product_key = pa.product_key
JOIN dim_product pb ON f2.product_key = pb.product_key
GROUP BY pa.name, pa.category, pb.name, pb.category
ORDER BY times_bought_together DESC
LIMIT 20;

-- Reading this in French :
-- "Pour chaque paire de produits, montre leurs noms et categories,
--  et combien de fois ils sont achetes ensemble."

-- ------------------------------------------------------------
-- Step 4 : Cross-category pairs only
-- ------------------------------------------------------------
-- The CEO asks : "Which products from DIFFERENT categories are
-- frequently purchased together?" (cross-selling opportunities)

SELECT
    pa.category      AS category_a,
    pb.category      AS category_b,
    COUNT(*)         AS cross_category_pairs
FROM fact_sales f1
JOIN fact_sales f2
    ON  f1.order_number = f2.order_number
    AND f1.product_key  < f2.product_key
JOIN dim_product pa ON f1.product_key = pa.product_key
JOIN dim_product pb ON f2.product_key = pb.product_key
WHERE pa.category < pb.category   -- different categories, no duplicates
GROUP BY pa.category, pb.category
ORDER BY cross_category_pairs DESC;

-- ============================================================
-- KEY CONCEPTS
-- ============================================================
-- SELF-JOIN  : joining a table to itself (same table, two aliases)
-- < instead of != : avoids counting (A,B) and (B,A) as two pairs
-- Two JOINs to dim_product : one for each "side" of the pair
-- This pattern scales to any "co-occurrence" question :
--   - products bought together
--   - customers visiting same stores
--   - items returned together
-- ============================================================
