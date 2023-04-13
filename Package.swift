// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Mixture",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Mixture",
            targets: ["Mixture"]),
    ],
    targets: [
        .target(
            name: "Mixture",
            dependencies: []),
        .testTarget(
            name: "MixtureTests",
            dependencies: ["Mixture"]),
    ]
)
