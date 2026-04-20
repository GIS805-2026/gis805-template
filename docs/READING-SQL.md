# Lire du SQL comme du français

> **Ce guide vous apprend à LIRE du SQL**, pas à l'écrire.
> Si vous comprenez ce que fait une requête, vous pouvez la modifier.
> Si vous ne comprenez pas — arrêtez et demandez à votre assistant IA.

---

## Règle #1 : ne lisez pas de haut en bas

SQL s'exécute dans un ordre différent de celui dans lequel il est écrit.
Voici l'ordre de **lecture** (pas d'écriture) :

| Ordre de lecture | Clause      | Question en français                 |
|:----------------:|-------------|--------------------------------------|
| 1                | `FROM`      | De quelle(s) table(s) parle-t-on ?  |
| 2                | `JOIN`      | Quelles tables sont reliées ?        |
| 3                | `WHERE`     | Quelles lignes sont gardées ?        |
| 4                | `GROUP BY`  | Quels sous-totaux ?                  |
| 5                | `HAVING`    | Quels groupes sont gardés ?          |
| 6                | `SELECT`    | Quelles colonnes dans le résultat ?  |
| 7                | `ORDER BY`  | Dans quel ordre ?                    |
| 8                | `LIMIT`     | Combien de lignes maximum ?          |

---

## Exemple pas à pas

Voici une requête typique du cours :

```sql
SELECT
    p.category,
    s.region,
    d.quarter,
    SUM(f.line_total) AS revenu
FROM fact_sales f
JOIN dim_product  p ON f.product_key = p.product_key
JOIN dim_store    s ON f.store_key   = s.store_key
JOIN dim_date     d ON f.date_key    = d.date_key
WHERE d.year = 2024
GROUP BY p.category, s.region, d.quarter
ORDER BY revenu DESC;
```

### Lecture dans l'ordre correct :

**1. FROM** → `fact_sales f`
> « On part de la table des ventes, qu'on appelle `f` pour faire court. »

**2. JOIN** → trois tables de dimensions
> « On relie les ventes aux produits (`p`), aux magasins (`s`), et aux dates (`d`),
>   en utilisant les clés étrangères comme correspondance. »

**3. WHERE** → `d.year = 2024`
> « On ne garde que les ventes de 2024. »

**4. GROUP BY** → `p.category, s.region, d.quarter`
> « On fait un sous-total pour chaque combinaison catégorie × région × trimestre. »

**5. SELECT** → les colonnes + `SUM(f.line_total)`
> « Pour chaque groupe, montre la catégorie, la région, le trimestre, et le total. »

**6. ORDER BY** → `revenu DESC`
> « Trie du plus grand revenu au plus petit. »

### Traduction finale en une phrase :

> « Pour l'année 2024, quel est le revenu total par catégorie de produit,
>   par région de magasin, par trimestre, trié du plus grand au plus petit ? »

---

## Les alias : pourquoi `f.`, `p.`, `s.`, `d.` ?

Quand on joint plusieurs tables, il faut préciser de quelle table vient
chaque colonne. Les **alias** sont des raccourcis :

| Alias | Table          | Pourquoi cette lettre        |
|-------|----------------|------------------------------|
| `f`   | `fact_sales`   | **f**act                     |
| `p`   | `dim_product`  | **p**roduct                  |
| `s`   | `dim_store`    | **s**tore                    |
| `d`   | `dim_date`     | **d**ate                     |
| `c`   | `dim_customer` | **c**ustomer                 |

**Règle :** dès qu'il y a un `JOIN`, préfixez *toutes* les colonnes.
Sinon, DuckDB vous dira `ambiguous reference`.

---

## Patron : traduire du français en SQL

| Phrase en français                          | SQL correspondant                     |
|---------------------------------------------|---------------------------------------|
| « Combien de… »                             | `SELECT COUNT(*)`                     |
| « Le total de… »                            | `SELECT SUM(colonne)`                 |
| « La moyenne de… »                          | `SELECT AVG(colonne)`                 |
| « …par catégorie »                          | `GROUP BY category`                   |
| « …par région par mois »                    | `GROUP BY region, month`              |
| « …seulement au Québec »                    | `WHERE region = 'Quebec'`             |
| « …les 10 premiers »                        | `ORDER BY … DESC LIMIT 10`           |
| « …en combinant les ventes et les produits »| `JOIN dim_product ON …`               |

### Recette en 3 étapes :

1. **Écrivez** la question en français.
2. **Soulignez** les mots clés (combien, total, par, seulement, les N premiers).
3. **Remplacez** chaque mot par sa clause SQL.

---

## Exercice : lisez ces requêtes

### Requête A
```sql
SELECT COUNT(*) AS nombre_clients
FROM dim_customer
WHERE segment = 'Premium';
```
> **Traduction :** « Combien de clients sont dans le segment Premium ? »

### Requête B
```sql
SELECT
    d.month,
    SUM(f.line_total) AS revenu_mensuel
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.month
ORDER BY d.month;
```
> **Traduction :** « Quel est le revenu total par mois, trié par mois ? »

### Requête C
```sql
SELECT
    p.category,
    COUNT(DISTINCT f.order_number) AS paniers
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category
HAVING COUNT(DISTINCT f.order_number) > 100
ORDER BY paniers DESC;
```
> **Traduction :** « Quelles catégories de produits apparaissent dans plus de 100
> paniers différents ? Triées de la plus fréquente à la moins fréquente. »

---

## Quand vous êtes bloqué

Copiez la requête et demandez à votre assistant :

> « Explique-moi cette requête SQL **clause par clause**, en commençant
>   par le FROM. Traduis chaque clause en une phrase en français. »

**Règle d'or du cours :** si vous ne pouvez pas expliquer chaque ligne
d'une requête à un collègue non-technique, vous ne la comprenez pas
encore assez pour la soumettre.

---

## Voir aussi

- `docs/YOUR-FIRST-QUERY.md` — écrire vos premières requêtes
- `docs/glossary.md` — tous les termes du cours
- `docs/TROUBLESHOOTING.md` — erreurs SQL fréquentes
