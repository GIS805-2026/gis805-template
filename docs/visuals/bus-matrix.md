# Bus matrix NexaMart : processus × dimensions conformes

La *bus matrix* de Kimball est le plan d'ensemble de votre entrepôt.
Une case cochée = ce processus utilise cette dimension. Deux processus
qui cochent la même dimension peuvent être joints en **drill-across**
sans risque — c'est la définition opérationnelle d'une dimension
conforme.

## Pourquoi on en a besoin

Sans bus matrix, chaque session ajoute une table de faits isolée et
personne ne voit les chevauchements. Avec la matrice, on voit
immédiatement :

- Quelles dimensions sont partagées (→ drill-across possible).
- Quelles dimensions sont uniques à un processus (→ pas de partage).
- Quelles colonnes doivent rester identiques partout.

## La matrice NexaMart (telle que construite S02 → S09)

| Processus / Fact               | dim_date | dim_customer | dim_product | dim_store | dim_channel | dim_campaign | dim_segment |
|---|---|---|---|---|---|---|---|
| `fact_sales` (S02)             | X | X | X | X | X |   |   |
| `fact_returns` (S05)           | X | X | X | X | X |   |   |
| `fact_daily_inventory` (S04)   | X |   | X | X |   |   |   |
| `fact_budget` (S06)            | X |   | X | X |   |   |   |
| `fact_shipment` (S07)          | X | X | X | X |   |   |   |
| `fact_orders_transaction` (S09)| X | X |   | X | X |   |   |
| `fact_inventory_snapshot` (S09)| X |   | X | X |   |   |   |
| `fact_order_pipeline` (S09)    | X | X | X | X |   |   |   |
| `fact_promo_exposure` (S09)    | X | X | X |   | X | X |   |
| `bridge_customer_segment` (S08)|   | X |   |   |   |   | X |

## Comment la lire

### Règle 1 — Deux faits partagent une ligne de X ⇒ drill-across OK

`fact_sales` et `fact_returns` partagent `dim_date`, `dim_customer`,
`dim_product`, `dim_store` et `dim_channel`. On peut donc produire un
rapport "ventes nettes = ventes − retours" par n'importe quelle
combinaison de ces cinq axes. C'est exactement le pattern S06.

### Règle 2 — Deux faits ne partagent rien ⇒ pas de drill-across

`fact_promo_exposure` partage `dim_campaign` avec… personne. Une
question "revenu par campagne" ne peut pas se répondre en joignant
`fact_promo_exposure` et `fact_sales` directement — il faut passer par
le client (exposé via `dim_customer` + la date d'exposition) puis
filtrer les ventes post-exposition. C'est une conversion d'attribution,
pas un drill-across.

### Règle 3 — Une case X = promesse de conformité

Si `fact_sales.customer_key` et `fact_returns.customer_key` ne
pointent pas vers **la même** `dim_customer`, la matrice ment. Le check
`test_conformance_dim_customer` dans `validation/checks.sql` enforce
que les deux FK ont les mêmes valeurs distinctes.

## Exemples concrets de drill-across depuis la matrice

### Question 1 : "Taux de retour par catégorie et par région, T1 2026"

Dimensions partagées requises : `dim_date`, `dim_product`, `dim_store`.
Les trois sont cochées à la fois pour `fact_sales` et `fact_returns`.
→ **Drill-across faisable**.

### Question 2 : "Revenu vs budget par région et par mois"

Dimensions partagées requises : `dim_date`, `dim_store`. Les deux
sont cochées pour `fact_sales` et `fact_budget`.
→ **Drill-across faisable** (c'est exactement le livrable S06).

### Question 3 : "Stock moyen par campagne"

`fact_inventory_snapshot` ne coche pas `dim_campaign`.
→ **Drill-across impossible.** La question doit être reformulée
(ex. "stock moyen pendant la période où la campagne était active", qui
passe par `dim_date.is_campaign_day` — attribut dans `dim_date`, pas
jointure entre faits).

## Diagramme visuel compact

```text
                 date  cust  prod  store chan  camp  seg
fact_sales       [X]   [X]   [X]   [X]   [X]   [ ]   [ ]
fact_returns     [X]   [X]   [X]   [X]   [X]   [ ]   [ ]
fact_inventory   [X]   [ ]   [X]   [X]   [ ]   [ ]   [ ]
fact_budget      [X]   [ ]   [X]   [X]   [ ]   [ ]   [ ]
fact_shipment    [X]   [X]   [X]   [X]   [ ]   [ ]   [ ]
fact_promo_exp   [X]   [X]   [X]   [ ]   [X]   [X]   [ ]
bridge_segment   [ ]   [X]   [ ]   [ ]   [ ]   [ ]   [X]
                  ▲                                   ▲
                  │                                   │
      conforme entre 7 faits           unique au bridge
```

## À retenir

1. La bus matrix est le **contrat** entre toutes les tables de faits.
2. Une **colonne** de la matrice représente une dimension conforme.
3. Deux **lignes** qui partagent au moins une colonne cochée peuvent
   être combinées en drill-across.
4. Maintenez la matrice **à jour** à chaque nouvelle table de faits ;
   sinon elle ment rapidement.

Le pattern drill-across lui-même est illustré dans
`docs/visuals/drill-across-pattern.md` et expliqué pas-à-pas dans
`docs/worked-examples/s06-drill-across-walkthrough.md`.
