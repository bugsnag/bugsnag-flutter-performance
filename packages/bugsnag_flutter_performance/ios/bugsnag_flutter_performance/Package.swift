// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "bugsnag_flutter_performance",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "bugsnag-flutter-performance", targets: ["bugsnag_flutter_performance"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "bugsnag_flutter_performance",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
