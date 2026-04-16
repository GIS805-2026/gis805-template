# Assignment 2 Submission

## Informations

**Nom** : [Votre nom]
**CIP** : [Votre CIP]
**Date** : YYYY-MM-DD

---

## Résumé du modèle

[Décrivez brièvement votre schéma en étoile]

---

## Tables de faits

### fact_sales

**Grain** : [Une ligne = quoi?]

**Mesures** :
| Mesure | Formule | Description |
|--------|---------|-------------|
| | | |

**Clés** :
| FK | Dimension |
|----|-----------|
| | |

---

## Tables de dimensions

### dim_customer
[Décrivez brièvement]

### dim_product
[Décrivez brièvement]

### dim_store
[Décrivez brièvement]

### dim_date
[Décrivez brièvement]

---

## Décisions de modélisation

### Décision 1 : [Titre]
**Choix** : 
**Justification** : 

### Décision 2 : [Titre]
**Choix** : 
**Justification** : 

---

## Validation

### Tests exécutés
- [ ] 00_existence.sql
- [ ] 01_row_counts.sql
- [ ] 02_key_integrity.sql
- [ ] 03_null_policy.sql
- [ ] 04_reconciliation.sql

### Résultats
[Résumez les résultats]

---

## Artefacts livrés

| Fichier | Description |
|---------|-------------|
| `db/nexamart.duckdb` | Base avec dims et fact |
| `sql/dims/*.sql` | Scripts de création dims |
| `sql/facts/*.sql` | Scripts de création facts |
| `docs/schema-notes.md` | Documentation du schéma |

---

## Réflexion

[Qu'avez-vous appris? Quels trade-offs avez-vous faits?]
