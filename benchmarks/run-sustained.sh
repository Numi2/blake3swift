#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIZES="${SIZES:-512m,1g}"
ITERATIONS="${ITERATIONS:-2}"
DURATION_SECONDS="${DURATION_SECONDS:-30}"
SUSTAINED_MODE="${SUSTAINED_MODE:-resident}"
SUSTAINED_POLICY="${SUSTAINED_POLICY:-gpu}"
CRYPTOKIT_MODES="${CRYPTOKIT_MODES:-none}"
OUT_DIR="${OUT_DIR:-benchmarks/results/$(date -u +%Y%m%dT%H%M%SZ)-sustained}"

mkdir -p "$OUT_DIR"
swift build -c release --product blake3-bench
BENCHMARK_BIN="${BENCHMARK_BIN:-$ROOT_DIR/.build/release/blake3-bench}"

{
  echo "date_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "commit=$(git rev-parse HEAD 2>/dev/null || true)"
  echo "swift=$(swift --version | tr '\n' ' ')"
  sw_vers 2>/dev/null || true
  sysctl -n machdep.cpu.brand_string 2>/dev/null || true
  sysctl -n hw.model 2>/dev/null || true
  if [[ -n "${METAL_LIBRARY:-}" ]]; then
    echo "metal_library=$METAL_LIBRARY"
  else
    echo "metal_library=runtime-source"
  fi
  echo "minimum_gpu_bytes=${MINIMUM_GPU_BYTES:-default}"
  echo "cryptokit_modes=$CRYPTOKIT_MODES"
} | tee "$OUT_DIR/environment.txt"

COMMAND=(
  "$BENCHMARK_BIN"
  --sizes "$SIZES"
  --iterations "$ITERATIONS"
  --metal-modes "$SUSTAINED_MODE"
  --cryptokit-modes "$CRYPTOKIT_MODES"
  --sustained-seconds "$DURATION_SECONDS"
  --sustained-mode "$SUSTAINED_MODE"
  --sustained-policy "$SUSTAINED_POLICY"
  --json-output "$OUT_DIR/sustained-$SUSTAINED_MODE.json"
)

if [[ -n "${METAL_LIBRARY:-}" ]]; then
  COMMAND+=(--metal-library "$METAL_LIBRARY")
fi

if [[ -n "${MINIMUM_GPU_BYTES:-}" ]]; then
  COMMAND+=(--minimum-gpu-bytes "$MINIMUM_GPU_BYTES")
fi

if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
  COMMAND+=(--memory-stats)
fi

"${COMMAND[@]}" | tee "$OUT_DIR/sustained-$SUSTAINED_MODE.md"
"$BENCHMARK_BIN" --validate-json "$OUT_DIR/sustained-$SUSTAINED_MODE.json"

echo "Wrote sustained benchmark artifacts to $OUT_DIR"
