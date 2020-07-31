// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Undoer",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "Undoer", targets: ["Undoer"]),
    ],
    targets: [
        .target(name: "Undoer"),
    ]
)
