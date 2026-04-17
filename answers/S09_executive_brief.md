# Executive Brief S09

## CEO Question
Quels processus NexaMart sont transactionnels, quels sont des snapshots, et quels sont de simples présences ?

## Executive Answer
<!-- Répondez brièvement et directement. Le CEO lira cette section en premier. -->


## What Changed This Week
- 
- 
- 

## Modeling Decisions

### Grain
<!-- Quel est le grain de chaque type de table de faits ? -->

### Facts
<!-- Transaction facts ? Periodic snapshots ? Accumulating snapshots ? Factless facts ? -->

### Dimensions
<!-- Quels axes d'analyse (qui, quoi, quand, où) ? -->

### Temporal / Historical Choices
<!-- Comportement de mise à jour par type de fait ? -->

### Assumptions
<!-- Quelles hypothèses avez-vous faites ? -->

## Arbre de décision

| Processus | Type de fait | Justification |
|-----------|-------------|---------------|
| Ventes | Transaction | |
| Inventaire quotidien | Snapshot périodique | |
| Pipeline commandes | Snapshot accumulant | |
| Exposition promo | Factless fact | |

## Snapshot périodique vs transaction
<!-- SQL comparant fact_sales (transaction) et fact_daily_inventory (snapshot) -->


## Snapshot accumulant
<!-- fact_order_pipeline : colonnes de date par étape, UPDATE à chaque avancement -->


## Fait sans mesure
<!-- fact_promo_exposure : l'existence = le fait. COUNT(*) = mesure implicite -->


## Validation
- **Metric reconciliation:** 
- **Duplicate risk:** 
- **Row-count check:** 
- **Sanity check:** 

## Risks / Limitations
- 
- 

## Next Recommendation to the Board
- 
