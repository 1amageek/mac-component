// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "mac-component",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "MacComponent", targets: ["MacComponent"]),
    ],
    targets: [
        .target(name: "MacComponent"),
    ]
)
