# S00 -- Guide de configuration

Ce guide est votre **reference** pour configurer et utiliser votre environnement de travail. En seance 1, l'instructeur vous guidera a travers les etapes 1 a 6 en classe. Vous pouvez revenir a ce document a tout moment pendant le trimestre.

Dans ce cours, vous travaillez en **langage naturel d'abord**. Un assistant IA est votre co-equipier : posez-lui des questions, demandez-lui d'expliquer le code, laissez-le vous guider. L'objectif n'est pas de memoriser des commandes, mais de developper votre jugement sur les reponses.

---

## Etape 1 : creer votre compte GitHub

1. Allez sur <https://github.com/signup> et creez un compte gratuit
   - Utilisez de preference votre courriel UdeS
2. **Demandez le GitHub Student Developer Pack** : <https://education.github.com/pack>
   - Cela vous donne acces gratuit a GitHub Copilot et aux Codespaces
   - La verification peut prendre quelques heures a quelques jours -- faites-le **des maintenant**

---

## Etape 2 : accepter l'assignment

1. Cliquez sur le **lien d'assignment** fourni sur Moodle
2. Connectez-vous a GitHub si necessaire
3. Cliquez **Accept this assignment** -- votre depot prive est cree en quelques secondes

Vous avez maintenant un depot a votre nom : `GIS805-2026/gis805-2026-<votre_username>`.

---

## Etape 3 : choisir votre environnement

Trois chemins possibles. **Choisissez celui qui fonctionne pour vous** -- le resultat est le meme.

### Chemin A : Codespace (recommande, zero installation)

Le plus simple. Tout se passe dans votre navigateur.

1. Sur la page de votre depot, cliquez **Code > Codespaces > Create codespace on main**
2. Attendez ~2 minutes -- VS Code s'ouvre dans le navigateur avec Python, DuckDB et Copilot deja configures
3. Passez a l'**Etape 4**

> **Limite** : le Student Developer Pack offre 60 heures/mois de Codespace. Pensez a arreter votre Codespace quand vous ne travaillez pas (dans le menu `...` en haut a gauche > **Stop Codespace**). Si vous manquez d'heures, passez au chemin B.

### Chemin B : VS Code local + GitHub Copilot

Le chemin long-terme le plus confortable. Recommande apres les premieres semaines.

1. Installez les outils :

| Outil | Lien | Notes |
| ----- | ---- | ----- |
| **VS Code** | <https://code.visualstudio.com/> | Editeur principal du cours |
| **Python 3.10+** | <https://www.python.org/downloads/> | Cochez "Add to PATH" sous Windows |
| **Git** | <https://git-scm.com/downloads> | Probablement deja installe sur Mac/Linux |

2. Installez les extensions VS Code :
   - **GitHub Copilot** + **GitHub Copilot Chat** (gratuit via Student Developer Pack)
   - **SQLTools** + **SQLTools DuckDB Driver**
   - **Mermaid Markdown Syntax Highlighting**

3. Clonez votre depot. Dans VS Code, ouvrez la palette de commandes (`Ctrl+Shift+P` / `Cmd+Shift+P`), tapez **Git: Clone**, collez l'URL de votre depot et choisissez un dossier local.

4. Ouvrez un terminal dans VS Code et lancez :

```bash
# Mac / Linux
make generate

# Windows PowerShell
.\run.ps1 generate
```

5. Passez a l'**Etape 4**

### Chemin C : VS Code local + assistant IA alternatif

Si votre Student Developer Pack n'est pas encore actif, vous pouvez quand meme commencer.

1. Suivez les memes etapes d'installation que le **Chemin B**, mais sans l'extension Copilot
2. Utilisez un assistant IA en parallele pour les memes interactions :
   - **ChatGPT** : <https://chat.openai.com>
   - **Claude** : <https://claude.ai>
   - **Extensions VS Code alternatives** : Cody (<https://sourcegraph.com/cody>) ou Continue (<https://continue.dev/>), toutes deux gratuites

> Les prompts suggeres dans ce guide fonctionnent avec n'importe quel assistant. Copiez-collez vos questions et le contexte pertinent (noms de fichiers, messages d'erreur) dans l'outil de votre choix.

