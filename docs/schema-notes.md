# Notes de schéma — NexaMart

> Diagrammes Mermaid, notes de design, évolution du schéma au fil des séances.

## S02 — Première étoile (fact_sales)

```mermaid
erDiagram
    fact_sales }|--|| dim_date : date_key
    fact_sales }|--|| dim_product : product_key
    fact_sales }|--|| dim_store : store_key
    fact_sales }|--|| dim_customer : customer_key
    fact_sales }|--|| dim_channel : channel_key
```

<!-- Mettez à jour ce diagramme au fil des séances -->
