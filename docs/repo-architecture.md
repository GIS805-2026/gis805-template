# Comment ce dépôt est organisé

Aperçu rapide pour étudiants, correcteurs et TAs qui arrivent en cours de
trimestre. Explique ce qui est à vous, ce qui est donné, et ce qui est
généré.

## Les trois zones

### Zone 1 — Ce qui est donné et ne change pas

| Chemin | Rôle |
|---|---|
| `src/run_pipeline.py` | Orchestration : charge les CSVs, exécute vos `.sql`, rapporte. Vous ne modifiez pas ce fichier. |
| `src/run_checks.py` | Exécute `validation/checks.sql` et écrit le résultat dans `validation/results/`. |
| `Makefile` et `run.ps1` | Raccourcis `generate/load/check/clean`. |
| `scripts/datagen/` | Générateurs déterministes des CSVs d'entraînement. Un jeu de données unique par équipe. |
| `validation/checks.sql` | Les vérifications du cours. Partagées avec GitHub Classroom. |
| `.devcontainer/`, `.github/workflows/classroom.yml` | Environnement et autograding. |
| `sql/templates/` | Cinq patterns SQL à copier-coller dans votre travail. |

### Zone 2 — Ce qui est à vous, semaine par semaine

| Chemin | Ce que vous y mettez |
|---|---|
| `sql/dims/` | Une `.sql` par dimension (dim_customer, dim_product, …). |
| `sql/facts/` | Une `.sql` par table de faits (fact_sales, fact_returns, …). |
| `sql/staging/` | Transformations intermédiaires (utile à partir de S06). |
| `sql/checks/` | Vos propres requêtes de travail, celles qui alimentent vos briefs. |
| `sql/views/` | Vues orientées question business (utile à partir de S11). |
| `answers/SNN_executive_brief.md` | Un brief exécutif par séance (sauf examens). |
| `docs/model-card.md` et `docs/decision-log.md` | Documentation S11, puis maintenue jusqu'à S13. |
| `ai-usage.md` | Journal de votre usage de l'IA, mis à jour chaque séance. |

### Zone 3 — Ce qui est généré et jamais commité

| Chemin | Pourquoi pas commité |
|---|---|
| `db/*.duckdb` | Binaire volumineux, reproductible depuis vos SQL. |
| `data/synthetic/` | Régénérable depuis votre team seed. |
| `data/staged/`, `data/exports/` | Intermédiaires. |
| `validation/results/` | Sortie de `make check`, pas un livrable. |
| `__pycache__/`, `.venv/` | Artefacts Python locaux. |

Ces chemins sont déjà dans `.gitignore`. Ne les committez pas.

## Cinq malentendus fréquents

### « Je dois écrire mon propre `run_pipeline.py` »

Non. `src/run_pipeline.py` est l'orchestrateur donné : il charge vos CSVs,
puis exécute **alphabétiquement** vos fichiers dans `sql/staging/`,
`sql/dims/`, `sql/facts/`. Vous écrivez les SQL ; lui les exécute.

### « Le Makefile utilise la commande `duckdb` en ligne de commande »

Non. Le Makefile appelle `python src/run_pipeline.py` et
`python src/run_checks.py`. Seul le **package Python** `duckdb` est requis,
pas de binaire CLI à installer.

### « Le dossier `answers/` contient déjà des briefs exemples »

Non. `answers/` contient uniquement `README.md` qui explique la convention.
Le brief exemple annoté se trouve à `docs/s02-sample-brief.md`.

### « Les PDF dans `docs/lab-guides/` sont dans git donc je peux les éditer »

Ils sont **regénérés automatiquement** par un GitHub Action à chaque mise à
jour du cours. Toute modification locale sera écrasée au prochain push de
l'instructeur.

### « `sql/dims/` et `sql/facts/` sont vides dans le template, c'est un bug »

C'est voulu : le vide est votre livrable. Chaque session, vous ajoutez un
ou plusieurs `.sql` selon le pattern décrit dans le lab guide. Partez de
`sql/templates/` si vous hésitez.

## Cycle de travail hebdomadaire

1. Ouvrir le lab guide PDF de la séance (dans `docs/lab-guides/`).
2. Générer / recharger vos données si vous avez changé de branche.
3. Ajouter vos `.sql` sous `sql/…/`.
4. `make load && make check` jusqu'au vert.
5. Rédiger `answers/SNN_executive_brief.md` en citant vos chiffres.
6. `git commit` avec un message parlant, `git push`.
7. Consulter l'autograding sur GitHub (onglet Actions).

## Où demander de l'aide

- Votre assistant IA — toujours en premier.
- `docs/faq.md` — questions conceptuelles et erreurs fréquentes.
- `docs/verify-before-pushing.md` — checklist avant de pousser.
- Forum du cours — pour les blocages persistants ou les ambiguïtés de
  rubric.
