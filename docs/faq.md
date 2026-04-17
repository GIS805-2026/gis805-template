# FAQ — GIS805 NexaMart

## 1. Pourquoi ne pas simplement créer des vues SQL sur le système opérationnel ?

Les vues résolvent le problème de complexité, mais pas celui de performance ni de stabilité.
Une vue sur un ERP en production consomme les mêmes ressources que la requête sous-jacente.
De plus, tout changement de schéma ERP casse la vue.

L'entrepôt **isole** les analyses des systèmes sources : on copie, on transforme, on historise.
Le système opérationnel reste disponible pour les opérations quotidiennes.

## 2. Est-ce que toutes les entreprises ont un entrepôt de données ?

Non. Les PME travaillent souvent directement sur leurs systèmes opérationnels ou utilisent
des outils BI connectés aux bases sources.

Mais dès qu'une organisation a besoin de **croiser des données de plusieurs systèmes** ou de
**conserver l'historique**, un entrepôt devient nécessaire. C'est un signe de maturité analytique.

## 3. Est-ce qu'on travaille en équipe ?

Non. Chaque étudiant est **individuellement** responsable de l'entrepôt complet de NexaMart.
Vous êtes le seul Head of Data — vous construisez les 5 tables de faits, les dimensions,
et la documentation.

Trois **revues par les pairs** (après S04, S09 et S11) permettent d'apprendre des modèles
de vos collègues, mais le travail et l'évaluation sont individuels.

## 4. Pourquoi DuckDB et pas Snowflake ou BigQuery ?

DuckDB est gratuit, embarqué, et ne nécessite aucune infrastructure cloud.
Les concepts qu'on apprend — étoile, grain, SCD, drill-across — s'appliquent
**identiquement** sur n'importe quel moteur.

On élimine la complexité d'infrastructure pour se concentrer sur la **modélisation**.
Votre fichier `db/nexamart.duckdb` est votre entrepôt complet, portable et versionnable.
