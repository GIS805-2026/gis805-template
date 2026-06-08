# GIS805 — Séance 08 / 12 — Ponts pondérés, SCD avancés et relations many-to-many chez NexaMart

> Guide de studio (version Markdown). PDF équivalent : `docs/lab-guides/GIS805-08_lab.pdf`.

## En bref

- **Date :** 8 juin 2026
- **Horaire :** 19 h 00 – 22 h 00
- **Lieu :** Longueuil
- **Temps estimé :** 105 min (~1.8 h)

## Objectif

Résoudre le problème du double-comptage dans les segments clients NexaMart en utilisant des ponts pondérés, implémenter une logique SCD3/hybride, et vérifier la réconciliation des totaux.

## Question du CEO

> « Comment allouer les coûts et comprendre les segments clients qui se chevauchent sans double-compter ? »

## Contexte du soir

**NexaMart S08 : Comment allouer les coûts et comprendre les segments clients**

Les clients NexaMart appartiennent à plusieurs segments (Platinum, Gold, Silver...). Les campagnes marketing sont allouées à plusieurs segments. Le CEO veut voir revenu et coût par segment, mais sans duplication.

## Résultats d'apprentissage

- Construire un pont pondéré customer↔segment avec poids sommant à 1.0.
- Implémenter un SCD Type 3 (current_segment + previous_segment).
- Vérifier que les totaux pondérés réconcilent avec les totaux réels.
- Modéliser une allocation budgétaire campagne↔segment sans duplication.

## Points clés

- Aucun pont n'est accepté sans preuve que les totaux pondérés = totaux réels.
- SCD3 = simple et lisible pour current vs previous.
- La vérification est un livrable, pas un bonus.

## Idées reçues à déjouer

- **Mythe :** On peut simplement joindre clients aux segments sans pondération
  **Réalité :** Un client dans 3 segments sans pondération triple le revenu dans les rapports. Les poids doivent sommer à 1.0.
- **Mythe :** SCD Type 2 est toujours suffisant pour l'historique
  **Réalité :** Pour certains cas (segment actuel vs précédent), un Type 3 est plus simple et plus lisible que Type 2.

## Déroulé

### Partie 1 — Bridge theory + SCD3 intro  *(20 min)*

Ponts pondérés, M:N, SCD3/hybrid, outrigger mention

### Partie 2 — Sprint 1 : weighted bridge  *(45 min)*

Construire bridge_customer_segment, vérifier sum(weight)=1

### Partie 3 — Sprint 2 : reconciliation + campaign allocation  *(40 min)*

Requête de réconciliation, allocation campagne, board brief

## Lab

**Objectif du lab :** Construire un pont pondere bridge_customer_segment pour eliminer le double-comptage des clients multi-segments. Verifier que les totaux ponderes reconcilent avec les totaux reels. Repondre a la question du CEO avec evidence provenant du pont.


Votre DuckDB (db/nexamart.duckdb) contient deja les tables de faits et dimensions des sessions precedentes. make generate produit 4 fichiers S08 dans data/synthetic/team_XX/s08/ : bridge_customer_segment.csv, bridge_campaign_allocation.csv, customer_scd3_history.csv et dim_segment_outrigger.csv. make load execute sql/bridges/ et cree les tables correspondantes. Attention : le pont contient deja les poids normalises (SUM(weight) = 1.0 par client) mais vous devez le verifier.

**Livrable :** Pont pondere + reconciliation prouvee + board brief.

### Exercice 0 -- Comprendre comment le pont est construit  *(15 min)*

**Objectif :** Comprendre comment bridge_customer_segment est construite par le pipeline, pourquoi chaque jointure existe, et verifier que la contrainte SUM(weight) = 1.0 est respectee. Vous devez pouvoir expliquer chaque ligne du SQL avant d ecrire vos propres requetes.

make generate cree les CSVs S08 dans data/synthetic/ (dont bridge_customer_segment.csv avec les poids). make load execute automatiquement sql/bridges/bridge_customer_segment.sql qui transforme le CSV brut en table propre avec les bonnes cles. Votre travail ce soir n est pas de reecrire ce SQL d infrastructure -- il est deja fait. Votre travail est de COMPRENDRE comment il fonctionne, puis d ecrire vos propres requetes d analyse dessus.

