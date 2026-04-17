# Assignment 2 Submission

## Informations

**Nom** : [Votre nom]
**CIP** : [Votre CIP]
**Date** : YYYY-MM-DD

---

## Resume du modele

[Decrivez brievement votre schema en etoile]

---

## Tables de faits

### fact_sales

**Grain** : [Une ligne = quoi?]

**Mesures** :
| Mesure | Formule | Description |
|--------|---------|-------------|
| | | |

**Cles** :
| FK | Dimension |
|----|-----------|
| | |

---

## Tables de dimensions

### dim_customer
[Decrivez brievement]

### dim_product
[Decrivez brievement]

### dim_store
[Decrivez brievement]

### dim_date
[Decrivez brievement]

---

## Decisions de modelisation

### Decision 1 : [Titre]
**Choix** :
**Justification** :

### Decision 2 : [Titre]
**Choix** :
**Justification** :

---

## Validation

### Tests executes
- [ ] 00_existence.sql
- [ ] 01_row_counts.sql
- [ ] 02_key_integrity.sql
- [ ] 03_null_policy.sql
- [ ] 04_reconciliation.sql

### Resultats
[Resumez les resultats]

---

## Artefacts livres

| Fichier | Description |
|---------|-------------|
| `db/nexamart.duckdb` | Base avec dims et fact |
| `sql/dims/*.sql` | Scripts de creation dims |
| `sql/facts/*.sql` | Scripts de creation facts |
| `docs/schema-notes.md` | Documentation du schema |

---

## Reflexion

[Qu'avez-vous appris? Quels trade-offs avez-vous faits?]
