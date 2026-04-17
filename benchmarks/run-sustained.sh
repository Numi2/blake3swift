#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIZES="${SIZES:-512m,1g}"
ITERATIONS="${ITERATIONS:-2}"
DURATION_SECONDS="${DURATION_SECONDS:-30}"
SUSTAINED_MODE="${SUSTAINED_MODE:-resident}"
SUSTAINED_POLICY="${SUSTAINED_POLICY:-gpu}"
OUT_DIR="${OUT_DIR:-benchmarks/results/$(date -u +%Y%m%dT%H%M%SZ)-sustained}"
MEMORY_STATS_ARG=()

if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
  MEMORY_STATS_ARG=(--memory-stats)
fi

mkdir -p "$OUT_DIR"

{
  echo "date_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "commit=$(git rev-parse HEAD 2>/dev/null || true)"
  echo "swift=$(swift --version | tr '\n' ' ')"
  sw_vers 2>/dev/null || true
  sysctl -n machdep.cpu.brand_string 2>/dev/null || true
  sysctl -n hw.model 2>/dev/null || true
} | tee "$OUT_DIR/environment.txt"

swift run -c release blake3-bench \
  --sizes "$SIZES" \
  --iterations "$ITERATIONS" \
  --metal-modes "$SUSTAINED_MODE" \
  --sustained-seconds "$DURATION_SECONDS" \
  --sustained-mode "$SUSTAINED_MODE" \
  --sustained-policy "$SUSTAINED_POLICY" \
  "${MEMORY_STATS_ARG[@]}" \
  | tee "$OUT_DIR/sustained-$SUSTAINED_MODE.md"

echo "Wrote sustained benchmark artifacts to $OUT_DIR"
