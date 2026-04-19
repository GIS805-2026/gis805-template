# `sql/views/` — vues analytiques

Les vues donnent aux consommateurs (CEO, directeurs, analystes) une
**interface simple** sur votre étoile. Elles cachent la complexité des
jointures et exposent les concepts business.

## Ce qui va ici

Des fichiers `.sql` qui créent des `VIEW` par-dessus vos dims et facts :

```
sql/views/
  v_sales_by_region_month.sql      <-- fact_sales x dim_store x dim_date
  v_top_customers_loyalty.sql      <-- fact_sales x dim_customer
  v_stock_coverage_days.sql        <-- fact_daily_inventory, semi-additive
```

## Convention de nommage

- Préfixe `v_` pour distinguer des tables.
- Nom orienté question business, pas orienté table (`v_sales_by_region_month`,
  pas `v_fact_sales_joined`).

## Règle d'or

Une vue devrait **répondre à une question**, pas **exposer un schéma**. Si
votre vue a 20 colonnes parce que vous voulez "tout exposer au cas où", vous
avez créé un problème, pas une solution. Faites-en plusieurs, chacune avec
un angle.

## Quand cela devient pertinent

**S11** — la session de documentation formalise les vues comme contrat avec
les consommateurs. Avant S11, vous pouvez créer des vues pour votre propre
confort, mais ce n'est pas un livrable explicite.
