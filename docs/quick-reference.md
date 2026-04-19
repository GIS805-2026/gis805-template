# GIS805 — Carte de référence (une page, à imprimer)

Tout ce dont vous avez besoin chaque semaine, sans scroller. Imprimez
cette page recto, gardez-la à côté de votre écran.

## Commandes (les 5 qui comptent)

| Mac / Linux / Codespace | Windows PowerShell | Ce que ça fait |
|---|---|---|
| `make generate` | `.\run.ps1 generate` | Génère vos CSVs uniques (team seed = votre username) |
| `make load`     | `.\run.ps1 load`     | Charge CSVs + exécute `sql/staging,dims,facts/*.sql` dans DuckDB |
| `make check`    | `.\run.ps1 check`    | Lance `validation/checks.sql` → rapport PASS / FAIL / SKIP |
| `make clean`    | `.\run.ps1 clean`    | Supprime `db/*.duckdb` et `data/synthetic/` (régénérable) |
| `git status && git push` | idem | Pousse vers `main` → déclenche l'autograding |

**Cycle hebdo :** `generate` → écrire SQL → `load` → `check` jusqu'au vert → écrire brief → `push`.

## Convention de nommage (non négociable)

```text
sql/staging/stg_<nom>.sql           # vues intermédiaires (S06+)
sql/dims/dim_<nom>.sql              # une dimension par fichier
sql/facts/fact_<nom>.sql            # une fact table par fichier
sql/views/v_<question>.sql          # vues orientées question (S11+)
sql/checks/<votre_nom>.sql          # vos requêtes de travail
answers/S01_executive_brief.md      # un brief par séance (sauf S05/S10/S14)
docs/model-card.md                  # à partir de S11
docs/decision-log.md                # à partir de S11
ai-usage.md                         # tenu à jour chaque séance
```

Règles :

- **Une dim / un fact par fichier.** Pas de `dims_combined.sql`.
- **`run_pipeline.py` exécute** dans l'ordre : `staging → dims → facts`,
  alphabétique à l'intérieur. `dim_a` s'exécute avant `dim_z` avant `fact_a`.
- **Jamais** `UPPERCASE.SQL`, `.sql.bak`, espaces dans le nom.

## Kimball en 10 lignes

| Concept | Définition courte |
|---|---|
| **Grain** | Ce qu'une ligne de fact représente. Une phrase. Irréversible. |
| **Dimension** | Descripteur textuel : qui / quoi / où / quand / pourquoi. |
| **Fact table** | Mesures (chiffres) + FK vers dimensions. |
| **Dimension conforme** | Même dim partagée par plusieurs facts → drill-across possible. |
| **Degenerate dim** | Identifiant (`order_number`) sans table dim propre, vit dans le fact. |
| **Surrogate key (`*_key`)** | Entier arbitraire, clé canonique dans l'entrepôt. |
| **Natural key (`*_id`)** | Identifiant venant du système source. |
| **Additive** | `SUM()` sur tous les axes (quantity, line_total). |
| **Semi-additive** | `SUM()` sauf sur le temps (units_on_hand). Utilisez `AVG`. |
| **Non-additive** | Ratio ou pourcentage. Recalculez, ne sommez pas. |

## SCD en 5 lignes

| Type | Quand | Effet |
|---|---|---|
| **Type 1** | Correction, attribut sans valeur historique | UPDATE écrase la ligne |
| **Type 2** | Attribut analytique historisé (segment, ville) | Ferme l'ancienne ligne, ouvre une nouvelle |
| **Type 3** | Dernière transition seulement suffit | Colonne `previous_*` |
| **Type 4** (mini-dim) | Attribut change trop vite | Table séparée avec sa propre clé |
| **Type 6** (hybride) | Besoin de "en ce moment" ET de "à l'époque" | Type 1 + Type 2 combinés |

Défaut raisonnable : **Type 2**.

## Les 4 types de fact tables

```text
Transaction      → événement discret        (fact_sales, fact_returns)
Periodic Snap.   → état à une date fixe     (fact_inventory_snapshot)   semi-additif
Accumul. Snap.   → pipeline qui progresse   (fact_order_pipeline)       UPDATE autorisé
Factless         → présence sans mesure     (fact_promo_exposure)       COUNT / anti-join
```

## Les règles d'or (8 commandements)

1. **Jamais** de `JOIN` direct entre deux fact tables. → drill-across.
2. **Une seule** définition de grain par fact, en **une phrase**.
3. **Surrogate keys** dans les facts, pas de clés naturelles.
4. **Pas de NULL** dans les FK — membre inconnu (`-1`) sinon.
5. **`SUM(weight) = 1.0`** par entité dans tout bridge pondéré.
6. **SCD2 : périodes non chevauchantes**, adjacentes.
7. **Dimensions conformes** = même colonne, même valeurs, partout.
8. **Brief testable "lundi matin"** : cadre comprend en 2 min sans vous.

## Checks de santé avant de pousser

```sql
-- 1. Grain unique
SELECT COUNT(*) - COUNT(DISTINCT <grain_cols>) FROM <fact>;  -- doit être 0

-- 2. Pas de FK NULL
SELECT COUNT(*) FROM <fact> WHERE <fk>_key IS NULL;          -- doit être 0

-- 3. SCD2 non chevauchant
SELECT customer_id, COUNT(*) OVER (PARTITION BY customer_id, effective_from)
FROM dim_customer;                                            -- tout doit être 1

-- 4. Bridge réconcilié
SELECT SUM(f.line_total), SUM(f.line_total * b.weight)
FROM fact_sales f JOIN bridge_customer_segment b ON …;        -- les deux doivent être égaux
```

Lancez aussi `make check` — les checks institutionnels sont dans
`validation/checks.sql`.

## Fichiers à consulter quand vous êtes bloqué

| Symptôme | Ressource |
|---|---|
| Erreur exacte | `docs/TROUBLESHOOTING.md` (par symptôme) |
| "Pourquoi fait-on ça ?" | `docs/faq.md` |
| "Comment structurer mon brief ?" | `docs/s02-sample-brief.md` (exemple annoté) |
| SCD concret | `docs/visuals/scd-type2-before-after.md` |
| Drill-across | `docs/worked-examples/s06-drill-across-walkthrough.md` |
| Bridge M:N | `docs/worked-examples/s08-bridge-returns-walkthrough.md` |
| 4 types de faits | `docs/worked-examples/s09-four-fact-types-walkthrough.md` |
| Sous le capot du pipeline | `src/pipeline_skeleton.py` (version annotée) |
| Patterns SQL prêts à copier | `sql/templates/01–06*.sql` |

## Rythme d'une séance studio

```text
┌──────────────────┬─────────────────────────────────────────────┐
│ 00:00 – 00:20    │ Ouverture : question CEO + hook             │
│ 00:20 – 01:10    │ Sprint SQL : vous modélisez et chargez      │
│ 01:10 – 01:20    │ Pause                                       │
│ 01:20 – 02:10    │ Sprint brief : réponse + preuve + risques   │
│ 02:10 – 02:30    │ Démo / debrief / push                       │
└──────────────────┴─────────────────────────────────────────────┘
```

Arrivez avec `make generate` déjà lancé — gagnez 2 minutes.

---

*Mis à jour chaque fois qu'une nouvelle convention est introduite dans
le cours. Version Markdown canonique : `docs/quick-reference.md`.*
