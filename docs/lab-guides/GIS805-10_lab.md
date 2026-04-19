# GIS805 — Séance 10 / 14 — Examen intra 2 : modélisation avancée multi-star, dimensions et faits

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-10_lab.pdf`.

## En bref

- **Date :** 8 juin 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 155 min (~2.6 h)

## Objectif

Vérifier la maîtrise de la modélisation avancée (S06-S09) dans le contexte NexaMart.

## Déroulé

### Partie 1 — Révision integration night → fact types  *(25 min)*

Rappel multi-star, role-playing, bridges, 4 types de faits

### Partie 2 — Examen individuel  *(120 min)*

Sections : drill-across, role-playing dates, NULL policy, bridges, fact types, réconciliation

### Partie 3 — Post-exam debrief  *(10 min)*

Chaque étudiant identifie un point à améliorer dans son modèle.

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S10_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (50 %) — Réponses correctes sur multi-star, role-playing, bridges et 4 types de faits pour le cas intra.
  - **validation_quality** (30 %) — Les requêtes soumises s'exécutent et retournent des résultats cohérents avec la question intégrée.
  - **executive_justification** (15 %) — La réponse intégrée pose UNE décision qui nécessite les deux tables de faits. Grain clairement énoncé.
  - **process_trace** (5 %) — N/A pour examen. Non évalué.
  - **reproducibility** (0 %)

---

*Généré automatiquement à partir de `content/sessions/GIS805-10.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
