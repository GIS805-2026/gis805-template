# Vos premières requêtes SQL

> **Pas besoin d'être programmeur.**
> SQL est un langage pour poser des questions à une base de données.
> Chaque requête est une *question* écrite dans un format que la machine comprend.
> Ce guide vous montre comment lire et écrire vos premières questions.

---

## Avant de commencer

Vérifiez que vos données sont chargées :

```bash
make generate    # Codespace / Mac / Linux
make load
make check
```

```powershell
.\run.ps1 generate    # Windows PowerShell
.\run.ps1 load
.\run.ps1 check
```

Vous devriez voir `PASS` (ou `SKIP` pour les tables pas encore construites).

> **Astuce :** Dans VS Code, cliquez l'icône **base de données** (SQLTools)
> dans la barre latérale gauche pour explorer vos tables *sans écrire de code*.

---

## Étape 1 — Voir ce qui existe

**Question en français :** « Quelles tables ai-je dans ma base de données ? »

```sql
SHOW TABLES;
```

Vous verrez une liste comme `raw_dim_customer`, `raw_dim_product`, `raw_fact_sales`, etc.
Ce sont vos données brutes — les tables du système opérationnel de NexaMart.

---

## Étape 2 — Regarder quelques lignes

**Question :** « À quoi ressemble une vente ? »

```sql
SELECT *
FROM raw_fact_sales
LIMIT 5;
```

| Mot SQL    | Ce qu'il veut dire                       |
|------------|------------------------------------------|
| `SELECT *` | « Montre-moi toutes les colonnes »       |
| `FROM`     | « …de cette table »                      |
| `LIMIT 5`  | « …mais seulement les 5 premières lignes » |

> **Truc :** `SELECT *` est utile pour explorer. Pour vos livrables, nommez
> toujours les colonnes exactes — c'est plus clair et plus fiable.

---

## Étape 3 — Compter

**Question :** « Combien de clients NexaMart a-t-elle ? »

```sql
SELECT COUNT(*) AS nombre_clients
FROM raw_dim_customer;
```

| Mot SQL      | Ce qu'il veut dire                           |
|--------------|----------------------------------------------|
| `COUNT(*)`   | « Compte le nombre de lignes »               |
| `AS nombre_clients` | « Donne un nom lisible au résultat »  |

**Question :** « Combien de commandes, et pour quel revenu total ? »

```sql
SELECT
    COUNT(*)        AS nombre_lignes,
    SUM(line_total) AS revenu_total
FROM raw_fact_sales;
```

| Mot SQL         | Ce qu'il veut dire                    |
|-----------------|---------------------------------------|
| `SUM(line_total)` | « Additionne toutes les valeurs de cette colonne » |

---

## Étape 4 — Filtrer

**Question :** « Combien de ventes au Québec ? »

```sql
SELECT COUNT(*) AS ventes_quebec
FROM raw_fact_sales
WHERE region = 'Quebec';
```

| Mot SQL  | Ce qu'il veut dire                        |
|----------|-------------------------------------------|
| `WHERE`  | « …seulement les lignes qui respectent cette condition » |

Vous pouvez combiner des conditions :

```sql
SELECT COUNT(*) AS ventes_q4_quebec
FROM raw_fact_sales
WHERE region = 'Quebec'
  AND quarter = 4;
```

---

## Étape 5 — Regrouper (GROUP BY)

**Question :** « Quel est le revenu par catégorie de produit ? »

```sql
SELECT
    category,
    SUM(line_total) AS revenu
FROM raw_fact_sales
GROUP BY category
ORDER BY revenu DESC;
```

| Mot SQL      | Ce qu'il veut dire                                  |
|--------------|-----------------------------------------------------|
| `GROUP BY`   | « Fais un sous-total pour chaque valeur différente » |
| `ORDER BY … DESC` | « Trie du plus grand au plus petit »           |

**Lecture en français :**
« Pour chaque catégorie, calcule la somme du revenu, et classe du plus grand au plus petit. »