1. make generate && make load
2. SHOW TABLES;
3. -- bridge_customer_segment et dim_segment_outrigger doivent apparaitre.
4. -- Si une table manque : verifiez que sql/bridges/ contient les fichiers SQL.
5. 
6. -- *** ETAPE CLE : LIRE LE SQL DU PONT ***
7. -- Ouvrez sql/bridges/bridge_customer_segment.sql dans votre editeur.
8. -- Lisez chaque ligne et repondez a ces questions :
9. -- Q1 : D ou viennent les donnees brutes ? (quelle table raw_*)
10. -- Q2 : Pourquoi joindre dim_customer ? (pour obtenir customer_key a partir de customer_id)
11. -- Q3 : Pourquoi joindre dim_segment_outrigger ? (pour obtenir segment_key a partir du nom)
12. -- Q4 : Le pont couvre TOUTES les versions SCD2 d un client. Pourquoi ?
13. --       (Parce que fact_sales contient des ventes liees a des customer_key historiques.)
14. -- Q5 : Que fait le check a la fin du fichier ? (verifie SUM(weight) = 1.0 par client)
15. 
16. -- Explorez la table resultante :
17. DESCRIBE bridge_customer_segment;
18. -- Colonnes : bridge_id, customer_key, segment_key, weight, effective_date, is_primary
19. DESCRIBE dim_segment_outrigger;
20. -- Colonnes : segment_key, segment (nom), discount_pct, free_shipping, ...
21. SELECT COUNT(*) FROM bridge_customer_segment;
22. SELECT COUNT(DISTINCT customer_key) FROM bridge_customer_segment;
23. -- Combien de lignes par client en moyenne ?
24. SELECT customer_key, COUNT(*) AS nb_segments, SUM(weight) AS total_weight
25.   FROM bridge_customer_segment GROUP BY customer_key ORDER BY 2 DESC LIMIT 10;
26. -- Q6 : Quel client a le plus de segments ? Combien ?
27. -- Q7 : SUM(weight) est-il bien = 1.0 pour chaque client ?
28. -- Q8 : Combien de clients n ont qu un seul segment (relation 1:1) ?
29. 
30. -- PIEGE INTENTIONNEL -- executez ceci et notez le resultat :
31. SELECT seg.segment, SUM(f.line_total) AS revenue
32.   FROM fact_sales f
33.   JOIN dim_customer c ON c.customer_key = f.customer_key
34.   JOIN bridge_customer_segment b ON b.customer_key = c.customer_key
35.   JOIN dim_segment_outrigger seg ON seg.segment_key = b.segment_key
36.   GROUP BY 1;
37. SELECT SUM(line_total) FROM fact_sales;
38. -- Comparez la somme des segments avec le total reel. Notez le ratio d inflation.
39. -- Q9 : Pourquoi la somme des segments depasse-t-elle le total reel ?
40. -- (Reponse : on a utilise le pont SANS multiplier par weight -- fan-out.)

**Résultat attendu :** Tables S08 presentes dans SHOW TABLES. L etudiant peut expliquer chaque jointure du SQL du pont. Chaque client a entre 1 et 5 segments. SUM(weight) = 1.0 pour tous les clients. Le piege montre que la somme des segments sans ponderation depasse le total reel (ratio d inflation ~1.5x documente).


**Erreurs fréquentes :**
- ⚠️ make load echoue : verifier que sql/bridges/ est un DOSSIER (pas un fichier) contenant bridge_customer_segment.sql
- ⚠️ bridge_customer_segment vide : relancer make generate puis make load
- ⚠️ Ne pas lire le SQL du pont : c est l etape la plus importante de cet exercice
- ⚠️ Piege ignore : ne pas documenter le fan-out = ne pas comprendre le probleme a resoudre
- ⚠️ Confondre segment (VARCHAR) et segment_key (INTEGER) : verifiez les colonnes avec DESCRIBE

### Exercice 1 -- Requete d allocation ponderee + verification  *(35 min)*

**Objectif :** Ecrire votre propre requete de revenue pondere par segment en utilisant la table bridge_customer_segment deja creee par le pipeline. Verifier la contrainte SUM(weight) = 1.0 par client et prouver que le total pondere reconcilie avec le total reel (ecart = 0.00).

Fichier cible : sql/bridges/s08-weighted-allocation.sql. Le pont bridge_customer_segment existe deja -- make load l a cree depuis sql/bridges/bridge_customer_segment.sql (que vous avez lu en Exercice 0). Votre travail ici est d ecrire les requetes d ANALYSE qui utilisent ce pont pour calculer le revenu par segment. Le slide de code est disponible comme reference si vous etes bloque apres avoir essaye seul.

