# Executive Brief S08

## CEO Question
Comment allouer les coûts et comprendre les segments clients qui se chevauchent sans double-compter ?

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
<!-- Quelles mesures stockez-vous ? Allocation vs duplication ? -->

### Dimensions
<!-- Ponts pondérés ? Relations many-to-many ? -->
<!-- Structure : customer_key, segment_key, weight. SUM(weight) = 1.0 par client -->

### Temporal / Historical Choices
<!-- SCD3/hybride ? Comment gérez-vous les changements de segment ? -->
<!-- dim_customer : current_segment + previous_segment dans la même ligne -->

### Assumptions
<!-- Quelles hypothèses avez-vous faites ? -->

## Preuve de réconciliation
<!-- SQL : SUM(revenue * weight) = SUM(revenue) total -- pas de double-comptage -->


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