3. Passez a l'**Etape 4**

---

## Etape 4 : rencontrer votre assistant

C'est le moment le plus important. Ouvrez votre assistant IA et posez votre premiere question :

> **Qu'est-ce qui se trouve dans mon depot? Explique-moi la structure du projet.**

Si vous etes dans un Codespace ou VS Code avec Copilot, ouvrez le panneau **Copilot Chat** (icone de bulle dans la barre laterale). Si vous utilisez un autre outil, copiez la liste des fichiers et posez la question.

Prenez le temps de lire la reponse. Essayez ensuite :

> **A quoi sert le fichier Makefile?**
>
> **Qu'est-ce que DuckDB et pourquoi on l'utilise dans ce cours?**

Vous venez de faire votre premiere interaction de travail assistee par IA. C'est exactement comme ca qu'on travaille dans ce cours : vous posez des questions en francais, l'assistant repond, et vous exercez votre jugement sur la reponse.

---

## Etape 5 : generer vos donnees uniques

Chaque etudiant obtient un jeu de donnees unique, derive automatiquement de votre nom d'utilisateur GitHub. Aucun token a copier-coller -- votre seed est calcule a partir de votre username git.

Demandez a votre assistant :

> **Comment je genere mon jeu de donnees?**

Il vous guidera vers la commande. Vous pouvez aussi la taper directement dans le terminal :

```bash
# Mac / Linux
make generate

# Windows PowerShell
.\run.ps1 generate
```

Vous devriez voir apparaitre des fichiers CSV dans `data/synthetic/` avec vos donnees uniques.

---

## Etape 6 : charger et verifier

Demandez a votre assistant :

> **Comment je charge mes donnees dans la base de donnees?**

Ou directement dans le terminal :

```bash
# Mac / Linux
make load
make check

# Windows PowerShell
.\run.ps1 load
.\run.ps1 check
```

Vous devriez voir `PASS` pour toutes les verifications. Si quelque chose affiche `FAIL`, demandez a votre assistant :

> **J'ai un FAIL sur [nom du check]. Qu'est-ce que ca veut dire et comment je corrige?**

---

## Etape 7 : explorer vos donnees

Demandez a votre assistant :

> **Montre-moi une requete SQL pour voir combien j'ai de clients et de commandes.**

Puis dans le terminal DuckDB :

```sql
SELECT COUNT(*) FROM raw_customers;
SELECT COUNT(*) FROM raw_orders;
```

Si les deux requetes retournent des nombres > 0, vous etes pret pour la seance 1.

---

## Checklist de fin de seance 1

- [ ] J'ai un environnement fonctionnel (Codespace ou VS Code local)
- [ ] J'ai un assistant IA fonctionnel (Copilot, ChatGPT, Claude, ou autre)
- [ ] J'ai parle avec mon assistant et il m'a explique mon depot
- [ ] `make check` (ou `.\run.ps1 check`) affiche `PASS` pour les verifications de base
- [ ] Je vois des donnees dans `raw_customers` et `raw_orders`
- [ ] J'ai commite mon premier executive brief

---

## En cas de probleme

Demandez d'abord a votre assistant IA -- decrivez votre probleme en francais, il peut souvent vous debloquer.

Si votre assistant ne suffit pas :

- **Student Developer Pack en attente** : utilisez le Chemin C en attendant -- vous migrerez vers Copilot quand il sera actif
- **Codespace ne demarre pas** : rafraichissez la page, ou supprimez le Codespace et recreez-en un
- **Heures de Codespace epuisees** : passez au Chemin B (installation locale)
- **Python non reconnu (local)** : reinstallez en cochant "Add Python to PATH"
- **Permission denied (git clone)** : verifiez que vous avez accepte l'assignment Classroom
- **Tout echoue** : passez au Codespace, ca fonctionne presque toujours

Posez vos questions sur le forum du cours ou en debut de seance 1.
