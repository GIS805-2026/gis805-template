# Dictionnaire de données — NexaMart

Ce document décrit chaque fichier CSV produit par `make generate`
et chaque colonne qu'il contient. Il est **régénéré automatiquement**
par `scripts/regen_data_dictionary.py` à chaque changement d'un
générateur sous `scripts/datagen/`. Ne le modifiez pas à la main —
vos ajustements seraient écrasés au prochain build. Pour enrichir
la description d'une colonne, éditez `COLUMN_DOCS` dans le script
de régénération.

## Lecture

- `team_N` = votre numéro d'équipe, calculé depuis votre username GitHub.
- Les tables `raw_*` dans DuckDB sont chargées depuis ces CSV par `make load`.
- Les colonnes marquées `_TODO` n'ont pas encore de description — signalez-le si vous en rencontrez une.

## Dimensions conformées partagées

*Lu par toutes les sessions.*

### `data/synthetic/team_N/shared/dim_channel.csv`

*Source : `scripts/datagen/gen_shared_seeds.py`*

| Colonne | Description |
|---|---|
| `channel_id` | Clé naturelle du canal (CH-WEB, CH-APP, etc.). |
| `channel_name` | Libellé du canal de vente. |
| `channel_type` | Famille du canal (online, physical, phone). |

### `data/synthetic/team_N/shared/dim_customer.csv`

*Source : `scripts/datagen/gen_shared_seeds.py`*

| Colonne | Description |
|---|---|
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `first_name` | Prénom du client. |
| `last_name` | Nom de famille du client. |
| `email_domain` | Domaine du courriel (pour analyses anonymes). |
| `city` | Ville du magasin ou du client. |
| `province` | Province canadienne (QC, ON, BC, AB). |
| `loyalty_segment` | Segment de fidélité (Platinum, Gold, Silver, Bronze, New, Inactive). |
| `join_date` | Date de création du compte client. |

### `data/synthetic/team_N/shared/dim_date.csv`

*Source : `scripts/datagen/gen_shared_seeds.py`*

| Colonne | Description |
|---|---|
| `date_key` | Clé naturelle de la date, format ISO YYYY-MM-DD. |
| `year` | Année (entier). |
| `quarter` | Trimestre 1-4. |
| `month` | Mois 1-12. |
| `month_name` | Nom du mois en anglais (pour affichage). |
| `week_iso` | Numéro de semaine ISO 8601. |
| `day_of_week` | Jour de la semaine 1-7 (lundi=1). |
| `day_name` | Nom du jour en anglais. |
| `is_weekend` | 1 si samedi/dimanche, sinon 0. |

### `data/synthetic/team_N/shared/dim_product.csv`

*Source : `scripts/datagen/gen_shared_seeds.py`*

| Colonne | Description |
|---|---|
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `product_name` | Libellé commercial du produit. |
| `category` | Catégorie haut niveau (Electronics, Clothing, etc.). |
| `subcategory` | Sous-catégorie interne. |
| `brand` | Marque du produit. |
| `unit_cost` | Coût unitaire payé au fournisseur. |
| `unit_price` | Prix de vente suggéré (avant rabais). |

### `data/synthetic/team_N/shared/dim_store.csv`

*Source : `scripts/datagen/gen_shared_seeds.py`*

| Colonne | Description |
|---|---|
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `store_name` | Nom complet du magasin. |
| `city` | Ville du magasin ou du client. |
| `region` | Région administrative (Québec, Ontario, etc.). |
| `province` | Province canadienne (QC, ON, BC, AB). |
| `store_type` | Type de magasin (flagship, standard, compact, express). |

## S02 — Étoile & grain

*Grain d'une ligne de commande.*

### `data/synthetic/team_N/s02/fact_sales.csv`

*Source : `scripts/datagen/gen_s02_star_schema.py`*

| Colonne | Description |
|---|---|
| `sale_line_id` | Identifiant unique de la ligne de vente (grain de fact_sales). |
| `order_number` | Numéro de commande (dimension dégénérée). Une commande = plusieurs lignes. |
| `order_date` | Date de la commande. |
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `channel_id` | Clé naturelle du canal (CH-WEB, CH-APP, etc.). |
| `quantity` | Quantité vendue sur la ligne. |
| `unit_price` | Prix de vente suggéré (avant rabais). |
| `discount_pct` | Pourcentage de rabais appliqué (0 à 25). |
| `net_price` | Prix net après rabais. |
| `line_total` | Total de la ligne (net_price × quantity). |

