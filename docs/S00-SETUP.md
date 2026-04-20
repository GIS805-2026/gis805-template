# S00 — Guide de configuration

Ce guide est votre **référence** pour configurer et utiliser votre environnement de travail. En séance 1, l'instructeur vous guidera à travers les étapes 1 à 6 en classe. Vous pouvez revenir à ce document à tout moment pendant le trimestre.

Dans ce cours, vous travaillez en **langage naturel d'abord**. Un assistant IA est votre coéquipier : posez-lui des questions, demandez-lui d'expliquer le code, laissez-le vous guider. L'objectif n'est pas de mémoriser des commandes, mais de développer votre jugement sur les réponses.

---

## Étape 1 : créer votre compte GitHub

1. Allez sur <https://github.com/signup> et créez un compte gratuit
   - Utilisez de préférence votre courriel UdeS
2. **Demandez le GitHub Student Developer Pack** : <https://education.github.com/pack>
   - Cela vous donne accès gratuit à GitHub Copilot et aux Codespaces
   - La vérification peut prendre quelques heures à quelques jours — faites-le **dès maintenant**

---

## Étape 2 : accepter l'assignment

1. Cliquez sur le **lien d'assignment** fourni sur Moodle
2. Connectez-vous à GitHub si nécessaire
3. Cliquez **Accept this assignment** — votre dépôt privé est créé en quelques secondes

Vous avez maintenant un dépôt à votre nom : `GIS805-2026/gis805-2026-<votre_username>`.

---

## Étape 3 : choisir votre environnement

Trois chemins possibles. **Choisissez celui qui fonctionne pour vous** — le résultat est le même.

### Chemin A : Codespace (recommandé, zéro installation)

Le plus simple. Tout se passe dans votre navigateur.

1. Sur la page de votre dépôt, cliquez **Code > Codespaces > Create codespace on main**
2. Attendez ~2 minutes — VS Code s'ouvre dans le navigateur avec Python, DuckDB et Copilot déjà configurés
3. Passez à l'**Étape 4**

> **Limite** : le Student Developer Pack offre 60 heures/mois de Codespace. Pensez à arrêter votre Codespace quand vous ne travaillez pas (dans le menu `...` en haut à gauche > **Stop Codespace**). Si vous manquez d'heures, passez au chemin B.

### Chemin B : VS Code local + GitHub Copilot

Le chemin long-terme le plus confortable. Recommandé après les premières semaines.

1. Installez les outils :

| Outil | Lien | Notes |
| ----- | ---- | ----- |
| **VS Code** | <https://code.visualstudio.com/> | Éditeur principal du cours |
| **Python 3.10+** | <https://www.python.org/downloads/> | Cochez "Add to PATH" sous Windows |
| **Git** | <https://git-scm.com/downloads> | Probablement déjà installé sur Mac/Linux |

2. Installez les extensions VS Code :
   - **GitHub Copilot** + **GitHub Copilot Chat** (gratuit via Student Developer Pack)
   - **SQLTools** + **SQLTools DuckDB Driver**
   - **Mermaid Markdown Syntax Highlighting**

3. Clonez votre dépôt. Dans VS Code, ouvrez la palette de commandes (`Ctrl+Shift+P` / `Cmd+Shift+P`), tapez **Git: Clone**, collez l'URL de votre dépôt et choisissez un dossier local.

4. Ouvrez un terminal dans VS Code et lancez :

```bash
# Mac / Linux
make generate

# Windows PowerShell
.\run.ps1 generate
```

5. Passez à l'**Étape 4**

### Chemin C : VS Code local + assistant IA alternatif

Si votre Student Developer Pack n'est pas encore actif, vous pouvez quand même commencer.

1. Suivez les mêmes étapes d'installation que le **Chemin B**, mais sans l'extension Copilot
2. Utilisez un assistant IA en parallèle pour les mêmes interactions :
   - **ChatGPT** : <https://chat.openai.com>
   - **Claude** : <https://claude.ai>
   - **Extensions VS Code alternatives** : Cody (<https://sourcegraph.com/cody>) ou Continue (<https://continue.dev/>), toutes deux gratuites

> Les prompts suggérés dans ce guide fonctionnent avec n'importe quel assistant. Copiez-collez vos questions et le contexte pertinent (noms de fichiers, messages d'erreur) dans l'outil de votre choix.

3. Passez à l'**Étape 4**

---

## Étape 4 : rencontrer votre assistant

C'est le moment le plus important. Ouvrez votre assistant IA et posez votre première question :

> **Qu'est-ce qui se trouve dans mon dépôt ? Explique-moi la structure du projet.**

