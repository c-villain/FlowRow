// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FlowRow",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "FlowRow",
            targets: ["FlowRow"]),
    ],
    targets: [
        .target(
            name: "FlowRow"),
    ]
)
