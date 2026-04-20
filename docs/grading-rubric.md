# Grille d'évaluation — GIS805

Chaque livrable hebdomadaire est noté sur les mêmes cinq dimensions. Seuls
les **poids relatifs** et l'**emphase spécifique à la séance** changent.

## L'échelle

| Score | Niveau | Signification courte |
|---|---|---|
| 4 | Excellent | Le livrable est prêt pour un CEO, aucun correctif nécessaire. |
| 3 | Bien | Répond à la question avec des lacunes mineures, défendables. |
| 2 | Partiel | Répond en partie, une composante manque ou est incorrecte. |
| 1 | Insuffisant | Ne répond pas à la question, ou erreurs structurelles bloquantes. |

## Les cinq dimensions

### 1. `model_quality` — Qualité du modèle (40 % par défaut)

Qualité et exactitude du schéma dimensionnel produit en réponse à la
question CEO.

- **4 — Excellent.** Le schéma répond directement à la question.
  Grain, mesures et dimensions sont explicites et justifiés. Les patterns
  de la séance (SCD, role-playing, bridge, etc.) sont correctement appliqués.
  Aucune erreur structurelle.
- **3 — Bien.** Le schéma répond avec des lacunes mineures. Le grain est
  énoncé. Un choix de pattern est sous-optimal mais défendable avec une
  justification business.
- **2 — Partiel.** Le grain est implicite ou incohérent. Une relation clé
  est absente ou incorrecte. Les requêtes retournent des données mais pas
  la bonne réponse.
- **1 — Insuffisant.** Pas de grain. Erreurs structurelles qui empêchent
  les requêtes. Le modèle ne pourrait pas être mis en production.

### 2. `validation_quality` — Qualité de la validation (25 %)

Qualité des vérifications SQL et de la démonstration que le modèle fonctionne.

- **4.** La requête principale répond à la question CEO avec le bon
  résultat. Les cas limites sont traités (NULLs, inconnus, `SUM(weight)=1`,
  etc.). Les checks sont documentés et reproductibles.
- **3.** La requête retourne la bonne forme. Un cas limite non traité.
- **2.** La requête s'exécute mais retourne des résultats partiels. Aucun
  traitement des NULLs.
- **1.** Aucune requête de validation, ou la requête échoue à l'exécution.

### 3. `executive_justification` — Justification exécutive (20 %)

Qualité du board brief : répond-il à la question CEO en langage décisionnel ?

- **4.** Le brief répond directement à la question avec l'évidence du
  modèle. Formule une décision ou recommandation claire. Langage d'affaires,
  pas technique. 150 à 300 mots.
- **3.** Répond mais reste descriptif. Manque de recommandation explicite.
- **2.** Trop technique (explique le modèle) ou trop vague (pas de chiffres,
  pas de décision). Le CEO ne peut pas agir.
- **1.** Brief absent, hors sujet, ou ne mentionne pas la question CEO.

### 4. `process_trace` — Traçabilité du processus (10 %)

Commits git, usage IA déclaré, décisions documentées.

- **4.** Au moins 3 commits incrémentaux avec messages significatifs.
  Note IA présente et spécifique (outil + usage + validation humaine).
  Decision log mis à jour avec le choix de modélisation de la séance.
- **3.** Commits présents. Note IA mentionne les outils sans détail sur
  la validation.
- **2.** Commit unique avec tous les changements. Note IA générique
  ("j'ai utilisé Copilot").
- **1.** Aucun commit intermédiaire ou note IA absente.

### 5. `reproducibility` — Reproductibilité (5 %)

Un coéquipier peut cloner le dépôt et reproduire le résultat sans
intervention.

- **4.** Clone → DuckDB → `make check` → résultat identique en moins de
  5 minutes. Pas de chemin codé en dur, pas de dépendance cachée.
- **3.** Fonctionne avec un ajustement mineur de chemin documenté dans le
  README.
- **2.** Chemins codés en dur ou dépendances non déclarées.
- **1.** Le dépôt ne s'exécute pas sur un clone propre.

## Poids par séance

Par défaut, les poids ci-dessus s'appliquent à S01–S04, S06–S09, S13.
Certaines séances réaccordent pour refléter leur intention pédagogique :

| Séance | model_quality | validation | executive | process | reproducibility |
|---|---|---|---|---|---|
| S05 (intra 1) | 50 % | 30 % | 15 % | 5 % | — |
| S10 (intra 2) | 50 % | 30 % | 15 % | 5 % | — |
| S11 (documentation) | 20 % | 20 % | 20 % | 30 % | 10 % |
| S12 (board) | 30 % | 15 % | 40 % | 10 % | 5 % |
| S14 (final) | 25 % | 25 % | 30 % | 15 % | 5 % |

## À retenir

Un 4 partout n'existe presque pas en début de trimestre et ce n'est pas
attendu. Viser **3 solide** chaque semaine, puis pousser une dimension
à 4 selon l'emphase de la séance, est la trajectoire réaliste.