1. -- PARTIE A : requete naive (5 min) -- commencez ici avant tout autre SQL
2. Creez sql/bridges/s08-weighted-allocation.sql
3. -- Copiez la requete naive de l Exercice 0 (SUM sans weight).
4. -- Ajoutez un commentaire : -- INFLATION OBSERVEE : x.xx
5. -- Notez le ratio entre la somme des segments et le total reel.
6. -- PARTIE B : requete correcte (15 min)
7. -- Modifiez la requete : remplacez SUM(f.line_total) par SUM(f.line_total * b.weight)
8. -- SELECT seg.segment, SUM(f.line_total * b.weight) AS revenue_alloue
9. -- FROM fact_sales f
10. --   JOIN dim_customer c ON c.customer_key = f.customer_key
11. --   JOIN bridge_customer_segment b ON b.customer_key = c.customer_key
12. --   JOIN dim_segment_outrigger seg ON seg.segment_key = b.segment_key
13. -- GROUP BY 1 ORDER BY 2 DESC;
14. -- PARTIE C : verification SUM(weight) = 1.0 (5 min)
15. SELECT customer_key, SUM(weight) AS total_weight
16.   FROM bridge_customer_segment GROUP BY customer_key
17.   HAVING ABS(SUM(weight) - 1.0) > 0.01;
18. -- Resultat attendu : 0 lignes. Si des lignes apparaissent : pont casse.
19. -- PARTIE D : reconciliation obligatoire (10 min)
20. Creez sql/checks/s08-weighted-reconciliation.sql :
21. -- SELECT 'total_sans_pont' AS methode, SUM(line_total) AS total FROM fact_sales
22. -- UNION ALL
23. -- SELECT 'total_avec_pont', SUM(f.line_total * b.weight)
24. -- FROM fact_sales f
25. --   JOIN dim_customer c ON c.customer_key = f.customer_key
26. --   JOIN bridge_customer_segment b ON b.customer_key = c.customer_key;
27. -- Les deux lignes doivent afficher le meme chiffre.
28. git add -A && git commit -m 'S08 sprint1 weighted bridge + reconciliation'

**Résultat attendu :** Revenue par segment avec ponderation. SUM(revenue_alloue) = SUM(line_total) prouve en commentaire. Inflation du JOIN direct documentee avec ratio. Check SUM(weight) retourne 0 lignes (tous les clients reconcilent).


**Erreurs fréquentes :**
- ⚠️ Oublier * b.weight dans le SUM : totaux gonfles de 2x ou plus
- ⚠️ INNER JOIN au lieu de LEFT JOIN pour le pont : perd les clients sans segment
- ⚠️ Confondre customer_id et customer_key dans les jointures : utiliser customer_key partout
- ⚠️ Reconciliation non prouvee : les deux totaux doivent etre dans le fichier SQL

### Exercice 2 -- SCD3 + allocation campagne + board brief  *(30 min)*

**Objectif :** Explorer dim_customer_scd3 (concept bonus, deja creee par le pipeline), ecrire l allocation campagne via raw_bridge_campaign_allocation, et rediger le board brief repondant a la question du CEO.

dim_customer_scd3 a deja ete creee par make load (via sql/dims/dim_customer_scd3.sql). Comme pour le pont, commencez par ouvrir ce fichier SQL pour comprendre sa construction. Le SCD3 est optionnel mais valorise dans la note. L allocation campagne utilise les memes principes que le pont client. Le board brief doit montrer la difference entre attribution primaire et attribution ponderee avec un exemple chiffre.