## S03 — Slowly Changing Dimensions

*Événements de changement à historiser.*

### `data/synthetic/team_N/s03/customer_changes.csv`

*Source : `scripts/datagen/gen_s03_scd_changes.py`*

| Colonne | Description |
|---|---|
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `change_date` | Date de l'événement de changement. |
| `change_type` | Nature du changement (city_move, segment_change, name_correction, province_change, region_reassign, type_upgrade). |
| `field_changed` | Champ concerné (city, segment, name, province). |
| `old_value` | Valeur avant le changement. |
| `new_value` | Valeur après le changement. |

### `data/synthetic/team_N/s03/store_changes.csv`

*Source : `scripts/datagen/gen_s03_scd_changes.py`*

| Colonne | Description |
|---|---|
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `change_date` | Date de l'événement de changement. |
| `change_type` | Nature du changement (city_move, segment_change, name_correction, province_change, region_reassign, type_upgrade). |
| `old_value` | Valeur avant le changement. |
| `new_value` | Valeur après le changement. |

## S04 — Dimensions dégénérées + junk

*Commandes avec drapeaux opérationnels.*

### `data/synthetic/team_N/s04/order_lines.csv`

*Source : `scripts/datagen/gen_s04_basket_flags.py`*

| Colonne | Description |
|---|---|
| `line_id` | Identifiant de ligne de commande (local au fichier S04). |
| `order_number` | Numéro de commande (dimension dégénérée). Une commande = plusieurs lignes. |
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `quantity` | Quantité vendue sur la ligne. |
| `unit_price` | Prix de vente suggéré (avant rabais). |
| `line_total` | Total de la ligne (net_price × quantity). |

### `data/synthetic/team_N/s04/orders.csv`

*Source : `scripts/datagen/gen_s04_basket_flags.py`*

| Colonne | Description |
|---|---|
| `order_number` | Numéro de commande (dimension dégénérée). Une commande = plusieurs lignes. |
| `order_date` | Date de la commande. |
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `channel_id` | Clé naturelle du canal (CH-WEB, CH-APP, etc.). |
| `is_gift_wrapped` | Emballage cadeau demandé (0/1). |
| `is_express_shipping` | Livraison express (0/1). |
| `is_loyalty_redeemed` | Points de fidélité utilisés (0/1). |
| `is_promo_applied` | Promotion appliquée (0/1). |
| `is_employee_purchase` | Achat par un employé (0/1). |
| `is_online_pickup` | Ramassage en magasin après commande en ligne (0/1). |
| `is_fragile` | Article fragile (0/1). |
| `is_oversized` | Article hors gabarit (0/1). |

## S06 — Intégration entreprise

*Multi-fait : ventes, retours, inventaire, budget.*

### `data/synthetic/team_N/s06/fact_budget.csv`

*Source : `scripts/datagen/gen_s06_enterprise_integration.py`*

| Colonne | Description |
|---|---|
| `budget_id` | Identifiant unique de la ligne budgétaire. |
| `budget_month` | Premier jour du mois budgétaire (YYYY-MM-01). |
| `category` | Catégorie haut niveau (Electronics, Clothing, etc.). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `target_revenue` | Chiffre d'affaires cible pour la catégorie × magasin × mois. |
| `target_units` | Volume cible associé au revenue budget. |

### `data/synthetic/team_N/s06/fact_inventory_snapshot.csv`

*Source : `scripts/datagen/gen_s06_enterprise_integration.py`*

| Colonne | Description |
|---|---|
| `snapshot_id` | Identifiant unique du snapshot (grain : produit × magasin × date). |
| `snapshot_date` | Date du snapshot d'inventaire. |
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `quantity_on_hand` | Stock disponible en magasin au jour du snapshot. |
| `quantity_on_order` | Stock commandé au fournisseur, pas encore reçu. |
| `reorder_point` | Seuil en dessous duquel réapprovisionner. |

