// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Context",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7),
    ],
    products: [
        .library(name: "Context", targets: ["Context"]),
    ],
    targets: [
        .target(name: "Context"),
    ]
)
