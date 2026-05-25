// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ExchangeFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "ExchangeFeature",
            targets: ["ExchangeFeature"]
        ),
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../Utilities"),
        .package(path: "../UIComponents"),
        .package(path: "../Networking"),
    ],
    targets: [
        .target(
            name: "ExchangeFeature",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Utilities", package: "Utilities"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "Networking", package: "Networking"),
            ],
            resources: [
                .process("Resources/default_currencies.json")
            ]
        ),
        .testTarget(
            name: "ExchangeFeatureTests",
            dependencies: ["ExchangeFeature"]
        ),
    ]
)
