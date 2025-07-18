// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cachew",
    platforms: [ .iOS(.v14), .macOS(.v11) ],
    products: [
        .library(
            name: "Cachew",
            targets: ["Cachew"])
    ],
    targets: [
        .target(
            name: "Cachew"),
        .testTarget(
            name: "CachewTests",
            dependencies: ["Cachew"]
        )
    ]
)
