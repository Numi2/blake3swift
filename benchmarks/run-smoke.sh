#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

swift build -c release --product blake3-bench
BENCHMARK_BIN="${BENCHMARK_BIN:-$ROOT_DIR/.build/release/blake3-bench}"

SIZES="${SIZES:-1m,16m}"
ITERATIONS="${ITERATIONS:-2}"
METAL_MODES="${METAL_MODES:-resident,e2e}"
CRYPTOKIT_MODES="${CRYPTOKIT_MODES:-sha256}"
FILE_MODES="${FILE_MODES:-none}"

COMMAND=(
  "$BENCHMARK_BIN"
  --sizes "$SIZES"
  --iterations "$ITERATIONS"
  --metal-modes "$METAL_MODES"
  --cryptokit-modes "$CRYPTOKIT_MODES"
  --file-modes "$FILE_MODES"
)

if [[ -n "${METAL_LIBRARY:-}" ]]; then
  COMMAND+=(--metal-library "$METAL_LIBRARY")
fi

if [[ -n "${MINIMUM_GPU_BYTES:-}" ]]; then
  COMMAND+=(--minimum-gpu-bytes "$MINIMUM_GPU_BYTES")
fi

if [[ -n "${METAL_TILE_SIZE:-}" ]]; then
  COMMAND+=(--metal-tile-size "$METAL_TILE_SIZE")
fi

if [[ -n "${JSON_OUTPUT:-}" && "${JSON_OUTPUT:-}" != "0" ]]; then
  COMMAND+=(--json-output "$JSON_OUTPUT")
fi

if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
  COMMAND+=(--memory-stats)
fi

"${COMMAND[@]}"

if [[ -n "${JSON_OUTPUT:-}" && "${JSON_OUTPUT:-}" != "0" ]]; then
  "$BENCHMARK_BIN" --validate-json "$JSON_OUTPUT"
fi