---

## Étape 6 — Joindre deux tables (JOIN)

C'est l'étape clé. Dans un entrepôt de données, les **faits** (ventes)
et les **dimensions** (produits, clients, dates) sont dans des tables séparées.
Pour les combiner, on utilise un `JOIN`.

**Question :** « Quel est le revenu par catégorie de produit, en utilisant la table produit ? »

```sql
SELECT
    p.category,
    SUM(f.line_total) AS revenu
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY revenu DESC;
```

| Mot SQL                         | Ce qu'il veut dire                                    |
|---------------------------------|-------------------------------------------------------|
| `fact_sales f`                  | « La table des ventes, que j'appelle `f` pour faire court » |
| `JOIN dim_product p`            | « Ajoute la table des produits, que j'appelle `p` »   |
| `ON f.product_key = p.product_key` | « Relie-les par la clé produit (même valeur = même produit) » |
| `p.category`                    | « La catégorie vient de la table produit »             |
| `f.line_total`                  | « Le montant vient de la table des ventes »            |

**Analogie :** Un `JOIN` est comme un RECHERCHEV dans Excel.
La clé (`product_key`) est la colonne de correspondance.

---

## Étape 7 — Joindre trois tables

**Question du CEO :** « Quel est le revenu par catégorie, par région, par trimestre ? »

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
GROUP BY p.category, s.region, d.quarter
ORDER BY p.category, s.region, d.quarter;
```

**Lecture en français :**
« Pour chaque combinaison catégorie × région × trimestre, calcule le revenu total. »

C'est exactement la question que le CEO pose en S01.
Votre modèle dimensionnel rend cette requête **simple et répétable**.

---

## Résumé — les 7 mots clés

| Mot SQL    | En français                              | Quand l'utiliser                   |
|------------|------------------------------------------|------------------------------------|
| `SELECT`   | « Montre-moi… »                          | Toujours — c'est le début         |
| `FROM`     | « …de cette table »                      | Toujours — après SELECT           |
| `WHERE`    | « …seulement si… »                       | Filtrer des lignes                 |
| `JOIN … ON`| « …en reliant avec cette autre table »   | Combiner faits + dimensions        |
| `GROUP BY` | « …un sous-total par… »                  | Agréger (SUM, COUNT, AVG)          |
| `ORDER BY` | « …trié par… »                           | Classer les résultats              |
| `LIMIT`    | « …les N premiers »                      | Explorer sans tout afficher        |

---

## Comment lire une requête SQL

> **Truc pour débutants :** ne lisez **pas** de haut en bas.
> Lisez dans cet ordre :

1. **FROM** — De quelle(s) table(s) parle-t-on ?
2. **JOIN** — Quelles tables sont reliées ?
3. **WHERE** — Quelles lignes sont gardées ?
4. **GROUP BY** — Quels sous-totaux ?
5. **SELECT** — Quelles colonnes dans le résultat ?
6. **ORDER BY** — Dans quel ordre ?

---

## Et si je suis bloqué ?

1. **Demandez à votre assistant IA** en français :
   - « Explique-moi ce que fait cette requête ligne par ligne. »
   - « Écris une requête pour voir le revenu par région par mois. »
   - « Pourquoi j'ai une erreur "column must appear in GROUP BY" ? »

2. **Consultez :** `docs/TROUBLESHOOTING.md` pour les erreurs fréquentes.

3. **Règle d'or :** si votre assistant génère du SQL que vous ne comprenez pas
   ligne par ligne, **arrêtez**. Demandez :
   « Explique chaque clause comme si j'étais un étudiant en gestion qui n'a jamais vu de SQL. »

---

## Prochaine étape

Retournez à `docs/S00.5-EXPLORE-DATA.md` pour explorer vos données NexaMart
avec les requêtes fournies. Vous avez maintenant le vocabulaire pour comprendre
ce que chaque requête fait.
