#!/usr/bin/env bash
# Verifies the local environment is ready before creating the kind cluster.
# Works the same with Docker Desktop and Colima.
set -euo pipefail

echo "==> Checking required tools..."
MISSING=0
for bin in docker kind kubectl helm; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "  MISSING: ${bin}"
    MISSING=1
  else
    echo "  ok: $(command -v "${bin}")"
  fi
done
if [ "${MISSING}" -ne 0 ]; then
  echo
  echo "Install missing tools and re-run this script."
  echo "  brew install kind kubectl helm"
  echo "  brew install colima docker     # if you don't have a Docker engine yet"
  exit 1
fi

echo
echo "==> Checking Docker engine reachability..."
if ! docker info >/dev/null 2>&1; then
  cat >&2 <<'EOF'
ERROR: Docker daemon is not reachable.

If you use Colima, start it with enough resources:
  colima start --cpu 4 --memory 8 --disk 20

If you use Docker Desktop, open it from Applications and wait for the engine.

Confirm with:
  docker info
EOF
  exit 1
fi
echo "  ok"

echo
echo "==> Checking allocated resources..."
MEM_BYTES=$(docker info --format '{{.MemTotal}}')
MEM_GIB=$(awk -v b="${MEM_BYTES}" 'BEGIN{ printf "%.1f", b/1024/1024/1024 }')
CPUS=$(docker info --format '{{.NCPU}}')
echo "  CPUs: ${CPUS}"
echo "  Memory: ${MEM_GIB} GiB"

NEED_MEM_GIB=6
if awk -v m="${MEM_GIB}" -v n="${NEED_MEM_GIB}" 'BEGIN{ exit (m+0 < n+0) ? 0 : 1 }'; then
  cat >&2 <<EOF

WARNING: only ${MEM_GIB} GiB allocated. Recommended: ${NEED_MEM_GIB}+ GiB.
The overflow scenario may behave inconsistently below this threshold.

If using Colima, restart with:
  colima stop
  colima start --cpu 4 --memory 8 --disk 20
EOF
fi

NEED_CPU=2
if [ "${CPUS}" -lt "${NEED_CPU}" ]; then
  cat >&2 <<EOF

WARNING: only ${CPUS} CPUs allocated. Recommended: ${NEED_CPU}+ CPUs.
EOF
fi

echo
echo "==> All required tools and engine reachable. Next: ./01-setup.sh"
