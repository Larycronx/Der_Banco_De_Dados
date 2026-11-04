#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MYSQL_BIN="${MYSQL_BIN:-mysql}"

if [[ -z "${MYSQL_DATABASE:-}" ]]; then
  echo "Defina MYSQL_DATABASE para um banco MySQL de teste vazio." >&2
  echo "Exemplo: MYSQL_DATABASE=erp_teste ./sql/tests/run_tests.sh" >&2
  exit 2
fi

MYSQL_ARGS=(--default-character-set=utf8mb4 --database="$MYSQL_DATABASE")
[[ -n "${MYSQL_HOST:-}" ]] && MYSQL_ARGS+=(--host="$MYSQL_HOST")
[[ -n "${MYSQL_PORT:-}" ]] && MYSQL_ARGS+=(--port="$MYSQL_PORT")
[[ -n "${MYSQL_USER:-}" ]] && MYSQL_ARGS+=(--user="$MYSQL_USER")
[[ -n "${MYSQL_SOCKET:-}" ]] && MYSQL_ARGS+=(--socket="$MYSQL_SOCKET")

{
  # STRICT_ALL_TABLES evita que valor inválido em ENUM vire a string vazia do MySQL.
  printf "%s\n" "SET SESSION sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'STRICT_ALL_TABLES', 'NO_ENGINE_SUBSTITUTION');"
  cat \
    "$ROOT/sql/schema/der.sql" \
    "$ROOT/sql/examples/dados_exemplo_erp.sql" \
    "$ROOT/sql/tests/test_integridade.sql"
} | "$MYSQL_BIN" "${MYSQL_ARGS[@]}"