1. -- PARTIE A : SCD Type 3 (10 min -- BONUS)
2. -- Ouvrez sql/dims/dim_customer_scd3.sql dans votre editeur.
3. -- dim_customer_scd3 est DEJA creee par make load. Lisez le SQL :
4. -- Q1 : D ou viennent les donnees ? (raw_customer_scd3_history)
5. -- Q2 : Quelles colonnes distinguent le Type 3 du Type 2 ?
6. --       (current_segment + previous_segment dans la MEME ligne)
7. -- Q3 : Comment sait-on qu un client n a jamais change de segment ?
8. --       (previous_segment IS NULL)
9. 
10. -- Explorez la table :
11. DESCRIBE dim_customer_scd3;
12. SELECT COUNT(*) FROM dim_customer_scd3;
13. SELECT COUNT(*) FROM dim_customer_scd3 WHERE previous_segment IS NOT NULL;
14. -- Combien de clients ont change de segment ?
15. 
16. -- Requete : quelles transitions de segment sont les plus frequentes ?
17. SELECT current_segment, previous_segment, COUNT(*) AS nb
18.   FROM dim_customer_scd3 WHERE previous_segment IS NOT NULL
19.   GROUP BY 1, 2 ORDER BY 3 DESC;
20. 
21. -- PARTIE B : allocation campagne (10 min)
22. DESCRIBE raw_bridge_campaign_allocation;
23. -- Ecrivez la requete de cout alloue par segment :
24. -- SELECT segment, SUM(planned_spend * budget_weight) AS cout_alloue
25. -- FROM raw_bridge_campaign_allocation GROUP BY 1;
26. -- Reconciliation : SUM(cout_alloue) = SUM(planned_spend) originale ?
27. -- Attention : planned_spend est deja pre-multiplie dans les raw -- verifiez avec DESCRIBE.
28. 
29. -- PARTIE C : board brief (10 min)
30. Creez answers/S08_executive_brief.md :
31. -- 1. La question du CEO (une phrase)
32. -- 2. La methode : pont pondere avec SUM(weight) = 1.0
33. -- 3. Les chiffres : revenu par segment (primaire vs pondere)
34. -- 4. L observation : quel segment est surestime/sous-estime sans ponderation ?
35. -- 5. La recommandation au CEO : quelle methode utiliser pour quels rapports ?
36. git add -A && git commit -m 'S08 sprint2 SCD3 + campaign + brief'
37. Consultez docs/verify-before-pushing.md avant de pousser.
38. git push

**Résultat attendu :** dim_customer_scd3 exploree et comprise. Transitions de segment documentees. Allocation campagne par segment avec reconciliation. Board brief avec comparaison primaire vs ponderee et recommandation argumentee.


**Erreurs fréquentes :**
- ⚠️ SCD3 confondu avec SCD2 : SCD3 = colonne previous dans la meme ligne, pas une nouvelle ligne
- ⚠️ Ne pas lire sql/dims/dim_customer_scd3.sql : meme reflexe que pour le pont, lisez le SQL d abord
- ⚠️ Brief sans chiffres : le CEO veut des preuves, pas des opinions
- ⚠️ Brief qui utilise une seule table : la reponse doit comparer primaire vs pondere

Committez incrementalement (>= 3 commits distincts). Documentez chaque interaction IA dans ai-usage.md (outil, prompt utilise, ce que vous avez valide manuellement). Ces deux points valent 15 % de la note (process_trace 10 % + reproducibility 5 %).

**Fichiers à produire (`repo_artifacts`) :**

- `answers/S08_executive_brief.md` — Brief CEO : quelle est la repartition reelle du revenu par segment avec le pont pondere ? (chiffre observe obligatoire, comparaison primaire vs ponderee)
- `sql/bridges/s08-weighted-allocation.sql` — Requete de revenue pondere par segment via bridge_customer_segment avec SUM(line_total * weight)
- `sql/checks/s08-weighted-reconciliation.sql` — Deux checks : SUM(weight) = 1.0 par client + total_sans_pont = total_avec_pont
- `docs/board-briefs/s08-overlap-risk.md` — Vue consolidee pour le board montrant le risque de double-comptage et la solution pont pondere

## Remise

- **Échéance :** Before next session starts
- **Artefacts requis :**
  - `answers/S08_executive_brief.md`
  - `db/nexamart.duckdb`
  - `ai-usage.md`
- **Rubrique de notation :**
  - **model_quality** (40 %) — bridge_customer_segment avec colonne weight. SCD Type 3 implémenté ou documenté comme décision explicite.
  - **validation_quality** (25 %) — SELECT SUM(weight) GROUP BY customer_key retourne 1.00 pour tous les clients. Revenu sans double-comptage.
  - **executive_justification** (20 %) — Brief distingue le revenu par segment loyauté sans double-comptage. Décision SCD3 justifiée business.
  - **process_trace** (10 %) — docs/bridge-policy.md documenté le choix pondération et la règle de réconciliation SCD3.
  - **reproducibility** (5 %)

## Lectures

- [Kimball Group -- Multivalued Dimensions and Bridge Tables](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/multivalued-dimension-bridge-table/) — Le pattern pont pour les relations M:N sans double-comptage
- [Kimball Group -- SCD Type 3](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/type-3/) — Garder current et previous dans la même ligne de dimension

---

*Généré automatiquement à partir de `content/sessions/GIS805-08.yaml`. Pour corriger une coquille, modifiez le YAML source et poussez sur `master` — la CI régénère PDF + Markdown.*
