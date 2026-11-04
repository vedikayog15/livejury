#!/usr/bin/env bash
# Standalone PostgreSQL verification. Uses only a disposable local cluster.
set -euo pipefail
cd "$(dirname "$0")/.."
task_pgdir=$(mktemp -d "${TMPDIR:-/tmp}/jury-db-check.XXXXXX")
cleanup() {
  pg_ctl -D "$task_pgdir/data" -m immediate stop >/dev/null 2>&1 || true
  rm -rf "$task_pgdir"
}
trap cleanup EXIT
initdb -D "$task_pgdir/data" -A trust --no-locale --encoding=UTF8 >/dev/null
pg_ctl -D "$task_pgdir/data" -l "$task_pgdir/server.log" -o "-F -k $task_pgdir -h ''" -w start >/dev/null
psql -X -h "$task_pgdir" -d postgres -v ON_ERROR_STOP=1 \
  -f supabase/tests/bootstrap_local.sql \
  -f supabase/migrations/202609060001_jury_schema.sql \
  -f supabase/migrations/202609060002_case_library.sql \
  -f supabase/migrations/202609220003_admin.sql \
  -f supabase/migrations/202611040004_account_deletion.sql \
  -f supabase/tests/security_and_flow.sql
