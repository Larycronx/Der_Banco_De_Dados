#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "Defina DATABASE_URL para um banco PostgreSQL de teste vazio." >&2
  echo "Exemplo: DATABASE_URL=postgresql://postgres:senha@localhost:5432/erp_teste ./tests/run_tests.sh" >&2
  exit 2
fi

PSQL_BIN="${PSQL_BIN:-psql}"
"$PSQL_BIN" "$DATABASE_URL" -v ON_ERROR_STOP=1 -P pager=off \
  -f "$ROOT/DER/der.sql" \
  -f "$ROOT/exemplo/dados_exemplo_erp.sql" \
  -f "$ROOT/tests/test_integridade.sql"
