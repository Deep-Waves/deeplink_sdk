// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "deeplink_sdk",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "deeplink_sdk",
            targets: ["deeplink_sdk"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "deeplink_sdk",
            dependencies: [],
            path: "Classes"
        )
    ]
)
