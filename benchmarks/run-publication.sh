#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIZES="${SIZES:-16m,64m,256m,512m,1g}"
ITERATIONS="${ITERATIONS:-8}"
OUT_DIR="${OUT_DIR:-benchmarks/results/$(date -u +%Y%m%dT%H%M%SZ)}"

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
  if [[ -n "${METAL_LIBRARY:-}" ]]; then
    echo "metal_library=$METAL_LIBRARY"
  else
    echo "metal_library=runtime-source"
  fi
  echo "minimum_gpu_bytes=${MINIMUM_GPU_BYTES:-default}"
  echo "metal_tile_size=${METAL_TILE_SIZE:-default}"
} | tee "$OUT_DIR/environment.txt"

CPU_METAL_COMMAND=(
  swift run -c release blake3-bench
  --sizes "$SIZES"
  --iterations "$ITERATIONS"
  --metal-modes resident,e2e
  --file-modes none
  --json-output "$OUT_DIR/cpu-metal-publication.json"
)

FILE_COMMAND=(
  swift run -c release blake3-bench
  --sizes "$SIZES"
  --iterations "$ITERATIONS"
  --metal-modes none
  --file-modes read,mmap,mmap-parallel,metal-mmap,metal-tiled-mmap
  --json-output "$OUT_DIR/file-publication.json"
)

if [[ -n "${CPU_WORKERS:-}" ]]; then
  CPU_METAL_COMMAND+=(--cpu-workers "$CPU_WORKERS")
  FILE_COMMAND+=(--cpu-workers "$CPU_WORKERS")
fi

if [[ -n "${METAL_LIBRARY:-}" ]]; then
  CPU_METAL_COMMAND+=(--metal-library "$METAL_LIBRARY")
  FILE_COMMAND+=(--metal-library "$METAL_LIBRARY")
fi

if [[ -n "${MINIMUM_GPU_BYTES:-}" ]]; then
  CPU_METAL_COMMAND+=(--minimum-gpu-bytes "$MINIMUM_GPU_BYTES")
  FILE_COMMAND+=(--minimum-gpu-bytes "$MINIMUM_GPU_BYTES")
fi

if [[ -n "${METAL_TILE_SIZE:-}" ]]; then
  FILE_COMMAND+=(--metal-tile-size "$METAL_TILE_SIZE")
fi

if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
  CPU_METAL_COMMAND+=(--memory-stats)
  FILE_COMMAND+=(--memory-stats)
fi

"${CPU_METAL_COMMAND[@]}" | tee "$OUT_DIR/cpu-metal-publication.md"
swift run -c release blake3-bench --validate-json "$OUT_DIR/cpu-metal-publication.json"

"${FILE_COMMAND[@]}" | tee "$OUT_DIR/file-publication.md"
swift run -c release blake3-bench --validate-json "$OUT_DIR/file-publication.json"

echo "Wrote benchmark artifacts to $OUT_DIR"
