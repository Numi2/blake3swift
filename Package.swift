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
            name: "Blake3"
        ),
        .executableTarget(
            name: "Blake3Benchmark",
            dependencies: ["Blake3"]
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
