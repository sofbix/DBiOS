// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealmModule",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RealmModule",
            targets: ["RealmModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift", from: "10.50.0"),
    ],
    targets: [
        .target(
            name: "RealmModule",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift")
            ],
            path: "Sources/RealmModule"
        )
    ]
)
