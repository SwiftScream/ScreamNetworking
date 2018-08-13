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
        .package(url: "git@github.com:SwiftScream/URITemplate.git", from: "2.0.0"),
        .package(url: "git@github.com:SwiftScream/ScreamEssentials.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ScreamNetworking",
            dependencies: ["URITemplate", "ScreamEssentials"],
            path: "Source"),
    ]
)
