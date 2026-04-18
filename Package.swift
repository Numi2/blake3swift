// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "blake3swift",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Blake3",
            targets: ["Blake3"]
        ),
        .executable(
            name: "blake3-bench",
            targets: ["Blake3Benchmark"]
        )
    ],
    targets: [
        .target(
            name: "CBLAKE3",
            cSettings: [
                .define("BLAKE3_NO_SSE2"),
                .define("BLAKE3_NO_SSE41"),
                .define("BLAKE3_NO_AVX2"),
                .define("BLAKE3_NO_AVX512"),
                .headerSearchPath("include")
            ]
        ),
        .target(
            name: "Blake3"
        ),
        .target(
            name: "Blake3BenchmarkSupport",
            dependencies: ["Blake3", "CBLAKE3"]
        ),
        .executableTarget(
            name: "Blake3Benchmark",
            dependencies: ["Blake3", "Blake3BenchmarkSupport"]
        ),
        .testTarget(
            name: "Blake3Tests",
            dependencies: ["Blake3"],
            resources: [
                .copy("Resources/test_vectors.json")
            ]
        )
    ]
)
