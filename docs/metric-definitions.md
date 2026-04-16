# Définitions des Métriques

Ce document définit clairement chaque métrique utilisée dans le modèle NexaMart.

## Pourquoi c'est important

Des définitions claires évitent :
- Les malentendus entre analystes
- Les calculs incohérents
- Les décisions basées sur des données mal comprises

## Format de définition

Pour chaque métrique :
- **Nom** : Nom technique et nom d'affaires
- **Définition** : Description précise en langage naturel
- **Formule** : Calcul exact
- **Unité** : $, %, quantité, etc.
- **Granularité** : À quel niveau cette métrique a-t-elle du sens?
- **Agrégation** : Comment combiner les valeurs (SUM, AVG, etc.)
- **Filtres standards** : Exclusions habituelles

---

## Métriques de revenus

### Revenu brut (Gross Revenue)

**Définition** : Total des ventes avant toute déduction

**Formule** : `SUM(quantity * unit_price)`

**Unité** : CAD $

**Granularité** : Ligne de commande et au-dessus

**Agrégation** : SUM

**Filtres standards** : Aucun

---

### Revenu net (Net Revenue)

**Définition** : Revenus après retours et rabais

**Formule** : `gross_revenue - returns - discounts`

**Unité** : CAD $

**Granularité** : Transaction et au-dessus

**Agrégation** : SUM

**Filtres standards** : Exclure les transactions annulées

---

## Métriques de volume

### Nombre de transactions

**Définition** : Compte distinct des transactions complétées

**Formule** : `COUNT(DISTINCT order_id)`

**Unité** : Nombre

**Granularité** : Jour/magasin/client et au-dessus

**Agrégation** : SUM du count

**Filtres standards** : Exclure les commandes annulées

---

## Métriques de performance

### Panier moyen (Average Basket)

**Définition** : Revenu moyen par transaction

**Formule** : `net_revenue / transaction_count`

**Unité** : CAD $

**Granularité** : Jour/magasin et au-dessus seulement

**Agrégation** : Recalculer à chaque niveau (pas de SUM)

**Filtres standards** : Transactions > 0$

---

<!-- Ajoutez vos métriques selon le même format -->
