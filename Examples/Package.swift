// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BLAKE3SwiftExamples",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(name: "blake3swift", path: "..")
    ],
    targets: [
        .executableTarget(
            name: "Blake3Examples",
            dependencies: [
                .product(name: "Blake3", package: "blake3swift")
            ]
        )
    ]
)
