# `sql/staging/` — transformations intermédiaires

Le staging est la zone **entre** les tables `raw_*` (ce qui est chargé depuis
les CSV) et les tables `dim_*` / `fact_*` (ce que vous publiez).

## Ce qui va ici

Des tables ou vues `stg_*` qui nettoient, conforment ou enrichissent les
données brutes avant la modélisation :

```
sql/staging/
  stg_customer_conformed.sql   <-- S06, unifie les IDs clients entre systèmes
  stg_sales_deduplicated.sql   <-- S06, supprime les doublons cross-source
  stg_returns_typed.sql        <-- S06, cast les colonnes en types cohérents
```

## Convention de nommage

- Préfixe `stg_` pour distinguer des raw et des dims/facts.
- Un fichier par table de staging.
- Les tables de staging peuvent être des `VIEW` (plus léger) ou des `TABLE`
  (plus rapide si réutilisées plusieurs fois).

## Règle d'or

Si vous écrivez la même logique de transformation dans deux fichiers `dims/`
ou `facts/` différents, extrayez-la en staging. Le but est d'éviter la
divergence.

## Quand cela devient pertinent

**S06** — en intégrant plusieurs systèmes sources (ventes boutique +
ventes e-commerce + retours), vous aurez besoin de conformer les IDs.
Avant S06, la plupart des étudiants n'ont pas besoin de staging : leurs
`dim_*.sql` peuvent lire directement depuis `raw_*`.
