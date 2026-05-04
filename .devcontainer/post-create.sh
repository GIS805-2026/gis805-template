#!/usr/bin/env bash
set -e

# ── Python dependencies ────────────────────────────────────────────
pip install -q -r requirements.txt

# ── DuckDB CLI (allows `duckdb db/nexamart.duckdb` from terminal) ──
DUCKDB_VER="1.1.3"
if ! command -v duckdb &>/dev/null; then
    echo "Installing DuckDB CLI v${DUCKDB_VER}..."
    curl -fsSL "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VER}/duckdb_cli-linux-amd64.zip" \
        -o /tmp/duckdb_cli.zip
    sudo unzip -oq /tmp/duckdb_cli.zip -d /usr/local/bin
    rm /tmp/duckdb_cli.zip
    echo "DuckDB CLI installed: $(duckdb --version)"
fi
