# S08 — Ponts pondérés : allouer sans double-compter

En S08, chaque client NexaMart appartient à **plusieurs** segments
simultanément : par valeur (Gold/Silver/Bronze), par comportement
d'achat (Fidèle, Opportuniste, Nouveau), et par canal préféré (Web,
App, Magasin). Le board veut répartir les 10 M$ de revenu entre ces
segments — **sans compter trois fois** le même client.

La réponse est une **table de pont pondérée** (weighted bridge).

## La question CEO de S08

> **« Comment allouer les coûts et comprendre les segments clients qui se chevauchent sans double-compter ? »**

Le mot clé : *sans double-compter*. Si la somme des trois segments
dépasse 100 % du revenu total, quelque chose ment.

## Étape 1 — Le problème du M:N naïf

Sans pont, on est tenté de :

```sql
-- NE PAS FAIRE
SELECT seg.segment_name, SUM(f.line_total) AS revenue
FROM fact_sales f
JOIN dim_customer c        ON c.customer_key = f.customer_key
JOIN customer_segments cs  ON cs.customer_id = c.customer_id
JOIN dim_segment seg       ON seg.segment_id = cs.segment_id
GROUP BY seg.segment_name;
```

Si Marie est à la fois Gold, Fidèle et Web, le `JOIN` produit **trois**
lignes pour chaque vente de Marie. `SUM(line_total)` = `3 × vrai total`.
Les trois segments comptent la même vente. La somme dépasse 100 %.

## Étape 2 — La table de pont pondérée

On introduit un pont `bridge_customer_segment` qui répartit chaque
client entre ses segments avec un **poids** qui somme à 1.0 :

| customer_id | segment_id  | weight |
|---|---|---|
| CUS-00042 | Gold     | 0.50 |
| CUS-00042 | Fidèle   | 0.30 |
| CUS-00042 | Web      | 0.20 |
| CUS-00043 | Silver   | 1.00 |
| CUS-00044 | Bronze   | 0.60 |
| CUS-00044 | Magasin  | 0.40 |

**Contrainte fondamentale** : `SUM(weight)` par `customer_id` = 1.0.
C'est le check qu'on enforce via `validation/checks.sql`
(`test_bridge_weights_sum_to_one`).

## Étape 3 — La requête correcte

```sql
SELECT seg.segment_name,
       SUM(f.line_total * b.weight) AS revenue_alloue
FROM fact_sales f
JOIN dim_customer c          ON c.customer_key = f.customer_key
JOIN bridge_customer_segment b ON b.customer_id = c.customer_id
JOIN dim_segment seg         ON seg.segment_id = b.segment_id
GROUP BY seg.segment_name;
```

Une vente de 100 $ de Marie contribue pour :

- **50 $** au segment Gold
- **30 $** au segment Fidèle
- **20 $** au segment Web

Somme : **100 $**. Exactement la vraie valeur. Aucun double-comptage.

## Étape 4 — Vérification : le total doit réconcilier

**Check obligatoire** avant de présenter au board :

```sql
SELECT
    'total_without_bridge' AS method,
    SUM(f.line_total)      AS total
FROM fact_sales f
UNION ALL
SELECT
    'total_with_bridge',
    SUM(f.line_total * b.weight)
FROM fact_sales f
JOIN dim_customer c          ON c.customer_key = f.customer_key
JOIN bridge_customer_segment b ON b.customer_id = c.customer_id;
```

Les deux lignes **doivent** afficher le même chiffre, au centime près.
Si elles divergent, soit un client n'a pas de ligne dans le pont (son
revenu est perdu), soit un client a `SUM(weight) ≠ 1` (son revenu est
dédoublé ou tronqué).

## Étape 5 — Comment attribuer les poids ?

Trois stratégies acceptables :

1. **Égale.** `1 / n` où `n` est le nombre de segments. Simple, sans
   biais, mais ignore l'intensité d'appartenance.
2. **Par contribution.** Pour chaque segment, poids = part du revenu
   historique attribuable à ce segment. Capture l'intensité réelle.
3. **Définie par métier.** Le board fixe les poids explicitement
   (ex. Gold = 0.5, Fidèle = 0.3, Canal = 0.2). Parfait si la politique
   d'attribution existe déjà.

Documentez **laquelle** vous avez choisie dans le brief. Le choix n'est
jamais "neutre" — il répond à une question de gouvernance.

## Étape 6 — Bridge ≠ SCD2

Les deux concepts se ressemblent (plusieurs lignes par entité) mais
résolvent des problèmes différents :

| | SCD Type 2 | Bridge |
|---|---|---|
| Problème | Un attribut change **dans le temps** | Un attribut a plusieurs valeurs **en parallèle** |
| Lignes par entité | Une par période | Une par valeur simultanée |
| Somme des poids | N/A (les périodes ne se chevauchent pas) | 1.0 par entité, à chaque instant |
| Exemple NexaMart | Marie a été Silver puis Gold | Marie est Gold ET Fidèle ET Web |

Vous pouvez utiliser **les deux** ensemble : un pont peut historiser ses
poids (`effective_from`, `effective_to`). C'est avancé — pas requis en
S08.

## Diagramme synthétique

```mermaid
flowchart LR
  C[dim_customer] -->|1| B[bridge_customer_segment<br/>customer_id + segment_id + weight]
  B -->|M| S[dim_segment]
  B -. SUM weight = 1.0 .-> CHK[check<br/>validation/checks.sql]
  F[fact_sales] -->|customer_key| C
  F -.line_total x weight.-> B
```

Un client, plusieurs segments, un total qui réconcilie.

## Erreurs fréquentes à déjouer

### « J'ai oublié de multiplier par `b.weight` »

Votre rapport affiche 3 × le vrai revenu. Le check de réconciliation
l'attrape immédiatement.

### « Un nouveau client n'a pas encore de pont »

Son revenu sort du total. Deux choix défendables :

- Insérer une ligne par défaut `(customer_id, 'Unknown', 1.0)` dans le
  pont — son revenu va dans un segment "Unknown".
- Rejeter les clients sans pont dans les rapports segmentés — et
  l'afficher explicitement au board ("12 clients non segmentés, 4 % du
  revenu").

Choisir explicitement. Ne pas laisser `NULL`.

## Votre livrable S08

`answers/S08_executive_brief.md` doit :

1. Le SQL qui calcule `revenue_alloue` par segment avec le pont.
2. Le SQL de **réconciliation** montrant que
   `total_without_bridge == total_with_bridge`.
3. La méthode d'attribution des poids (égale / contribution /
   définie) avec la raison.
4. Un cas concret où le pont change la conclusion : sans pont,
   le segment X semble responsable de 42 % du revenu ; avec pont, il
   n'en représente que 18 %. Nommez-le.

Template SQL : `sql/templates/05_bridge_m2m.sql`. Visuel :
`docs/visuals/bridge-m2n.md`.
