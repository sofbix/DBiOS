// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreStoreModule",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CoreStoreModule",
            targets: ["CoreStoreModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnEstropia/CoreStore", from: "9.0.0"),
    ],
    targets: [
        .target(
            name: "CoreStoreModule",
            dependencies: [
                .product(name: "CoreStore", package: "CoreStore")
            ],
            path: "Sources/CoreStoreModule"
        )
    ]
)
