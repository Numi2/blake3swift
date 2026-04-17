#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIZES="${SIZES:-1m,16m}"
ITERATIONS="${ITERATIONS:-2}"
METAL_MODES="${METAL_MODES:-resident,e2e}"
FILE_MODES="${FILE_MODES:-none}"
MEMORY_STATS_ARG=()

if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
  MEMORY_STATS_ARG=(--memory-stats)
fi

swift run -c release blake3-bench \
  --sizes "$SIZES" \
  --iterations "$ITERATIONS" \
  --metal-modes "$METAL_MODES" \
  --file-modes "$FILE_MODES" \
  "${MEMORY_STATS_ARG[@]}"
