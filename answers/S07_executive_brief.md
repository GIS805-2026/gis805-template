# Executive Brief S07

## CEO Question
Où se produisent les retards de livraison -- par date de commande, date d'expédition, date de livraison et géographie ?

## Executive Answer
<!-- Répondez brièvement et directement. Le CEO lira cette section en premier. -->


## What Changed This Week
- 
- 
- 

## Modeling Decisions

### Grain
<!-- Quel est le grain de votre table de faits ? -->

### Facts
<!-- Quelles mesures stockez-vous ? -->

### Dimensions
<!-- Role-playing dates ? Hiérarchies géographiques ? Mini-dimensions ? -->
<!-- Même dim_date, 3 alias : order_date_key, ship_date_key, delivery_date_key -->

### Temporal / Historical Choices
<!-- Politique de membres inconnus (NULL handling) ? -->
<!-- Enregistrement "Inconnu" (surrogate key = -1) au lieu de NULL. Pourquoi ? -->

### Assumptions
<!-- Quelles hypothèses avez-vous faites ? -->

## Hiérarchie géographique
<!-- Magasin -> ville -> région -> province -- permet le drill-down -->


## Analyse des délais
<!-- SQL : délai moyen commande->expédition et expédition->livraison par région -->


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
