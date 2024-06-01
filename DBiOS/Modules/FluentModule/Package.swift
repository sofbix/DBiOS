// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FluentModule",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FluentModule",
            targets: ["FluentModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.6.0"),
    ],
    targets: [
        .target(
            name: "FluentModule",
            dependencies: [
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ],
            path: "Sources/FluentModule"
        )
    ]
)
