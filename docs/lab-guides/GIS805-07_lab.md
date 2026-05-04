# GIS805 — Séance 07 / 14 — Dimensions spéciales : dates role-playing, hiérarchies, NULLs et mini-dimensions

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-07_lab.pdf`.

## En bref

- **Date :** 28 mai 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 105 min (~1.8 h)

## Objectif

Résoudre le problème de livraison NexaMart en utilisant des dates role-playing, des hiérarchies géographiques, une politique de membres inconnus, et des mini-dimensions.

## Question du CEO

> « Où se produisent les retards de livraison, par date de commande, date d'expédition, date de livraison et géographie ? »

## Contexte du soir

**NexaMart S07 : Où se produisent les retards de livraison, par date de comma**

Le CEO veut comprendre les délais de livraison NexaMart par plusieurs angles temporels et géographiques. Certains transporteurs sont inconnus, certaines livraisons n'ont pas de date, et la hiérarchie géographique a des trous.

## Résultats d'apprentissage

- Implémenter des dates role-playing (order_date, ship_date, delivery_date).
- Concevoir une hiérarchie géographique correcte (magasin → ville → région → province).
- Définir une politique explicite de NULLs et membres inconnus.
- Évaluer le compromis snowflake vs star pour les hiérarchies profondes.

## Points clés

- Role-playing = une dim_date, plusieurs alias, plusieurs foreign keys.
- NULL policy = un livrable explicite, pas une décision implicite.
- Minimum viable output : analyse de délai correcte + NULL policy documentée.

## Idées reçues à déjouer

  **Réalité :** Chaque rôle de date (commande, expédition, livraison) nécessite un alias distinct pour que les filtres fonctionnent correctement.
  **Réalité :** NULL casse les GROUP BY et les jointures. Un membre inconnu explicite (-1, 'Unknown') est toujours préférable.

## Déroulé

### Partie 1 — Role-playing dates + hierarchy theory  *(20 min)*

Alias de dates, hiérarchies, NULL policy, snowflake trade-offs

### Partie 2 — Sprint 1 : delay analysis  *(45 min)*

Charger fact_shipment, implémenter 3 role-playing dates, analyser délais

### Partie 3 — Sprint 2 : NULL policy + hierarchy + brief  *(40 min)*

Créer membres inconnus, dim_geography hierarchy, mini-dim bands

## Lab

**Objectif du lab :** Analyze delivery delays using role-playing dates and handle NULLs.

**Livrable :** Delay analysis SQL + hierarchy + NULL policy + board brief.

**Fichiers à produire (`repo_artifacts`) :**

- `answers/S07_executive_brief.md`
- `sql/special_dims/s07-delivery-delay.sql`
- `docs/hierarchy-and-null-policy.md`
- `docs/board-briefs/s07-special-dims.md`

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S07_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (40 %) — fact_shipment avec 3 FK distincts vers dim_date (order/ship/delivery). Politique NULLs explicite pour ≥ 1 dimension.
  - **validation_quality** (25 %) — Requête de délai moyen par transporteur isole les inconnus dans une ligne '-1 / Inconnu' distincte.
  - **executive_justification** (20 %) — Brief quantifie les délais par axe temporel requis par le CEO. Transporteurs inconnus nommés explicitement.
  - **process_trace** (10 %) — docs/null-policy.md commité avec enregistrement inconnu par dimension concernée.
  - **reproducibility** (5 %)

## Lectures

- [Kimball Group -- Role-Playing Dimensions](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/role-playing-dimension/) — Utiliser la meme dimension (ex. dim_date) sous plusieurs alias dans une table de faits
- [Kimball Group -- Null Handling in Dimensional Models](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/null-dimension-attribute/) — Politique de gestion des valeurs manquantes avec des enregistrements -1/Inconnu

---

*Généré automatiquement à partir de `content/sessions/GIS805-07.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
