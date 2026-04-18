#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIZES="${SIZES:-64m,256m,512m}"
ITERATIONS="${ITERATIONS:-4}"
CPU_WORKER_COUNTS="${CPU_WORKER_COUNTS:-4 6 8 10}"
METAL_MODE_SETS="${METAL_MODE_SETS:-resident private staged e2e private,private-staged}"
METAL_GATE_BYTES_LIST="${METAL_GATE_BYTES_LIST:-16m}"
METAL_TILE_SIZES="${METAL_TILE_SIZES:-}"
OUT_DIR="${OUT_DIR:-benchmarks/results/$(date -u +%Y%m%dT%H%M%SZ)-tuning}"

mkdir -p "$OUT_DIR"
swift build -c release --product blake3-bench
BENCHMARK_BIN="${BENCHMARK_BIN:-$ROOT_DIR/.build/release/blake3-bench}"

for workers in $CPU_WORKER_COUNTS; do
  COMMAND=(
    "$BENCHMARK_BIN"
    --sizes "$SIZES"
    --iterations "$ITERATIONS"
    --metal-modes none
    --file-modes none
    --cpu-workers "$workers"
    --json-output "$OUT_DIR/cpu-workers-$workers.json"
  )
  if [[ -n "${METAL_LIBRARY:-}" ]]; then
    COMMAND+=(--metal-library "$METAL_LIBRARY")
  fi
  if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
    COMMAND+=(--memory-stats)
  fi
  "${COMMAND[@]}" | tee "$OUT_DIR/cpu-workers-$workers.md"
  "$BENCHMARK_BIN" --validate-json "$OUT_DIR/cpu-workers-$workers.json"
done

for modes in $METAL_MODE_SETS; do
  for gate_bytes in $METAL_GATE_BYTES_LIST; do
    safe_modes="${modes//,/-}"
    safe_gate="${gate_bytes//[^A-Za-z0-9]/-}"
    COMMAND=(
      "$BENCHMARK_BIN"
      --sizes "$SIZES"
      --iterations "$ITERATIONS"
      --metal-modes "$modes"
      --file-modes none
      --minimum-gpu-bytes "$gate_bytes"
      --json-output "$OUT_DIR/metal-$safe_modes-gate-$safe_gate.json"
    )
    if [[ -n "${METAL_LIBRARY:-}" ]]; then
      COMMAND+=(--metal-library "$METAL_LIBRARY")
    fi
    if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
      COMMAND+=(--memory-stats)
    fi
    "${COMMAND[@]}" | tee "$OUT_DIR/metal-$safe_modes-gate-$safe_gate.md"
    "$BENCHMARK_BIN" --validate-json "$OUT_DIR/metal-$safe_modes-gate-$safe_gate.json"
  done
done

for tile_size in $METAL_TILE_SIZES; do
  safe_tile="${tile_size//[^A-Za-z0-9]/-}"
  COMMAND=(
    "$BENCHMARK_BIN"
    --sizes "$SIZES"
    --iterations "$ITERATIONS"
    --metal-modes none
    --file-modes metal-tiled-mmap
    --metal-tile-size "$tile_size"
    --json-output "$OUT_DIR/metal-tiled-file-tile-$safe_tile.json"
  )
  if [[ -n "${METAL_LIBRARY:-}" ]]; then
    COMMAND+=(--metal-library "$METAL_LIBRARY")
  fi
  if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
    COMMAND+=(--memory-stats)
  fi
  "${COMMAND[@]}" | tee "$OUT_DIR/metal-tiled-file-tile-$safe_tile.md"
  "$BENCHMARK_BIN" --validate-json "$OUT_DIR/metal-tiled-file-tile-$safe_tile.json"
done

echo "Wrote tuning grid artifacts to $OUT_DIR"
