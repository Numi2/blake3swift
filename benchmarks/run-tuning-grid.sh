#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIZES="${SIZES:-64m,256m,512m}"
ITERATIONS="${ITERATIONS:-4}"
CPU_WORKER_COUNTS="${CPU_WORKER_COUNTS:-4 6 8 10}"
METAL_MODE_SETS="${METAL_MODE_SETS:-resident private staged e2e private,private-staged}"
OUT_DIR="${OUT_DIR:-benchmarks/results/$(date -u +%Y%m%dT%H%M%SZ)-tuning}"
MEMORY_STATS_ARG=()

if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
  MEMORY_STATS_ARG=(--memory-stats)
fi

mkdir -p "$OUT_DIR"

for workers in $CPU_WORKER_COUNTS; do
  swift run -c release blake3-bench \
    --sizes "$SIZES" \
    --iterations "$ITERATIONS" \
    --metal-modes none \
    --file-modes none \
    --cpu-workers "$workers" \
    "${MEMORY_STATS_ARG[@]}" \
    | tee "$OUT_DIR/cpu-workers-$workers.md"
done

for modes in $METAL_MODE_SETS; do
  safe_name="${modes//,/-}"
  swift run -c release blake3-bench \
    --sizes "$SIZES" \
    --iterations "$ITERATIONS" \
    --metal-modes "$modes" \
    --file-modes none \
    "${MEMORY_STATS_ARG[@]}" \
    | tee "$OUT_DIR/metal-$safe_name.md"
done

echo "Wrote tuning grid artifacts to $OUT_DIR"
