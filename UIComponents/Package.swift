// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "UIComponents",
            targets: ["UIComponents"]
        ),
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
            ]
        ),
        .testTarget(
            name: "UIComponentsTests",
            dependencies: ["UIComponents"]
        ),
    ]
)
