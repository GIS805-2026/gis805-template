# `sql/facts/` — tables de faits

Les faits stockent **ce qu'on mesure** : revenus, quantités, délais, marges.
Chaque ligne représente un événement au grain déclaré (une ligne de commande,
un jour de stock par magasin, une exposition promo).

## Ce qui va ici

Vos fichiers `.sql` qui créent les tables `fact_*` à partir des tables raw
+ dimensions chargées. Un fichier par table de faits :

```
sql/facts/
  fact_sales.sql              <-- S02, grain = ligne de commande
  fact_returns.sql            <-- S06, grain = ligne de retour
  fact_budget.sql             <-- S06, grain = mois x région x catégorie
  fact_daily_inventory.sql    <-- S09, snapshot périodique
  fact_order_pipeline.sql     <-- S09, accumulating snapshot
  fact_promo_exposure.sql     <-- S09, factless
```

## Convention de nommage

- Fichier : `fact_<processus>.sql`.
- Table produite : même nom que le fichier sans l'extension.
- Colonnes FK : même nom que la clé substitut de la dimension référencée
  (`customer_key`, `product_key`, etc.).
- Mesures additives : `quantity`, `line_total`, `margin_amount`.
- Mesures semi-additives : `stock_on_hand` (additive sur produit, pas sur
  date — la moyenne du stock a du sens, la somme n'en a pas).

## Règle du grain

Avant d'écrire le `CREATE TABLE`, écrivez en commentaire la phrase du grain :

```sql
-- GRAIN : une ligne = une ligne de commande (order_number + line_id)
```

Si vous ne pouvez pas formuler cette phrase en une ligne, votre fait n'est pas
prêt. Revenez à votre brief exécutif.

## Par où commencer

Copiez `../templates/02_fact_with_grain.sql`. Il inclut la déclaration du
grain, les jointures vers les dimensions, et les vérifications de cardinalité.

## Quand cela devient obligatoire

**S02** — `fact_sales` est le livrable principal de la session.
