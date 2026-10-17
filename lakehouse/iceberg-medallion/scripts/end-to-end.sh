#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

uv run python -m pipeline.bronze
uv run python -m pipeline.silver
uv run python -m pipeline.gold
