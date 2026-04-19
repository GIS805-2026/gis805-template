# S02 — Comment décide-t-on ce qui est fait vs dimension ?

Le saut conceptuel le plus difficile en S02 : *ce chiffre, est-ce un fait
ou une dimension ?* Ce document prend la question CEO de S02 et déroule
la décision, pas-à-pas, en expliquant pourquoi on arrive au schéma qu'on
arrive.

## La question CEO de S02

> **"Quel segment de fidélité génère le plus de revenu par région au cours du dernier trimestre ?"**

Lisez-la deux fois. Tous les mots comptent.

## Étape 1 — Trouver le verbe mesurable

Dans la phrase, cherchez les **mots qui décrivent une quantité** :

| Mot | Quantité ? | Notes |
|---|---|---|
| segment de fidélité | non | attribut textuel (Silver, Gold…) |
| région | non | attribut textuel (Québec, Ontario…) |
| revenu | **oui** | somme de dollars |
| trimestre | non | unité de temps (descripteur) |

*Un seul mot désigne une quantité mesurable : **revenu**.*

**Règle.** Les mots qui désignent une quantité mesurable → **mesures**.
Les mesures vivent dans une **table de faits**. Les autres mots →
**descripteurs** → **dimensions**.

## Étape 2 — Formuler le grain

Le **grain** est la phrase qui décrit ce qu'une ligne de la table de
faits représente. Pour NexaMart, les ventes arrivent sous forme de
commandes, et chaque commande contient plusieurs lignes (un produit, une
quantité, un prix).

> **Grain : une ligne = une ligne de commande** (un produit acheté dans
> une commande donnée, à un prix et une quantité donnés).

Pourquoi pas "une ligne = une commande" ? Parce qu'une commande peut
contenir 3 produits à prix différents. Si on agrège trop tôt, on perd la
capacité de répondre à **"quelle catégorie de produit ?"**.

Pourquoi pas "une ligne = un client" ? Parce qu'un client a plusieurs
commandes sur le trimestre. Agréger au niveau client, c'est refaire
l'ERP — et c'est exactement ce qu'on essaie d'éviter.

**Règle.** Préférez le grain le plus fin pertinent pour les questions
attendues. On peut toujours agréger après ; on ne peut pas désagréger.

## Étape 3 — Lister les descripteurs

La question demande de **filtrer/grouper** par :

- segment de fidélité → attribut du **client** → `dim_customer.loyalty_segment`
- région → attribut du **magasin** → `dim_store.region`
- trimestre → attribut de la **date** → `dim_date.quarter`

Chaque descripteur vit dans **sa propre dimension**. Règle d'or : une
dimension par entité du monde réel. Pas de fourre-tout.

## Étape 4 — Les colonnes de `fact_sales`

Le grain nous donne la liste :

```sql
CREATE TABLE fact_sales (
    -- Clés étrangères vers les dimensions (une par dimension concernée)
    customer_key  INTEGER,   -- qui a acheté
    product_key   INTEGER,   -- quoi
    store_key     INTEGER,   -- où
    channel_key   INTEGER,   -- canal
    order_date    DATE,      -- quand (jointure vers dim_date)

    -- Dimension dégénérée : identifiant commande sans dimension propre
    order_number  VARCHAR,

    -- Mesures additives : on peut les sommer sur n'importe quel axe
    quantity      INTEGER,
    line_total    DECIMAL(10,2)
);
```

## Étape 5 — Ce qui ne va PAS dans `fact_sales`

Trois erreurs communes :

### Erreur 1 — "Je mets le `loyalty_segment` dans `fact_sales` parce que c'est plus rapide"

**Non.** Si Marie change de Silver à Gold, il faudrait mettre à jour
*toutes* ses lignes historiques dans `fact_sales`. Inefficace et
destructeur. Le segment reste dans `dim_customer` (en SCD2 en S03).

### Erreur 2 — "Je dénormalise `region` directement dans `fact_sales`"

**Non.** Si NexaMart renomme "Québec" en "Grand Montréal", il faudrait
mettre à jour chaque ligne de `fact_sales`. La dimension absorbe le
renommage sans toucher au fait.

### Erreur 3 — "Je fais une seule grosse table avec tout"

**Non.** C'est l'anti-patron **one big table**. Rapide à écrire, mais
illisible, impossible à historiser, et redondant (le nom du produit est
répété des milliers de fois).

## Étape 6 — La requête qui répond au CEO

```sql
SELECT
    c.loyalty_segment,
    s.region,
    SUM(f.line_total) AS revenue
FROM fact_sales f
JOIN dim_customer c ON c.customer_key = f.customer_key
JOIN dim_store    s ON s.store_key    = f.store_key
JOIN dim_date     d ON d.date_key     = f.order_date
WHERE d.quarter = 4 AND d.year = 2025
GROUP BY c.loyalty_segment, s.region
ORDER BY revenue DESC
LIMIT 5;
```

Remarquez : trois jointures (le *star join*), un `WHERE` sur un
descripteur de la dimension date, un `GROUP BY` sur deux attributs de
deux dimensions. C'est le pattern canonique.

## Résumé visuel

```text
                     ┌──────────────┐
                     │   dim_date   │
                     └──────┬───────┘
                            │
     ┌──────────────┐       │       ┌──────────────┐
     │ dim_customer │───┐   │   ┌───│  dim_store   │
     └──────────────┘   │   │   │   └──────────────┘
                        ▼   ▼   ▼
                      ┌─────────────┐
                      │ fact_sales  │
                      │   (grain :  │
                      │  une ligne  │
                      │ de commande)│
                      └─────┬───────┘
                            ▲   ▲
     ┌──────────────┐       │   │       ┌──────────────┐
     │ dim_product  │───────┘   └───────│  dim_channel │
     └──────────────┘                    └──────────────┘
```

Cinq dimensions, une table de faits : **c'est une étoile**. Toutes les
requêtes S02 suivent ce pattern.

## À retenir

1. Identifier **la mesure** dans la question du CEO — elle ira dans
   `fact_sales`.
2. Formuler **le grain** en une phrase.
3. Chaque descripteur du grain → sa propre dimension (pas de
   fourre-tout).
4. Les clés substituts (`*_key`) font le pont entre fait et dimensions.
5. Toute question que le CEO peut poser à partir de là est une variation
   de *"SUM(mesure) GROUP BY attribut(s) de dimension WHERE filtres"*.

Le template SQL de référence est `sql/templates/02_fact_with_grain.sql`.
