// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ScreamNetworking",
    products: [
        .library(
            name: "ScreamNetworking",
            targets: ["ScreamNetworking"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ScreamNetworking",
            dependencies: [],
            path: "Source"),
    ]
)
