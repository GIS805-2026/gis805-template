# Schéma en étoile — NexaMart

Le diagramme ci-dessous est rendu automatiquement par GitHub et par
la plupart des éditeurs Markdown (VS Code inclus). Aucun PNG à
maintenir : la source Mermaid est la seule source de vérité.

## Étoile minimale de S02 (`fact_sales` + 5 dimensions)

```mermaid
erDiagram
    DIM_DATE ||--o{ FACT_SALES : "order_date"
    DIM_PRODUCT ||--o{ FACT_SALES : "product_key"
    DIM_STORE ||--o{ FACT_SALES : "store_key"
    DIM_CUSTOMER ||--o{ FACT_SALES : "customer_key"
    DIM_CHANNEL ||--o{ FACT_SALES : "channel_key"

    FACT_SALES {
        int sale_line_id PK
        string order_number "degenerate dim"
        int order_date FK
        int product_key FK
        int store_key FK
        int customer_key FK
        int channel_key FK
        int quantity "additive"
        decimal unit_price "additive"
        decimal line_total "additive"
    }
    DIM_DATE {
        int date_key PK
        date full_date
        int year
        int quarter
        int month
        string year_month "conforming"
        string day_name
        bool is_weekend
    }
    DIM_PRODUCT {
        int product_key PK
        string product_id UK
        string product_name
        string category
        string subcategory
        string brand
    }
    DIM_STORE {
        int store_key PK
        string store_id UK
        string store_name
        string province
        string region "conforming"
        string district
    }
    DIM_CUSTOMER {
        int customer_key PK
        string customer_id "natural"
        string full_name
        string city
        string loyalty_segment "SCD2"
        date effective_from
        date effective_to
        bool is_current
    }
    DIM_CHANNEL {
        int channel_key PK
        string channel_id UK
        string channel_name
        string channel_type
    }
```

## Comment lire ce schéma

- **Centre.** `FACT_SALES` contient les mesures (`quantity`, `line_total`) et
  autant de FK que de dimensions interrogées.
- **Branches.** Chaque dimension est une table séparée, reliée par une
  **surrogate key** (`*_key`) — jamais par la clé naturelle (`*_id`).
- **Grain.** Une ligne de `FACT_SALES` = une ligne de commande
  (`order_number` + `sale_line_id`). Le grain est fixé en S02 et ne
  change plus.
- **Dimensions conformes.** `year_month` dans `DIM_DATE` et `region`
  dans `DIM_STORE` sont identifiées comme conformes : elles
  apparaissent avec les **mêmes valeurs** dans toutes les autres fact
  tables (`fact_returns`, `fact_budget`, etc.) et rendent le
  drill-across possible. Voir `docs/visuals/bus-matrix.md`.

## Évolution au fil des séances

Cette étoile grandit. À la fin du trimestre, le même schéma compte
**10 tables de faits** (5 transactions, 2 snapshots, 1 accumulating,
1 factless, 1 bridge) et **7 dimensions** (ajout de `dim_campaign`,
`dim_segment`, et `dim_customer_activity` en mini-dim).

Les autres visuels décomposent chaque pattern :

- `docs/visuals/scd-type2-before-after.md` — comment `DIM_CUSTOMER`
  gère un changement de segment sans réécrire l'histoire.
- `docs/visuals/drill-across-pattern.md` — combiner `FACT_SALES` et
  `FACT_RETURNS` sans gonfler les totaux.
- `docs/visuals/bridge-m2n.md` — quand un client appartient à
  plusieurs segments simultanément.
- `docs/visuals/bus-matrix.md` — grille maîtresse des dimensions
  conformes à travers tous les faits.
- `docs/visuals/promo-exposure-factless.md` — mesurer ce qui s'est
  passé sans colonne numérique.

## Pour aller plus loin

Voir `docs/kimball-cheatsheet.md` pour le vocabulaire et
`docs/worked-examples/s02-star-schema-walkthrough.md` pour le
pas-à-pas de construction.
