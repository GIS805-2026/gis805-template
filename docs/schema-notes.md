# Notes sur le Schéma Dimensionnel

## Vue d'ensemble du modèle

[Décrivez ici la structure générale de votre data warehouse]

## Tables de faits

### fact_[nom]

**Grain** : [Une ligne représente quoi exactement?]

**Mesures** :
| Colonne | Type | Description | Agrégation |
|---------|------|-------------|------------|
| | | | SUM/AVG/COUNT/etc. |

**Clés étrangères** :
| Colonne | Dimension | Description |
|---------|-----------|-------------|
| | | |

**Notes de design** :
- 

---

## Tables de dimensions

### dim_[nom]

**Type** : [SCD Type 1 / Type 2 / Type 3 / autre]

**Attributs** :
| Colonne | Type | Description | Hiérarchie |
|---------|------|-------------|------------|
| | | | |

**Clé naturelle** : 

**Clé de substitution** : 

**Notes de design** :
- 

---

## Vues analytiques

### v_[nom]

**But** : [Quelle question cette vue répond-elle?]

**Tables jointes** :
- 

**Logique métier** :
```sql
-- Résumé de la logique
```

---

## Schéma visuel

```
[Dessinez ici votre schéma en étoile avec ASCII art ou décrivez-le]

        dim_date
            |
dim_store --+-- fact_sales --+-- dim_product
            |                |
        dim_customer    dim_promotion
```
