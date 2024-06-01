// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDataModule",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftDataModule",
            targets: ["SwiftDataModule"]),
    ],
    dependencies: [
        .package(path: "../CoreModule"),
    ],
    targets: [
        .target(
            name: "SwiftDataModule",
            dependencies: [
                .product(name: "CoreModule", package: "CoreModule")
            ],
            path: "Sources/SwiftDataModule"
        )
    ]
)
