# GIS805 — NexaMart Makefile
# Usage: make <target>
# Works on Linux, macOS, Windows (Git Bash / Codespace terminal)

PYTHON   ?= python
DB       ?= db/nexamart.duckdb
DATA_DIR ?= data/raw

.PHONY: setup generate load check explore clean submit help quickstart

help: ## Show available targets
	@echo "  setup        Install Python dependencies"
	@echo "  generate     Generate your unique dataset (auto from GitHub username)"
	@echo "  load         Load CSV data into DuckDB"
	@echo "  check        Run validation checks"
	@echo "  explore      Open DuckDB interactive shell"
	@echo "  clean        Remove generated data and database"
	@echo "  submit       Pre-submission checklist"
	@echo "  quickstart   Full setup in one command"

setup: ## Install Python dependencies
	$(PYTHON) -m pip install -r requirements.txt

generate: ## Generate your unique dataset (auto from GitHub username)
	$(PYTHON) src/generate_data.py

load: ## Load CSV data into DuckDB
	$(PYTHON) src/run_pipeline.py --db $(DB) --data $(DATA_DIR)

check: ## Run validation checks against your DuckDB
	$(PYTHON) -c "import duckdb; con = duckdb.connect('$(DB)', read_only=True); sql = open('validation/checks.sql').read(); stmts = [s.strip() for s in sql.split(';') if s.strip() and not s.strip().startswith('--')]; [print(con.execute(s).fetchall()) for s in stmts]"

explore: ## Open DuckDB interactive shell
	$(PYTHON) -c "import duckdb; con = duckdb.connect('$(DB)'); print('Connected to $(DB). Type SQL or Ctrl+C to exit.'); import code; code.interact(local={'con': con, 'sql': lambda q: print(con.execute(q).fetchdf())})"

clean: ## Remove generated data and database (keeps source files)
	$(PYTHON) -c "import pathlib; [f.unlink() for f in [pathlib.Path('$(DB)'), pathlib.Path('data/metadata/dataset_identity.json')] if f.exists()]; [f.unlink() for f in pathlib.Path('$(DATA_DIR)').glob('*.csv')]"

submit: ## Pre-submission checklist
	$(PYTHON) -c "\
import pathlib, sys;\
print('=== Pre-submission checklist ===');\
checks = [\
  ('$(DB)', 'Database'),\
  ('ai-usage.md', 'AI usage trace'),\
  ('data/metadata/dataset_identity.json', 'Dataset identity'),\
];\
ok = True;\
[print(f'  [OK] {label}') if pathlib.Path(p).exists() else (print(f'  [!!] {label} -- MISSING'), setattr(sys, '_fail', True)) for p, label in checks];\
print();\
print(\"Run 'make check' to validate your data before pushing.\");\
print(\"Run 'git add -A && git commit -m \\\"S0X submission\\\" && git push' to submit.\")"

quickstart: setup generate load check ## Full setup in one command
