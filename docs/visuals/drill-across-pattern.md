# Drill-across : combiner deux tables de faits sans mentir

Le drill-across est le **seul** pattern correct pour combiner deux
tables de faits. Ce document le rend visuel en contrastant l'erreur
(JOIN direct) et la solution (agrégation conforme + jointure au grain
commun).

## Le problème en image

### Mauvais — JOIN direct entre deux faits

```text
  fact_sales                    fact_returns
  ┌────────────┐                ┌─────────────┐
  │ Marie S2026│                │ Marie R2026 │
  │  3 lignes  │ ─── JOIN ───>  │  2 lignes   │
  │  100 $ tot │   (direct)     │  40 $ total │
  └────────────┘                └─────────────┘
                    │
                    ▼
              produit cartésien
           ╔═════════════════════╗
           ║   3 x 2 = 6 lignes  ║
           ║   SUM(sales) = 200 $║  ← FAUX (vrai = 100 $)
           ║   SUM(returns)= 120$║  ← FAUX (vrai = 40 $)
           ╚═════════════════════╝
```

Chaque ligne de `fact_sales` apparaît 2 fois, chaque ligne de
`fact_returns` apparaît 3 fois. Les deux `SUM` sont multipliés.

### Bon — drill-across via dimensions conformes

```text
  fact_sales                    fact_returns
  ┌────────────┐                ┌─────────────┐
  │ Marie S2026│                │ Marie R2026 │
  │  3 lignes  │                │  2 lignes   │
  │  100 $ tot │                │  40 $ total │
  └─────┬──────┘                └──────┬──────┘
        │                              │
        │ GROUP BY region, year_month  │ GROUP BY region, year_month
        ▼                              ▼
  ┌──────────────┐              ┌──────────────┐
  │ CTE "ventes" │              │ CTE "retours"│
  │ QC-Est,2026-1│              │ QC-Est,2026-1│
  │   100 $      │              │   40 $       │
  └──────┬───────┘              └──────┬───────┘
         │                             │
         └──────────FULL JOIN──────────┘
                  (region, year_month)
                         │
                         ▼
                 ┌───────────────────┐
                 │ region year_month │
                 │ ventes  retours   │
                 │  100$    40$      │  ← CORRECT
                 │         net=60$   │
                 └───────────────────┘
```

Chaque fait est agrégé **séparément**. La jointure se fait entre
résultats déjà sommés, au grain conforme. Aucune multiplication.

## Le pattern en trois temps

```text
╔════════════════════════════════════════════════════════╗
║                                                        ║
║   1. AGRÉGER chaque fait au grain commun              ║
║      (une CTE par fait)                                ║
║                                                        ║
║   2. FULL JOIN les résultats sur les clés de grain    ║
║      (jamais INNER — vous perdriez les "non matchs")  ║
║                                                        ║
║   3. COALESCE(.., 0) pour les combinaisons absentes   ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

## SQL minimal

```sql
WITH ventes AS (
    SELECT s.region, d.year_month, SUM(f.line_total) AS revenue
    FROM fact_sales f
    JOIN dim_store s ON s.store_key = f.store_key
    JOIN dim_date  d ON d.date_key  = f.order_date
    GROUP BY s.region, d.year_month
),
retours AS (
    SELECT s.region, d.year_month, SUM(r.refund_amount) AS refunds
    FROM fact_returns r
    JOIN dim_store s ON s.store_key = r.store_key
    JOIN dim_date  d ON d.date_key  = r.return_date
    GROUP BY s.region, d.year_month
)
SELECT
    COALESCE(v.region,     r.region)     AS region,
    COALESCE(v.year_month, r.year_month) AS year_month,
    COALESCE(v.revenue, 0) AS ventes,
    COALESCE(r.refunds, 0) AS retours,
    COALESCE(v.revenue, 0) - COALESCE(r.refunds, 0) AS net_revenue
FROM      ventes  v
FULL JOIN retours r
       ON r.region     = v.region
      AND r.year_month = v.year_month
ORDER BY region, year_month;
```

## Ce qui rend le pattern possible

```text
        ┌───────────────┐    ┌───────────────┐
        │  fact_sales   │    │  fact_returns │
        └───┬───────┬───┘    └───┬───────┬───┘
            │       │            │       │
            ▼       ▼            ▼       ▼
       dim_store   dim_date  dim_store  dim_date   ← mêmes tables, mêmes clés
            │       │            │       │
            └───────┴────────────┴───────┘
                 dimensions conformes
                 (region et year_month identiques)
```

Sans dimensions conformes, le grain commun n'existe pas — les deux
`GROUP BY` produiraient des clés différentes et la `FULL JOIN`
échouerait à relier les lignes.

## Check obligatoire avant de publier

```sql
-- Les totaux individuels doivent être préservés
SELECT 'sales total direct'  AS src, SUM(line_total)    FROM fact_sales
UNION ALL
SELECT 'sales total via CTE',       SUM(revenue)        FROM ventes
UNION ALL
SELECT 'returns total direct',      SUM(refund_amount)  FROM fact_returns
UNION ALL
SELECT 'returns total via CTE',     SUM(refunds)        FROM retours;
```

Les deux paires doivent afficher **exactement** le même chiffre. Si
non, votre `GROUP BY` a perdu ou dupliqué des lignes.

## À retenir

```text
  ╭───────────────────────────────────────────────────────╮
  │                                                       │
  │   "Un seul JOIN direct entre deux tables de faits    │
  │    suffit à invalider un tableau de bord entier."    │
  │                                                       │
  │    — règle n°1 de l'entrepôt dimensionnel             │
  │                                                       │
  ╰───────────────────────────────────────────────────────╯
```

1. **Jamais** joindre deux faits directement.
2. Agréger chaque fait séparément au grain commun.
3. Joindre les résultats (`FULL JOIN`) sur les clés de dimension
   conforme.
4. Vérifier les totaux individuels contre leur source avant publication.

Walkthrough complet : `docs/worked-examples/s06-drill-across-walkthrough.md`.
Bus matrix qui liste les dimensions conformes : `docs/visuals/bus-matrix.md`.