### `data/synthetic/team_N/s06/fact_returns.csv`

*Source : `scripts/datagen/gen_s06_enterprise_integration.py`*

| Colonne | Description |
|---|---|
| `return_id` | Identifiant unique du retour. |
| `original_sale_line_id` | Clé étrangère vers fact_sales.sale_line_id. |
| `return_date` | Date du retour. |
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `return_quantity` | Quantité retournée (≤ quantity vendue). |
| `refund_amount` | Montant remboursé au client. |
| `return_reason` | Motif du retour (defective, wrong_size, changed_mind, damaged_shipping, duplicate). |

### `data/synthetic/team_N/s06/fact_sales.csv`

*Source : `scripts/datagen/gen_s06_enterprise_integration.py`*

| Colonne | Description |
|---|---|
| `sale_line_id` | Identifiant unique de la ligne de vente (grain de fact_sales). |
| `order_number` | Numéro de commande (dimension dégénérée). Une commande = plusieurs lignes. |
| `order_date` | Date de la commande. |
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `channel_id` | Clé naturelle du canal (CH-WEB, CH-APP, etc.). |
| `quantity` | Quantité vendue sur la ligne. |
| `unit_price` | Prix de vente suggéré (avant rabais). |
| `discount_pct` | Pourcentage de rabais appliqué (0 à 25). |
| `net_price` | Prix net après rabais. |
| `line_total` | Total de la ligne (net_price × quantity). |

## S07 — Dimensions spéciales

*Dates à rôles, hiérarchies, NULLs.*

### `data/synthetic/team_N/s07/customer_profile_bands.csv`

*Source : `scripts/datagen/gen_s07_special_dims.py`*

| Colonne | Description |
|---|---|
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `age_band` | Tranche d'âge (18-25, 26-35, 36-45, 46-55, 56-65, 65+). |
| `spend_band` | Tranche de dépense (low, medium, high, premium). |
| `frequency_band` | Fréquence d'achat (rare, occasional, regular, frequent). |

### `data/synthetic/team_N/s07/dim_geography.csv`

*Source : `scripts/datagen/gen_s07_special_dims.py`*

| Colonne | Description |
|---|---|
| `city` | Ville du magasin ou du client. |
| `region` | Région administrative (Québec, Ontario, etc.). |
| `province` | Province canadienne (QC, ON, BC, AB). |
| `country` | Pays (toujours 'Canada' dans ce jeu). |

### `data/synthetic/team_N/s07/fact_shipment.csv`

*Source : `scripts/datagen/gen_s07_special_dims.py`*

| Colonne | Description |
|---|---|
| `shipment_id` | Identifiant unique d'expédition. |
| `order_date` | Date de la commande. |
| `ship_date` | Date d'expédition (différente de order_date). |
| `delivery_date` | Date de livraison (NULL si en transit). |
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `channel_id` | Clé naturelle du canal (CH-WEB, CH-APP, etc.). |
| `carrier` | Transporteur (NULL si inconnu). |
| `destination_city` | Ville de destination. |
| `destination_province` | Province de destination. |
| `delivery_status` | État (delivered, in_transit, returned, failed). |
| `shipping_cost` | Coût d'expédition facturé à NexaMart. |

## S08 — Ponts pondérés & SCD3

*Relations M:N et historique partiel.*

### `data/synthetic/team_N/s08/bridge_campaign_allocation.csv`

*Source : `scripts/datagen/gen_s08_bridges.py`*

| Colonne | Description |
|---|---|
| `allocation_id` | Identifiant unique de la ligne d'allocation campagne. |
| `campaign_id` | Clé naturelle de la campagne (CMP-NNN). |
| `segment` | Segment de fidélité associé (peut différer du segment 'principal'). |
| `budget_weight` | Pondération du budget pour ce segment (somme = 1.0 par campagne). |
| `planned_spend` | Dépense marketing planifiée, en dollars. |

### `data/synthetic/team_N/s08/bridge_customer_segment.csv`

*Source : `scripts/datagen/gen_s08_bridges.py`*

