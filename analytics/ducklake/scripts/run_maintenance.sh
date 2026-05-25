#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "==> Compaction"
python run_operations.py ../sql/maintenance/01_compaction.sql

echo
echo "==> Expire snapshots"
python run_operations.py ../sql/maintenance/02_expire_snapshots.sql

echo
echo "==> Cleanup orphan files"
python run_operations.py ../sql/maintenance/03_cleanup_orphans.sql

echo
echo "Maintenance completed."
