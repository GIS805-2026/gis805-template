-- ============================================================
-- junk_order_profile.sql — Dimension poubelle (S04)
-- ============================================================
-- Consolide 8+ drapeaux booléens en profils nommés
-- Ex: "Express VIP" = express + loyalty + priority
-- Évite l'explosion de dimensions séparées par drapeau
-- ============================================================

-- TODO (S04) : Écrire le DDL CREATE TABLE
--   - order_profile_key (surrogate)
--   - Colonnes booléennes : is_express, is_loyalty, is_priority, etc.
--   - profile_name : étiquette lisible (ex: "Express VIP", "Standard")

-- TODO (S04) : Écrire la requête INSERT avec les combinaisons observées
--   (pas les 256 possibles, seulement celles qui existent dans les données)
