# `sql/checks/` — vérifications personnalisées

Les checks du cours sont dans `validation/checks.sql` (exécutés par
`make check`). Ce dossier-ci est pour **vos propres** vérifications :
questions que vous voulez poser à votre entrepôt pendant que vous travaillez.

## Ce qui va ici

Des fichiers `.sql` que vous lancez manuellement avec l'interface DuckDB
(SQLTools dans VS Code, ou `duckdb db/nexamart.duckdb` en ligne de commande) :

```
sql/checks/
  top_customers_by_region.sql    <-- répond à la question CEO de S02
  scd2_history_check.sql         <-- vérifie que les versions ne se chevauchent pas (S03)
  bridge_weight_sum.sql          <-- somme des poids par client (S08)
```

## Convention de nommage

- Nom descriptif en minuscules + underscores.
- Commentaire d'en-tête : la question business en une phrase.

## Astuce

Chaque brief exécutif dans `answers/` devrait pointer vers un fichier dans
`sql/checks/` qui produit l'évidence chiffrée que vous citez. Le correcteur
peut ainsi rejouer votre preuve.

## Obligation

Aucune. Ce dossier est optionnel mais **fortement recommandé** à partir de S02.
Les étudiants qui y mettent leurs requêtes de travail s'en sortent mieux en
examen parce qu'ils ont une bibliothèque de patterns à réutiliser.
