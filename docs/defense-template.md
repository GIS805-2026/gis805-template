# Defense au board — guide de preparation (S12)

> **Contexte :** En S12, vous presentez et defendez votre modele dimensionnel
> devant le CEO (votre instructeur) et le board (vos collegues).
> Ce guide vous aide a structurer votre presentation de 7 minutes.

---

## Structure recommandee (7 min)

| Temps     | Section                    | Ce que vous dites                                    |
|-----------|----------------------------|------------------------------------------------------|
| 0:00-1:00 | **Question du CEO**        | Quelle question strategique votre modele resout-il ? |
| 1:00-2:30 | **Le modele**              | Grain, faits, dimensions cles. Montrez le schema.    |
| 2:30-4:00 | **La preuve**              | Requete SQL + resultat qui repond a la question.     |
| 4:00-5:00 | **Les decisions**          | SCD, NULLs, ponts — pourquoi ces choix ?             |
| 5:00-6:00 | **Les limites**            | Ce que votre modele ne couvre pas (encore).           |
| 6:00-7:00 | **La recommandation**      | Quelle decision business le CEO peut prendre ?       |

---

## Checklist avant la presentation

### Contenu
- [ ] Mon grain statement est clair : « une ligne = … »
- [ ] J'ai un schema visuel (Mermaid ou bus matrix) a montrer
- [ ] J'ai une requete SQL qui repond a la question du CEO
- [ ] Les resultats de la requete sont coherents (totaux reconcilies)
- [ ] Mes decisions SCD, NULL, et pont sont justifiees par un besoin business

### Technique
- [ ] `make check` passe sans FAIL
- [ ] Ma base DuckDB est a jour (`make load` recent)
- [ ] Mon depot est commitee et pousse sur GitHub
- [ ] `docs/verify-before-pushing.md` est complete

### Presentation
- [ ] Je peux expliquer chaque ligne de ma requete SQL principale
- [ ] Je connais les limites de mon modele (ce qu'il ne couvre pas)
- [ ] J'ai prepare des reponses aux questions difficiles (voir ci-dessous)

---

## Questions difficiles a anticiper

Le board va poser des questions. Preparez vos reponses :

1. **« Pourquoi ce grain et pas un plus fin/grossier ? »**
   - Nommez une question qui serait impossible avec un grain plus grossier
   - Nommez un cout concret d'un grain plus fin

2. **« Comment savez-vous que vos chiffres sont justes ? »**
   - Montrez votre requete de reconciliation
   - `make check` + verification manuelle sur un sous-ensemble

3. **« Que se passe-t-il quand un client change de region ? »**
   - Expliquez votre politique SCD (Type 1/2/3) et pourquoi
   - Montrez l'impact sur un rapport avant/apres

4. **« Pourquoi certaines dimensions ont des "Inconnu" ? »**
   - Expliquez votre politique NULL et le membre inconnu (key=-1)
   - Montrez que les totaux incluent ces lignes

5. **« Le modele peut-il repondre a une nouvelle question ? »**
   - Ecrivez la requete en direct (ou demandez a votre assistant)
   - Montrez que le schema en etoile rend la nouvelle question simple

6. **« Quel est le plus gros risque de votre modele ? »**
   - Soyez honnete : donnees manquantes, grain trop grossier, SCD pas teste
   - Proposez un plan concret pour le resoudre

---

## Prompts pour votre assistant IA

Utilisez ces prompts pour preparer votre defense :

- « Structure ma presentation de 7 min : question, modele, preuve, decisions, limites, recommandation. »
- « Genere 5 questions difficiles que le CFO pourrait poser sur mon modele. »
- « Simule un contre-interrogatoire sur mes choix de grain et de SCD. »
- « Voici mes resultats SQL. Le total est-il coherent avec [X] ? Explique tout ecart. »

> **Regle d'or :** si votre assistant genere une reponse que vous ne
> comprenez pas, **ne l'utilisez pas**. Le board detectera immediatement
> que ce n'est pas votre raisonnement.

---

## Apres la defense

Documentez les questions recues et vos reponses dans :
- `docs/board-q-and-a-log.md`
- `docs/metric-definitions.md` (si des definitions ont ete clarifiees)

Commitez : `git add -A && git commit -m "S12 board defense" && git push`
