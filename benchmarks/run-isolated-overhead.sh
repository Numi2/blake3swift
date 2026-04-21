#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIZES="${SIZES:-16m,64m,256m}"
ITERATIONS="${ITERATIONS:-6}"
ISOLATED_METAL_MODES="${ISOLATED_METAL_MODES:-resident private staged wrapped}"
REPEATS="${REPEATS:-1}"
COOLDOWN_SECONDS="${COOLDOWN_SECONDS:-15}"
CRYPTOKIT_MODES="${CRYPTOKIT_MODES:-none}"
OUT_DIR="${OUT_DIR:-benchmarks/results/$(date -u +%Y%m%dT%H%M%SZ)-isolated-overhead}"

mkdir -p "$OUT_DIR"
swift build -c release --product blake3-bench
BENCHMARK_BIN="${BENCHMARK_BIN:-$ROOT_DIR/.build/release/blake3-bench}"

safe_name() {
  local value="$1"
  echo "${value//[^A-Za-z0-9]/-}"
}

capture_thermal() {
  local path="$1"
  {
    echo "date_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    pmset -g therm 2>/dev/null || true
  } > "$path"
}

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
  echo "sizes=$SIZES"
  echo "iterations=$ITERATIONS"
  echo "isolated_metal_modes=$ISOLATED_METAL_MODES"
  echo "repeats=$REPEATS"
  echo "cooldown_seconds=$COOLDOWN_SECONDS"
  echo "cpu_workers=${CPU_WORKERS:-default}"
  echo "minimum_gpu_bytes=${MINIMUM_GPU_BYTES:-default}"
  echo "cryptokit_modes=$CRYPTOKIT_MODES"
  echo "memory_stats=${MEMORY_STATS:-0}"
  echo "default_backend=${BLAKE3_SWIFT_BACKEND:-default}"
  echo "default_metal_min_bytes_env=${BLAKE3_SWIFT_METAL_MIN_BYTES:-default}"
  echo "fused_tile_chunks=${BLAKE3_SWIFT_METAL_FUSED_TILE_CHUNKS:-default}"
  echo "fused_tile_reduction=${BLAKE3_SWIFT_METAL_FUSED_TILE_REDUCTION:-default}"
  echo "acceptance_harness=primary-overhead"
  echo "notes=run resident/private/staged/wrapped in separate benchmark processes; mixed publication sweep is secondary"
} | tee "$OUT_DIR/environment.txt"

capture_thermal "$OUT_DIR/thermal-start.txt"

for repeat in $(seq 1 "$REPEATS"); do
  for mode in $ISOLATED_METAL_MODES; do
    safe_mode="$(safe_name "$mode")"
    prefix="$OUT_DIR/metal-$safe_mode-r$repeat"
    COMMAND=(
      "$BENCHMARK_BIN"
      --sizes "$SIZES"
      --iterations "$ITERATIONS"
      --metal-modes "$mode"
      --cryptokit-modes "$CRYPTOKIT_MODES"
      --file-modes none
      --json-output "$prefix.json"
    )

    if [[ -n "${CPU_WORKERS:-}" ]]; then
      COMMAND+=(--cpu-workers "$CPU_WORKERS")
    fi

    if [[ -n "${METAL_LIBRARY:-}" ]]; then
      COMMAND+=(--metal-library "$METAL_LIBRARY")
    fi

    if [[ -n "${MINIMUM_GPU_BYTES:-}" ]]; then
      COMMAND+=(--minimum-gpu-bytes "$MINIMUM_GPU_BYTES")
    fi

    if [[ "${MEMORY_STATS:-0}" == "1" ]]; then
      COMMAND+=(--memory-stats)
    fi

    capture_thermal "$prefix-thermal-before.txt"
    "${COMMAND[@]}" | tee "$prefix.md"
    "$BENCHMARK_BIN" --validate-json "$prefix.json"
    capture_thermal "$prefix-thermal-after.txt"

    if [[ "$COOLDOWN_SECONDS" != "0" ]]; then
      sleep "$COOLDOWN_SECONDS"
    fi
  done
done

capture_thermal "$OUT_DIR/thermal-end.txt"

if command -v jq >/dev/null 2>&1; then
  {
    echo "| Repeat | Mode | Size | Policy | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |"
    echo "| ---: | --- | --- | --- | ---: | ---: | ---: | ---: | --- |"
    for json in "$OUT_DIR"/metal-*-r*.json; do
      repeat_name="${json##*-r}"
      repeat_name="${repeat_name%.json}"
      jq -r --arg repeat "$repeat_name" '
        .rows[]
        | select(.backend == "metal")
        | [
            $repeat,
            .mode,
            .size,
            .policy,
            (.median_gib_per_second | tostring),
            (.minimum_gib_per_second | tostring),
            (.p95_gib_per_second | tostring),
            (.maximum_gib_per_second | tostring),
            (if .correct then "ok" else "bad" end)
          ]
        | "| " + join(" | ") + " |"
      ' "$json"
    done
  } > "$OUT_DIR/summary.md"
fi

echo "Wrote isolated overhead benchmark artifacts to $OUT_DIR"
