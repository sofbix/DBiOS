// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealmDBModule",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RealmDBModule",
            targets: ["RealmDBModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift", from: "10.50.0"),
    ],
    targets: [
        .target(
            name: "RealmDBModule",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift")
            ],
            path: "Sources/RealmDBModule"
        )
    ]
)
