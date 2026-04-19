# Decision Log — entrepôt NexaMart

> **Gabarit à remplir en S11**, puis maintenu jusqu'à S13.
> Supprimez cette ligne et les blocs `<!-- TODO -->` quand vous publiez.

Une décision non documentée est une décision perdue. Quand votre
successeur (ou votre vous-même dans trois mois) regarde votre modèle,
il doit comprendre **pourquoi** — pas seulement **quoi**. Ce journal
capture les choix structurants, l'alternative écartée, et le raisonnement.

## Comment l'utiliser

- Une décision = un bloc avec un **ID stable** (ex. `D02`, `D08`).
- Référencez-le depuis `docs/model-card.md`, les briefs, les commits.
- **Ne réécrivez pas** une décision passée : ajoutez-en une nouvelle qui
  la supersede, et pointez vers elle (`D14 supersede D02`).
- Notez les décisions **avant** de coder quand c'est possible — ce sont
  celles qui tiennent le mieux.

## Format d'une entrée

```markdown
### Dxx — <titre court impératif>

- **Date / séance :** AAAA-MM-JJ (SNN)
- **Contexte :** le problème concret, en 2 phrases
- **Décision :** ce que vous avez choisi, en 1 phrase
- **Alternatives écartées :** 1 à 3 options, avec la raison du rejet
- **Conséquences :** ce que cette décision impose en aval
- **Révisable si :** condition qui déclencherait une nouvelle décision
- **Références :** lien vers SQL, brief, visual, ou decision antérieure
```

---

## Décisions

<!-- TODO: remplacez les exemples ci-dessous par VOS décisions réelles. -->

### D01 — Grain de `fact_sales` = une ligne de commande

- **Date / séance :** <!-- TODO (S02) -->
- **Contexte :** La question CEO du S02 demande des ventes par
  catégorie et région. Granularité de commande (en-tête) masque la
  catégorie ; granularité d'événement de paiement éclate inutilement.
- **Décision :** Une ligne de `fact_sales` = `(order_number, sale_line_id)`.
- **Alternatives écartées :**
  - Grain en-tête de commande : perdrait la catégorie produit.
  - Grain événement paiement : sur-fragmenté pour nos questions.
- **Conséquences :** `sale_line_id` est degenerate dim dans `fact_sales`.
  Toute question "par commande" agrège, pas l'inverse.
- **Révisable si :** Apparition de questions sur paiement multiple
  (split payment) qui exigeraient le grain événement.
- **Références :** `sql/facts/fact_sales.sql`, `docs/worked-examples/s02-star-schema-walkthrough.md`.

### D02 — `dim_customer` en SCD Type 2

- **Date / séance :** <!-- TODO (S03) -->
- **Contexte :** <!-- TODO: Marie Tremblay change de segment → rapports historiques mentent si SCD1. -->
- **Décision :** SCD Type 2 sur `(city, province, loyalty_segment)`.
  Autres colonnes restent en Type 1.
- **Alternatives écartées :**
  - Type 1 partout : ré-attribue les ventes de mars au segment actuel.
  - Type 3 : ne garde qu'une transition, perd l'historique multi-changements.
- **Conséquences :** Les joints de fact vers dim passent par
  `BETWEEN effective_from AND effective_to`, pas par `customer_id`.
- **Révisable si :** <!-- TODO -->
- **Références :** `sql/dims/dim_customer.sql`, `docs/visuals/scd-type2-before-after.md`.

### D03 — <!-- TODO: votre première décision réelle -->

<!-- Copier le format ci-dessus -->

---

## Décisions en attente

<!-- TODO: choses que vous savez devoir décider bientôt, mais pas encore. Utile pour votre futur vous ET pour les peer reviews. -->

- <!-- TODO: ex. "Décider en S08 la stratégie d'allocation des poids du bridge : contribution vs définie métier." -->

## Décisions revisitées

<!-- TODO: quand une Dxx est superseded, notez ici le renvoi. -->

- <!-- TODO: ex. "D05 supersede D02 : bascule de loyalty_segment SCD2 → SCD6 hybride après retour du board." -->

---

*Un bon decision log n'a pas besoin de dates parfaites : il a besoin de
décisions **nommées**, **justifiées**, et **retrouvables**. Commencez
modestement, complétez au fur et à mesure.*
