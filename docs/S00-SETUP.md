# S00 -- Preparation avant la premiere seance

Completez ces etapes **avant** la seance 1. En classe, on passe directement au diagnostic d'affaires -- pas d'installation.

Dans ce cours, vous travaillez en **langage naturel d'abord**. Votre assistant IA (GitHub Copilot) est votre co-equipier : posez-lui des questions, demandez-lui d'expliquer le code, laissez-le vous guider. L'objectif n'est pas de memoriser des commandes, mais de developper votre jugement sur les reponses.

---

## Etape 1 : creer votre compte GitHub

1. Allez sur <https://github.com/signup> et creez un compte gratuit
   - Utilisez de preference votre courriel UdeS
2. Activez le **GitHub Student Developer Pack** : <https://education.github.com/pack>
   - Cela vous donne acces gratuit a **GitHub Copilot** (votre assistant IA pour le cours)

---

## Etape 2 : accepter l'assignment et ouvrir votre environnement

1. Cliquez sur le **lien d'assignment** fourni sur Moodle
2. Connectez-vous a GitHub si necessaire
3. Cliquez **Accept this assignment** -- votre depot prive est cree en quelques secondes
4. Sur la page de votre depot, cliquez **Code > Codespaces > Create codespace on main**
5. Attendez ~2 minutes -- VS Code s'ouvre dans votre navigateur avec tout deja installe

Rien a installer sur votre ordinateur. Tout fonctionne dans le navigateur.

---

## Etape 3 : rencontrer votre assistant

C'est le moment le plus important. Ouvrez le panneau **Copilot Chat** (icone de bulle dans la barre laterale gauche) et posez votre premiere question :

> **Qu'est-ce qui se trouve dans mon depot? Explique-moi la structure du projet.**

Copilot va lire votre depot et vous expliquer chaque dossier et fichier. Prenez le temps de lire sa reponse.

Essayez ensuite :

> **A quoi sert le fichier Makefile?**
>
> **Qu'est-ce que DuckDB et pourquoi on l'utilise dans ce cours?**

Vous venez de faire votre premiere interaction de travail avec un assistant IA. C'est exactement comme ca qu'on travaille dans ce cours : vous posez des questions en francais, l'assistant repond, et vous exercez votre jugement sur la reponse.

---

## Etape 4 : generer vos donnees uniques

Votre token personnel vous sera fourni par l'instructeur (sur Moodle ou en personne).

Demandez a Copilot :

> **Comment je genere mon jeu de donnees unique avec mon token?**

Il vous guidera vers la commande. Vous pouvez aussi la taper directement dans le terminal :

```bash
make generate TOKEN=votre_token_ici
```

Vous devriez voir apparaitre des fichiers CSV dans `data/raw/` avec vos donnees uniques.

---

## Etape 5 : charger et verifier

Demandez a Copilot :

> **Comment je charge mes donnees dans la base de donnees?**

Ou directement dans le terminal :

```bash
make load
make check
```

Vous devriez voir `PASS` pour toutes les verifications. Si quelque chose affiche `FAIL`, demandez a Copilot :

> **J'ai un FAIL sur [nom du check]. Qu'est-ce que ca veut dire et comment je corrige?**

---

## Etape 6 : explorer vos donnees

Demandez a Copilot :

> **Montre-moi une requete SQL pour voir combien j'ai de clients et de commandes.**

Ou dans le terminal :

```bash
make explore
```

Puis tapez :

```sql
SELECT COUNT(*) FROM raw_customers;
SELECT COUNT(*) FROM raw_orders;
```

Si les deux requetes retournent des nombres > 0, vous etes pret pour la seance 1.

---

## Checklist avant la seance 1

- [ ] Mon Codespace s'ouvre et fonctionne
- [ ] J'ai parle avec Copilot et il m'a explique mon depot
- [ ] `make check` affiche `PASS` pour les verifications de base
- [ ] Je vois des donnees dans `raw_customers` et `raw_orders`
- [ ] J'ai lu le `README.md` du depot

---

## Option avancee : installation locale

Si vous preferez travailler sur votre machine plutot que dans un Codespace :

### Outils a installer

| Outil | Lien | Notes |
| ----- | ---- | ----- |
| **VS Code** | <https://code.visualstudio.com/> | Editeur principal du cours |
| **Python 3.10+** | <https://www.python.org/downloads/> | Cochez "Add to PATH" sous Windows |
| **Git** | <https://git-scm.com/downloads> | Probablement deja installe sur Mac/Linux |

### Extensions VS Code

- **GitHub Copilot** (gratuit via Student Developer Pack)
- **SQLTools** + **SQLTools DuckDB Driver**
- **Mermaid Markdown Syntax Highlighting**

### Cloner et configurer

```bash
git clone https://github.com/GIS805-2026/gis805-2026-<votre_username>.git
cd gis805-2026-<votre_username>
make setup
make generate TOKEN=votre_token_ici
make load
make check
```

---

## En cas de probleme

Demandez d'abord a Copilot -- decrivez votre probleme en francais, il peut souvent vous debloquer.

Si Copilot ne suffit pas :

- **Codespace ne demarre pas** : rafraichissez la page, ou supprimez le Codespace et recreez-en un
- **Python non reconnu (local)** : reinstallez en cochant "Add Python to PATH"
- **Permission denied (git clone)** : verifiez que vous avez accepte l'assignment Classroom
- **Tout echoue en local** : passez au Codespace, ca fonctionne toujours

Posez vos questions sur le forum du cours ou en debut de seance 1.
