#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-"$ROOT_DIR/.build/metal"}"
CONFIGURATION="${CONFIGURATION:-release}"

mkdir -p "$OUTPUT_DIR"

SOURCE_PATH="$OUTPUT_DIR/blake3.metal"
AIR_PATH="$OUTPUT_DIR/blake3.air"
LIBRARY_PATH="$OUTPUT_DIR/blake3.metallib"

swift run \
  --package-path "$ROOT_DIR" \
  -c "$CONFIGURATION" \
  blake3-bench \
  --print-metal-source > "$SOURCE_PATH"

xcrun -sdk macosx metal -c "$SOURCE_PATH" -o "$AIR_PATH"
xcrun -sdk macosx metallib "$AIR_PATH" -o "$LIBRARY_PATH"

printf '%s\n' "$LIBRARY_PATH"
