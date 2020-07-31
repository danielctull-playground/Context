// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Context",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "Context", targets: ["Context"]),
    ],
    targets: [
        .target(name: "Context"),
    ]
)
