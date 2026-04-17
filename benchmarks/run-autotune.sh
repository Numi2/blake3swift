#!/usr/bin/env bash
set -euo pipefail

SIZES="${SIZES:-${AUTOTUNE_SIZES:-16m,64m}}"
ITERATIONS="${ITERATIONS:-${AUTOTUNE_ITERATIONS:-3}}"
AUTOTUNE_GATES="${AUTOTUNE_GATES:-1m,4m,16m,64m}"
AUTOTUNE_MODES="${AUTOTUNE_MODES:-resident,staged,private-staged,e2e,private}"
AUTOTUNE_TILE_SIZES="${AUTOTUNE_TILE_SIZES:-8m,16m,32m,64m}"
OUT_DIR="${OUT_DIR:-benchmarks/results/$(date -u +%Y%m%dT%H%M%SZ)-autotune}"

mkdir -p "$OUT_DIR"

{
  echo "date_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  swift --version | tr '\n' ' '
  echo
  sw_vers 2>/dev/null || true
  sysctl -n machdep.cpu.brand_string 2>/dev/null || true
  echo "sizes=$SIZES"
  echo "iterations=$ITERATIONS"
  echo "autotune_gates=$AUTOTUNE_GATES"
  echo "autotune_modes=$AUTOTUNE_MODES"
  echo "autotune_file_tiles=${AUTOTUNE_FILE_TILES:-0}"
  echo "autotune_tile_sizes=$AUTOTUNE_TILE_SIZES"
  if [[ -n "${METAL_LIBRARY:-}" ]]; then
    echo "metal_library=$METAL_LIBRARY"
  fi
} > "$OUT_DIR/environment.txt"

COMMAND=(
  swift run -c release blake3-bench
  --autotune-metal
  --autotune-sizes "$SIZES"
  --autotune-iterations "$ITERATIONS"
  --autotune-gates "$AUTOTUNE_GATES"
  --autotune-metal-modes "$AUTOTUNE_MODES"
  --autotune-output "$OUT_DIR/autotune-metal.json"
)

if [[ -n "${METAL_LIBRARY:-}" ]]; then
  COMMAND+=(--metal-library "$METAL_LIBRARY")
fi

if [[ "${AUTOTUNE_FILE_TILES:-0}" == "1" ]]; then
  COMMAND+=(--autotune-file-tiles --autotune-tile-sizes "$AUTOTUNE_TILE_SIZES")
fi

"${COMMAND[@]}" | tee "$OUT_DIR/autotune-metal.md"
swift run -c release blake3-bench --validate-autotune-json "$OUT_DIR/autotune-metal.json"

echo "Wrote autotune artifacts to $OUT_DIR"
