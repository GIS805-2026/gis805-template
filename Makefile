# GIS805 — NexaMart Makefile
# Usage: make <target> [TOKEN=your_token]

PYTHON   ?= python
DB       ?= db/nexamart.duckdb
DATA_DIR ?= data/raw
TOKEN    ?=

.PHONY: setup generate load check explore clean submit help

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## Install Python dependencies
	$(PYTHON) -m pip install -r requirements.txt

generate: ## Generate your unique dataset (requires TOKEN=...)
	@if [ -z "$(TOKEN)" ]; then echo "Error: TOKEN is required. Usage: make generate TOKEN=your_token"; exit 1; fi
	$(PYTHON) src/generate_data.py --token $(TOKEN)

load: ## Load CSV data into DuckDB
	$(PYTHON) src/run_pipeline.py --db $(DB) --data $(DATA_DIR)

check: ## Run validation checks against your DuckDB
	duckdb $(DB) < validation/checks.sql

explore: ## Open DuckDB interactive shell
	duckdb $(DB)

clean: ## Remove generated data and database (keeps source files)
	rm -f $(DB)
	rm -f $(DATA_DIR)/*.csv
	rm -f data/metadata/dataset_identity.json

submit: ## Pre-submission checklist
	@echo "=== Pre-submission checklist ==="
	@echo ""
	@test -f $(DB) && echo "[OK] Database exists: $(DB)" || echo "[!!] Missing database: $(DB)"
	@test -f ai-usage.md && echo "[OK] AI usage trace exists" || echo "[!!] Missing ai-usage.md"
	@test -f data/metadata/dataset_identity.json && echo "[OK] Dataset identity exists" || echo "[!!] Missing dataset identity"
	@echo ""
	@echo "Run 'make check' to validate your data before pushing."
	@echo "Run 'git add -A && git commit -m \"S0X submission\" && git push' to submit."

quickstart: setup generate load check ## Full setup in one command (requires TOKEN=...)