| Colonne | Description |
|---|---|
| `bridge_id` | Identifiant unique de la ligne du pont (une ligne = un client × un segment). |
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `segment` | Segment de fidélité associé (peut différer du segment 'principal'). |
| `weight` | Pondération du segment pour ce client (somme = 1.0 par client). |
| `effective_date` | Date d'entrée en vigueur de l'assignation au segment. |
| `is_primary` | 1 pour le segment de plus grand poids, 0 sinon. |

### `data/synthetic/team_N/s08/customer_scd3_history.csv`

*Source : `scripts/datagen/gen_s08_bridges.py`*

| Colonne | Description |
|---|---|
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `current_segment` | Segment actuel du client (SCD3). |
| `previous_segment` | Segment précédent du client (NULL si jamais changé). |
| `segment_change_date` | Date du dernier changement de segment (NULL si aucun). |
| `city` | Ville du magasin ou du client. |
| `province` | Province canadienne (QC, ON, BC, AB). |

### `data/synthetic/team_N/s08/dim_segment_outrigger.csv`

*Source : `scripts/datagen/gen_s08_bridges.py`*

| Colonne | Description |
|---|---|
| `segment` | Segment de fidélité associé (peut différer du segment 'principal'). |
| `discount_pct` | Pourcentage de rabais appliqué (0 à 25). |
| `free_shipping` | Livraison gratuite incluse pour le segment (0/1). |
| `priority_support` | Service client prioritaire (0/1). |
| `annual_reward_value` | Récompense annuelle en dollars pour le segment. |

## S09 — Quatre types de faits

*Transaction, snapshot, accumulating, factless.*

### `data/synthetic/team_N/s09/fact_daily_inventory.csv`

*Source : `scripts/datagen/gen_s09_fact_types.py`*

| Colonne | Description |
|---|---|
| `snapshot_id` | Identifiant unique du snapshot (grain : produit × magasin × date). |
| `snapshot_date` | Date du snapshot d'inventaire. |
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `quantity_on_hand` | Stock disponible en magasin au jour du snapshot. |
| `quantity_on_order` | Stock commandé au fournisseur, pas encore reçu. |
| `days_of_supply` | Jours de couverture au rythme de vente courant (mesure semi-additive). |

### `data/synthetic/team_N/s09/fact_order_pipeline.csv`

*Source : `scripts/datagen/gen_s09_fact_types.py`*

| Colonne | Description |
|---|---|
| `pipeline_id` | Identifiant unique de la ligne de pipeline. |
| `order_id` | Identifiant de la commande (ORD-NNNNNN). |
| `order_date` | Date de la commande. |
| `payment_date` | Date du paiement (NULL si en attente). |
| `pick_date` | Date de préparation en entrepôt (NULL si pas encore). |
| `ship_date` | Date d'expédition (différente de order_date). |
| `delivery_date` | Date de livraison (NULL si en transit). |
| `current_status` | Jalon atteint (completed, pending_ship, pending_pick, pending_payment, cancelled). |
| `days_order_to_deliver` | Délai commande → livraison en jours (NULL si non complété). |
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |

### `data/synthetic/team_N/s09/fact_orders_transaction.csv`

*Source : `scripts/datagen/gen_s09_fact_types.py`*

| Colonne | Description |
|---|---|
| `transaction_id` | Identifiant unique de la transaction (grain fact_orders_transaction). |
| `transaction_date` | Date de la transaction. |
| `transaction_type` | Type d'événement (sale, return, exchange). |
| `product_id` | Clé naturelle du produit (PRD-NNNN). |
| `store_id` | Clé naturelle du magasin (STR-NNN). |
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `quantity` | Quantité vendue sur la ligne. |
| `amount` | Montant de la transaction (négatif pour un retour). |

### `data/synthetic/team_N/s09/fact_promo_exposure.csv`

*Source : `scripts/datagen/gen_s09_fact_types.py`*

| Colonne | Description |
|---|---|
| `exposure_id` | Identifiant unique de l'exposition à une campagne. |
| `exposure_date` | Date où le client a été exposé à la campagne. |
| `campaign_id` | Clé naturelle de la campagne (CMP-NNN). |
| `customer_id` | Clé naturelle du client (CUS-NNNNN). |
| `channel_id` | Clé naturelle du canal (CH-WEB, CH-APP, etc.). |
