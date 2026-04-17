#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIZES="${SIZES:-16m,64m,256m,512m,1g}"
ITERATIONS="${ITERATIONS:-8}"
OUT_DIR="${OUT_DIR:-benchmarks/results/$(date -u +%Y%m%dT%H%M%SZ)}"
CPU_WORKERS_ARG=()
MEMORY_STATS_ARG=()

if [[ -n "${CPU_WORKERS:-}" ]]; then
  CPU_WORKERS_ARG=(--cpu-workers "$CPU_WORKERS")
fi

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
  sysctl -n hw.perflevel0.physicalcpu 2>/dev/null | sed 's/^/performance_cores=/' || true
  sysctl -n hw.activecpu 2>/dev/null | sed 's/^/active_cpus=/' || true
} | tee "$OUT_DIR/environment.txt"

swift run -c release blake3-bench \
  --sizes "$SIZES" \
  --iterations "$ITERATIONS" \
  --metal-modes resident,e2e \
  --file-modes none \
  "${CPU_WORKERS_ARG[@]}" \
  "${MEMORY_STATS_ARG[@]}" \
  | tee "$OUT_DIR/cpu-metal-publication.md"

swift run -c release blake3-bench \
  --sizes "$SIZES" \
  --iterations "$ITERATIONS" \
  --metal-modes none \
  --file-modes read,mmap,mmap-parallel,metal-mmap,metal-tiled-mmap \
  "${CPU_WORKERS_ARG[@]}" \
  "${MEMORY_STATS_ARG[@]}" \
  | tee "$OUT_DIR/file-publication.md"

echo "Wrote benchmark artifacts to $OUT_DIR"
