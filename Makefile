.PHONY: generate load check clean

TEAM_SEED ?= $(shell git config user.name | md5sum | cut -c1-8 | xargs printf "%d\n" 0x 2>/dev/null || echo 1)

# ──────────────────────────────────────────────
# generate : Produire toutes les données NexaMart
#            (dimensions + 5 faits + ponts + factless)
#            Déterministe : même seed → même données.
# ──────────────────────────────────────────────
generate:
	python scripts/datagen/gen_all.py --team-seed $(TEAM_SEED)

# ──────────────────────────────────────────────
# load : Exécuter le pipeline SQL (staging → dims → facts)
#        Produit db/nexamart.duckdb
# ──────────────────────────────────────────────
load:
	python src/run_pipeline.py

# ──────────────────────────────────────────────
# check : Valider l'intégrité du modèle
#         Clés uniques, NULLs, réconciliation, identité
# ──────────────────────────────────────────────
check:
	python src/run_checks.py

# ──────────────────────────────────────────────
# clean : Réinitialiser (supprime DB + données)
# ──────────────────────────────────────────────
clean:
	rm -f db/nexamart.duckdb
	rm -rf data/synthetic/ data/raw/*.csv data/staged/* data/exports/*
	rm -rf validation/results/*
