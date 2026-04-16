# S00 -- Preparation avant la premiere seance

Completez ces etapes **avant** la seance 1. En classe, on passe directement au diagnostic d'affaires -- pas d'installation.

---

## Etape 0 : obtenir votre depot personnel

Avant toute installation, vous devez obtenir votre copie personnelle du projet.

1. **Creez un compte GitHub** (gratuit) si vous n'en avez pas : <https://github.com/signup>
   - Utilisez de preference votre courriel UdeS pour beneficier du GitHub Student Developer Pack (<https://education.github.com/pack>)
2. **Cliquez sur le lien d'assignment** fourni sur Moodle par l'instructeur
   - GitHub Classroom vous demandera de vous connecter si ce n'est pas deja fait
   - Cliquez **Accept this assignment**
   - Attendez quelques secondes -- votre depot prive `GIS805-2026/gis805-2026-<votre_username>` est cree automatiquement
3. **Notez l'URL de votre depot** -- vous en aurez besoin pour cloner (etape 4 ci-dessous)

Choisissez ensuite **Option A** (installation locale) ou **Option B** (Codespaces, zero installation).

---

## Option A : installation locale (recommande)

### 1. Installer les outils

| Outil | Lien | Notes |
|-------|------|-------|
| **VS Code** | <https://code.visualstudio.com/> | Editeur principal du cours |
| **Python 3.10+** | <https://www.python.org/downloads/> | Cochez "Add to PATH" sous Windows |
| **DuckDB CLI** | <https://duckdb.org/docs/installation/> | Telechargez le binaire pour votre OS |
| **Git** | <https://git-scm.com/downloads> | Probablement deja installe sur Mac/Linux |

Extensions VS Code recommandees (installez via le panneau Extensions) :
- **SQLTools** + **SQLTools DuckDB Driver**
- **Mermaid Markdown Syntax Highlighting**
- **GitHub Copilot** (gratuit pour etudiants : <https://education.github.com/pack>)

### 2. Cloner votre depot

```bash
git clone https://github.com/GIS805-2026/gis805-2026-<votre_username>.git
cd gis805-2026-<votre_username>
```

### 3. Installer les dependances Python

```bash
make setup
```

Ou manuellement : `pip install -r requirements.txt`

### 4. Generer vos donnees uniques

Votre token vous sera fourni individuellement par l'instructeur.

```bash
make generate TOKEN=votre_token_ici
```

Ou manuellement : `python src/generate_data.py --token votre_token_ici`

### 5. Charger dans DuckDB

```bash
make load
```

### 6. Verifier que tout fonctionne

```bash
make check
```

Vous devriez voir `PASS` pour toutes les verifications d'existence et d'integrite.

### 7. Explorer rapidement

```bash
make explore
```

Dans le shell DuckDB :
```sql
SELECT COUNT(*) FROM raw_customers;
SELECT COUNT(*) FROM raw_orders;
.tables
.quit
```

Si les deux requetes retournent des nombres > 0, vous etes pret.

---

## Option B : GitHub Codespaces (zero installation)

Si vous ne pouvez pas installer les outils localement :

1. Ouvrez votre depot sur github.com (cree a l'etape 0)
2. Cliquez sur **Code > Codespaces > Create codespace on main**
3. Attendez ~2 minutes -- tout s'installe automatiquement (Python, DuckDB, extensions VS Code)
4. Dans le terminal du Codespace :

```bash
make generate TOKEN=votre_token_ici
make load
make check
```

Le Codespace est un VS Code complet dans le navigateur avec Python, DuckDB et toutes les extensions deja configures.

---

## Checklist de verification

Avant la seance 1, confirmez :

- [ ] Mon depot est clone et accessible
- [ ] `make check` affiche `PASS` pour les verifications de base
- [ ] Je peux ouvrir DuckDB et interroger `raw_customers`
- [ ] J'ai lu le `README.md` du depot

---

## En cas de probleme

- **Python non reconnu sous Windows** : reinstallez en cochant "Add Python to PATH"
- **Permission denied (git clone)** : verifiez que vous avez accepte l'assignment Classroom
- **DuckDB introuvable** : ajoutez le dossier du binaire a votre PATH
- **Tout echoue** : utilisez l'Option B (Codespaces) en attendant

Posez vos questions sur le forum du cours ou en debut de seance 1.