Si vous êtes dans un Codespace ou VS Code avec Copilot, ouvrez le panneau **Copilot Chat** (icône de bulle dans la barre latérale). Si vous utilisez un autre outil, copiez la liste des fichiers et posez la question.

Prenez le temps de lire la réponse. Essayez ensuite :

> **À quoi sert le fichier Makefile ?**
>
> **Qu'est-ce que DuckDB et pourquoi on l'utilise dans ce cours ?**

Vous venez de faire votre première interaction de travail assistée par IA. C'est exactement comme ça qu'on travaille dans ce cours : vous posez des questions en français, l'assistant répond, et vous exercez votre jugement sur la réponse.

---

## Étape 5 : générer vos données uniques

Chaque étudiant obtient un jeu de données unique, dérivé automatiquement de votre nom d'utilisateur GitHub. Aucun token à copier-coller — votre seed est calculé à partir de votre username git.

Demandez à votre assistant :

> **Comment je génère mon jeu de données ?**

Il vous guidera vers la commande. Vous pouvez aussi la taper directement dans le terminal :

```bash
# Mac / Linux
make generate

# Windows PowerShell
.\run.ps1 generate
```

Vous devriez voir apparaître des fichiers CSV dans `data/synthetic/` avec vos données uniques.

---

## Étape 6 : charger et vérifier

Demandez à votre assistant :

> **Comment je charge mes données dans la base de données ?**

Ou directement dans le terminal :

```bash
# Mac / Linux
make load
make check

# Windows PowerShell
.\run.ps1 load
.\run.ps1 check
```

Vous devriez voir `PASS` pour toutes les vérifications. Si quelque chose affiche `FAIL`, demandez à votre assistant :

> **J'ai un FAIL sur [nom du check]. Qu'est-ce que ça veut dire et comment je corrige ?**

---

## Étape 7 : explorer vos données

Demandez à votre assistant :

> **Liste toutes les tables de ma base DuckDB et donne-moi le nombre de lignes de chacune.**

Puis dans un notebook ou le CLI DuckDB, explorez par vous-même :

```sql
SHOW TABLES;
SELECT COUNT(*) FROM raw_dim_customer;
SELECT COUNT(*) FROM raw_fact_sales;
```

Si les requêtes retournent des nombres > 0, vous êtes prêt pour la séance 1.

---

## Astuce : explorer vos tables avec SQLTools (sans écrire de code)

SQLTools est déjà installé dans votre Codespace (ou dans VS Code local si vous avez suivi le Chemin B).

1. Dans la barre latérale gauche de VS Code, cliquez l'icône en forme de **base de données** (cylindre).
2. Si aucune connexion n'est listée, cliquez **Add New Connection** :
   - **Driver** : DuckDB
   - **Database File** : `db/nexamart.duckdb` (chemin relatif depuis la racine du dépôt)
3. Une fois connecté, vous verrez la liste de toutes vos tables dans le panneau latéral.
4. Cliquez sur une table pour voir ses colonnes, types, et un aperçu des données.
5. Vous pouvez aussi exécuter des requêtes SQL directement depuis SQLTools (clic droit > New SQL File).

**Pourquoi c'est utile :** vous pouvez explorer la structure de vos tables (colonnes, types) sans écrire de `SELECT *`. C'est plus rapide que le terminal pour vérifier que vos dimensions et faits sont bien chargés.

---

## Checklist de fin de séance 1

- [ ] J'ai un environnement fonctionnel (Codespace ou VS Code local)
- [ ] J'ai un assistant IA fonctionnel (Copilot, ChatGPT, Claude, ou autre)
- [ ] J'ai parlé avec mon assistant et il m'a expliqué mon dépôt
- [ ] `make check` (ou `.\run.ps1 check`) se termine sans FAIL (les SKIP sont normaux en S01)
- [ ] `SHOW TABLES` liste au moins `raw_dim_customer`, `raw_dim_product`, `raw_fact_sales`
- [ ] J'ai commité mon premier executive brief dans `answers/S01_executive_brief.md`

---

## En cas de problème

Demandez d'abord à votre assistant IA — décrivez votre problème en français, il peut souvent vous débloquer.

Si votre assistant ne suffit pas :

- **Student Developer Pack en attente** : utilisez le Chemin C en attendant — vous migrerez vers Copilot quand il sera actif
- **Codespace ne démarre pas** : rafraîchissez la page, ou supprimez le Codespace et recréez-en un
- **Heures de Codespace épuisées** : passez au Chemin B (installation locale)
- **Python non reconnu (local)** : réinstallez en cochant "Add Python to PATH"
- **Permission denied (git clone)** : vérifiez que vous avez accepté l'assignment Classroom
- **Tout échoue** : passez au Codespace, ça fonctionne presque toujours

Posez vos questions sur le forum du cours ou en début de séance 1.
