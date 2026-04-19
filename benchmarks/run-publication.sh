#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIZES="${SIZES:-16m,64m,256m,512m,1g}"
ITERATIONS="${ITERATIONS:-8}"
METAL_MODES="${METAL_MODES:-resident,private,staged,wrapped,e2e}"
CRYPTOKIT_MODES="${CRYPTOKIT_MODES:-sha256}"
CRYPTOKIT_METAL_MODES="${CRYPTOKIT_METAL_MODES:-resident,staged,wrapped,e2e}"
OUT_DIR="${OUT_DIR:-benchmarks/results/$(date -u +%Y%m%dT%H%M%SZ)}"

mkdir -p "$OUT_DIR"
swift build -c release --product blake3-bench
BENCHMARK_BIN="${BENCHMARK_BIN:-$ROOT_DIR/.build/release/blake3-bench}"

{
  echo "date_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "commit=$(git rev-parse HEAD 2>/dev/null || true)"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ -n "$(git status --short)" ]]; then
      echo "working_tree=dirty"
      git status --short | sed 's/^/git_status=/'
    else
      echo "working_tree=clean"
    fi
  fi
  echo "swift=$(swift --version | tr '\n' ' ')"
  sw_vers 2>/dev/null || true
  sysctl -n machdep.cpu.brand_string 2>/dev/null || true
  sysctl -n hw.model 2>/dev/null || true
  sysctl -n hw.perflevel0.physicalcpu 2>/dev/null | sed 's/^/performance_cores=/' || true
  sysctl -n hw.activecpu 2>/dev/null | sed 's/^/active_cpus=/' || true
  if [[ -n "${METAL_LIBRARY:-}" ]]; then
    echo "metal_library=$METAL_LIBRARY"
  else
    echo "metal_library=runtime-source"
  fi
  echo "minimum_gpu_bytes=${MINIMUM_GPU_BYTES:-default}"
  echo "metal_tile_size=${METAL_TILE_SIZE:-default}"
  echo "metal_modes=$METAL_MODES"
  echo "cryptokit_modes=$CRYPTOKIT_MODES"
  echo "cryptokit_metal_modes=$CRYPTOKIT_METAL_MODES"
} | tee "$OUT_DIR/environment.txt"

CPU_METAL_COMMAND=(
  "$BENCHMARK_BIN"
  --sizes "$SIZES"
  --iterations "$ITERATIONS"
  --metal-modes "$METAL_MODES"
  --cryptokit-modes none
  --file-modes none
  --json-output "$OUT_DIR/cpu-metal-publication.json"
)

FILE_COMMAND=(
  "$BENCHMARK_BIN"
  --sizes "$SIZES"
  --iterations "$ITERATIONS"
  --metal-modes none
  --cryptokit-modes none
  --file-modes read,mmap,mmap-parallel,metal-mmap,metal-tiled-mmap,metal-staged-read
  --json-output "$OUT_DIR/file-publication.json"
)

CRYPTOKIT_COMMAND=(
  "$BENCHMARK_BIN"
  --sizes "$SIZES"
  --iterations "$ITERATIONS"
  --metal-modes "$CRYPTOKIT_METAL_MODES"
  --cryptokit-modes "$CRYPTOKIT_MODES"
  --file-modes none
  --json-output "$OUT_DIR/cryptokit-comparison.json"
)

if [[ -n "${CPU_WORKERS:-}" ]]; then
  CPU_METAL_COMMAND+=(--cpu-workers "$CPU_WORKERS")
  FILE_COMMAND+=(--cpu-workers "$CPU_WORKERS")
  CRYPTOKIT_COMMAND+=(--cpu-workers "$CPU_WORKERS")
fi

if [[ -n "${METAL_LIBRARY:-}" ]]; then
  CPU_METAL_COMMAND+=(--metal-library "$METAL_LIBRARY")
  FILE_COMMAND+=(--metal-library "$METAL_LIBRARY")
  CRYPTOKIT_COMMAND+=(--metal-library "$METAL_LIBRARY")
fi

if [[ -n "${MINIMUM_GPU_BYTES:-}" ]]; then
  CPU_METAL_COMMAND+=(--minimum-gpu-bytes "$MINIMUM_GPU_BYTES")
  FILE_COMMAND+=(--minimum-gpu-bytes "$MINIMUM_GPU_BYTES")
  CRYPTOKIT_COMMAND+=(--minimum-gpu-bytes "$MINIMUM_GPU_BYTES")
fi

if [[ -n "${METAL_TILE_SIZE:-}" ]]; then
  FILE_COMMAND+=(--metal-tile-size "$METAL_TILE_SIZE")
fi

if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
  CPU_METAL_COMMAND+=(--memory-stats)
  FILE_COMMAND+=(--memory-stats)
  CRYPTOKIT_COMMAND+=(--memory-stats)
fi

"${CPU_METAL_COMMAND[@]}" | tee "$OUT_DIR/cpu-metal-publication.md"
"$BENCHMARK_BIN" --validate-json "$OUT_DIR/cpu-metal-publication.json"

"${FILE_COMMAND[@]}" | tee "$OUT_DIR/file-publication.md"
"$BENCHMARK_BIN" --validate-json "$OUT_DIR/file-publication.json"

if [[ "$CRYPTOKIT_MODES" != "none" && "$CRYPTOKIT_MODES" != "off" && "$CRYPTOKIT_MODES" != "disabled" ]]; then
  "${CRYPTOKIT_COMMAND[@]}" | tee "$OUT_DIR/cryptokit-comparison.md"
  "$BENCHMARK_BIN" --validate-json "$OUT_DIR/cryptokit-comparison.json"
fi

echo "Wrote benchmark artifacts to $OUT_DIR"
