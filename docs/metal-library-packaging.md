# Metal library packaging

`BLAKE3Metal` supports two kernel library sources:

- `.runtimeSource`: compiles the bundled Metal source string with `makeLibrary(source:)`.
- `.metallib(URL)`: loads a precompiled Metal library from disk with `makeLibrary(URL:)`.

Runtime source compilation is convenient for development and tests. Production apps should prefer a packaged `.metallib` so startup cost, code signing, and deployment behavior are explicit.

## Export the bundled source

The benchmark executable can print the exact Metal source embedded in the library:

```sh
swift run -c release blake3-bench --print-metal-source > BLAKE3Metal.metal
```

The same source is available to integrators as `BLAKE3Metal.kernelSource` for custom build tooling.

## Compile a `.metallib`

For a macOS target:

```sh
xcrun -sdk macosx metal -c BLAKE3Metal.metal -o BLAKE3Metal.air
xcrun -sdk macosx metallib BLAKE3Metal.air -o BLAKE3Metal.metallib
```

For an iOS target, use the matching SDK:

```sh
xcrun -sdk iphoneos metal -c BLAKE3Metal.metal -o BLAKE3Metal.air
xcrun -sdk iphoneos metallib BLAKE3Metal.air -o BLAKE3Metal.metallib
```

## Load the packaged library

```swift
import Foundation
import Metal
import Blake3

let device = MTLCreateSystemDefaultDevice()!
let metallibURL = URL(fileURLWithPath: "/path/to/BLAKE3Metal.metallib")
let context = try BLAKE3Metal.makeContext(
    device: device,
    librarySource: .metallib(metallibURL)
)
```

File hashing Metal strategies accept the same library source:

```swift
let digest = try BLAKE3File.hash(
    path: "/path/to/input.bin",
    strategy: .metalTiledMemoryMapped(
        fallbackToCPU: false,
        librarySource: .metallib(metallibURL)
    )
)
```

## Benchmark with a packaged library

Pass the library explicitly:

```sh
swift run -c release blake3-bench \
  --sizes 16m,64m,256m \
  --metal-library /path/to/BLAKE3Metal.metallib \
  --metal-modes resident,staged,e2e
```

The fixture scripts also accept `METAL_LIBRARY=/path/to/BLAKE3Metal.metallib`. Publication artifacts should record whether a run used `runtime-source` or a packaged `.metallib`.
