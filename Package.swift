// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SplitView",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "SplitView", targets: ["SplitView"]),
    ],
    targets: [
        .target(name: "SplitView"),
    ]
)
