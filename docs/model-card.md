# Model Card — NexaMart Dimensional Warehouse

> À compléter en S11. Ce document est le résumé exécutif de votre modèle dimensionnel.
> Test : un nouvel analyste comprend votre entrepôt lundi matin sans vous parler.

## Tables de faits

| Table | Grain | Mesures | Additivité | Type |
|-------|-------|---------|------------|------|
| fact_sales | | | | Transaction |
| fact_returns | | | | Transaction |
| fact_budget | | | | Périodique |
| fact_daily_inventory | | | | Snapshot périodique |
| fact_order_pipeline | | | | Snapshot accumulant |

## Dimensions

| Dimension | SCD Type | Justification |
|-----------|----------|---------------|
| dim_date | | |
| dim_product | | |
| dim_store | | |
| dim_customer | | |
| dim_channel | | |

## Politique NULL

<!-- Enregistrement inconnu : surrogate key = -1, nom = "Inconnu" -->

## Ponts

<!-- bridge_customer_segment : contrainte SUM(weight) = 1.0 -->

## Risques et limitations connus

<!-- Qu'est-ce que votre modèle ne couvre PAS? -->
