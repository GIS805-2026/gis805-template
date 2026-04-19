# Model Card — entrepôt NexaMart

> **Gabarit à remplir en S11** puis maintenu jusqu'à S13.
> Supprimez cette ligne et les blocs `<!-- TODO -->` quand vous publiez.

Une *model card* documente votre entrepôt pour quelqu'un qui arrive dans
l'équipe six mois après vous. Elle doit répondre à : **qu'est-ce que ce
modèle ? pour qui ? dans quelles limites ?** en une page, sans lire le
SQL.

## 1. Identification

- **Nom du modèle :** NexaMart Data Warehouse (GIS805)
- **Propriétaire :** <!-- TODO: votre nom + rôle simulé (ex. Head of Data) -->
- **Dernière mise à jour :** <!-- TODO: AAAA-MM-JJ + séance -->
- **Version :** <!-- TODO: ex. 0.13 (après S11) -->

## 2. Intention

### 2.1 Questions business que ce modèle répond

- <!-- TODO: 3 à 5 questions CEO que votre warehouse peut répondre aujourd'hui. Exemple : "Quel segment de fidélité génère le plus de revenu par région et par trimestre ?" -->

### 2.2 Questions que ce modèle **ne** répond **pas** (encore)

- <!-- TODO: 2 à 3 questions hors scope. Transparence > complétude. -->

## 3. Structure

### 3.1 Tables de faits

| Fact | Grain | Type | Mesures principales | Dimensions reliées |
|---|---|---|---|---|
| `fact_sales` | <!-- TODO --> | transaction | <!-- TODO --> | <!-- TODO --> |
| `fact_returns` | | transaction | | |
| `fact_inventory_snapshot` | | periodic snapshot | | |
| `fact_order_pipeline` | | accumulating | | |
| `fact_promo_exposure` | | factless | | |
<!-- TODO: compléter avec tous vos facts au fil des séances -->

### 3.2 Dimensions

| Dimension | Type SCD | Clés | Notes |
|---|---|---|---|
| `dim_date` | 1 | date_key | membre inconnu `-1` |
| `dim_customer` | 2 | customer_key, customer_id | <!-- TODO: segment historisé ? --> |
| `dim_product` | <!-- TODO --> | product_key, product_id | |
| `dim_store` | | store_key, store_id | hiérarchie province→région→district→store |
| `dim_channel` | | channel_key, channel_id | |
| `dim_campaign` | | campaign_key | utilisé par `fact_promo_exposure` |
| `dim_segment` | | segment_key | accessible via bridge |
| `dim_customer_activity` | 4 (mini-dim) | activity_key | attributs volatiles |

### 3.3 Ponts et cas particuliers

- `bridge_customer_segment` : répartit chaque client entre segments,
  `SUM(weight) = 1.0` par client (voir
  `docs/worked-examples/s08-bridge-returns-walkthrough.md`).
- <!-- TODO: autres cas (hiérarchies, role-playing dates utilisés) -->

## 4. Hypothèses clés et décisions structurantes

<!-- TODO: 3 à 6 décisions qui structurent le modèle. Pointez vers
docs/decision-log.md pour le détail complet de chacune. Exemple :
- Grain de fact_sales : une ligne de commande. Fixé en S02, non révisé.
- dim_customer en SCD Type 2 sur (city, province, loyalty_segment).
  Choix justifié dans decision-log.md#D02.
- Allocation de segment par contribution (vs pondération égale) pour
  bridge_customer_segment. Voir decision-log.md#D08.
-->

## 5. Qualité et fiabilité

### 5.1 Checks actifs

| Check | Ce qu'il protège | Statut |
|---|---|---|
| DUPLICATE_GRAIN | Unicité du grain par fact | PASS / FAIL |
| FK_NOT_NULL | Toute FK résout vers sa dimension | |
| SCD2_NO_OVERLAP | Versions de `dim_customer` non chevauchantes | |
| BRIDGE_WEIGHT_ONE | `SUM(weight) = 1.0` par client | |
| CONFORMANCE_DIMS | `region`, `year_month` identiques entre facts | |

Voir la liste complète dans `validation/checks.sql`. Les résultats
courants sont dans `validation/results/` (non commité).

### 5.2 Limites connues

- <!-- TODO: ce que votre modèle accepte mais qui limite l'interprétation. Ex : dim_customer SCD2 ne couvre pas les corrections administratives (modif SCD1 du nom) — documenté en decision-log.md#D05. -->

## 6. Audience et usages acceptables

### 6.1 Pour qui

- Rapports exécutifs hebdomadaires (board NexaMart).
- Analyses ad-hoc du Head of Data (vous).
- <!-- TODO: autres personas ? -->

### 6.2 Pour quoi, pas

- <!-- TODO: ce qu'il ne faut PAS faire avec ce warehouse. Ex : pas de données personnelles identifiables → pas utilisable pour marketing ciblé nominatif. -->

## 7. Reproductibilité

- **Seed :** déterministe depuis votre username GitHub (voir
  `scripts/datagen/_compute_seed.py`).
- **Pipeline :** `make generate && make load && make check` reconstruit
  tout à partir de zéro en ~90 secondes.
- **Version du code :** le commit courant (`git rev-parse --short HEAD`)
  est l'état canonique.

## 8. Historique

| Date | Version | Changement majeur | Référence |
|---|---|---|---|
| <!-- TODO S01 --> | 0.01 | Setup initial | — |
| <!-- TODO S02 --> | 0.02 | Première étoile (`fact_sales` + 5 dims) | — |
| | | | |
<!-- TODO: étoffer chaque séance où le modèle évolue significativement -->

---

*Cette model card est un livrable vivant. À chaque séance à partir de
S11, demandez-vous : "si je quittais aujourd'hui, cette page suffit-elle
à mon remplaçant ?"*
