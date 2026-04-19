# Kimball en une page

Gardez cette page ouverte à côté de votre SQL. Elle répond aux cinq
questions qui reviennent le plus souvent.

## 1. Qu'est-ce qu'un fait vs une dimension ?

| | Fait | Dimension |
|---|---|---|
| **Contenu** | ce qu'on **mesure** (chiffres) | le **contexte** (mots, catégories) |
| **Exemple** | revenu, quantité, délai | segment client, nom produit, date |
| **Colonnes typiques** | `*_key` (FK) + mesures | `*_key` (PK surrogate) + `*_id` (naturel) + descripteurs |
| **Nombre de lignes** | beaucoup (une par événement) | peu (une par entité) |
| **Test mental** | *"puis-je le sommer ?"* → oui | *"est-ce un mot dans la question ?"* → oui |

## 2. Qu'est-ce que le grain ?

Le **grain** est la phrase en français qui décrit ce qu'une ligne de
votre table de faits représente.

```text
Grain de fact_sales        : une ligne = une ligne de commande
Grain de fact_inventory    : une ligne = un produit × un magasin × un jour
Grain de fact_promo        : une ligne = un client × une campagne × une date
```

**Règle.** Si vous ne pouvez pas énoncer le grain en une phrase sans
"et/ou", votre grain n'est pas prêt.

## 3. Qu'est-ce qu'un schéma en étoile ?

```text
              ┌──────────┐
              │ dim_date │
              └────┬─────┘
 ┌──────────┐     │    ┌───────────┐
 │ dim_cust │─────┼────│ dim_store │
 └──────────┘     │    └───────────┘
              ┌───▼───┐
              │ FAIT  │
              └───┬───┘
 ┌──────────┐     │    ┌────────────┐
 │ dim_prod │─────┼────│ dim_channel│
 └──────────┘          └────────────┘
```

Le fait au centre, les dimensions autour, chacune reliée par une clé
substitut. Une requête typique fait **1 JOIN par dimension interrogée**.

## 4. SCD 1/2/3, en trois boxes

```
┌─────────────────────────────────────────────┐
│ SCD 1 : écraser                              │
│                                              │
│ city : Montréal → Sherbrooke                 │
│                                              │
│ Perd l'histoire. Utiliser pour corrections.  │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ SCD 2 : historiser (par défaut)              │
│                                              │
│ L1 | Montréal | effective_from | effective_to│
│ L2 | Sherbrooke | 2025-06-14 | 9999-12-31   │
│                                              │
│ Garde tout. Joint via surrogate_key.         │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ SCD 3 : garder la dernière transition        │
│                                              │
│ city : Sherbrooke  previous_city : Montréal  │
│                                              │
│ Une transition seulement, pas de chaîne.     │
└─────────────────────────────────────────────┘
```

## 5. Dimensions conformées — le secret du drill-across

Une dimension est **conformée** si la même table (ou une vue équivalente)
est utilisée par **plusieurs faits**. Les clés et les attributs sont
identiques.

```text
fact_sales    ──┐
fact_returns  ──┼── dim_customer (conformée)
fact_shipment ──┘
```

Avec des dimensions conformées, on peut **drill-across** : poser une
question qui traverse plusieurs faits sur le **même grain analytique**.

> "Les Gold clients retournent-ils plus que les Silver ?"
> ↑ traverse fact_sales (ventes) ET fact_returns (retours).

## Règles d'or

1. **Un fait par processus business.** Ventes, retours, inventaire,
   budget sont chacun leur propre fait.
2. **Une dimension par entité du monde.** Pas de `dim_misc`, pas de
   `dim_everything`.
3. **Surrogate key partout.** Entier auto-incrémenté, indépendant du
   système source. Permet SCD2 et protège contre les renumérotations.
4. **Un grain explicite** en commentaire en tête de chaque `CREATE TABLE`
   `fact_*`.
5. **Testez le join-star.** Toute requête analytique devrait s'exprimer
   comme *"fact JOIN dim1 JOIN dim2 GROUP BY dim1.attr, dim2.attr"*.
   Si votre requête n'a pas cette forme, revoir votre modèle.

## Les patterns courants

| Pattern | Quand | Fichier |
|---|---|---|
| Dimension depuis raw | S02, le plus commun | `sql/templates/01_dim_from_raw.sql` |
| Fait avec grain | S02 | `sql/templates/02_fact_with_grain.sql` |
| SCD Type 2 | S03, S08 | `sql/templates/03_scd_type2.sql` |
| Pont M:N | S08 | `sql/templates/05_bridge_m2m.sql` |
| Check de validation | toutes | `sql/templates/04_validation_check.sql` |
