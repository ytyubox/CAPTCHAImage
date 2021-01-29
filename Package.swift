// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CAPTCHAImage",
    platforms: [SupportedPlatform.iOS(.v12)],
    products: [
        .library(
            name: "CAPTCHAImage",
            targets: ["CAPTCHAImage"]
        ),
    ],
    dependencies: [
        .package(url: "~/Desktop/TestUtils",
                 .branch("main")),
    ],
    targets: [
        .target(
            name: "CAPTCHAImage",
            dependencies: []
        ),
        .testTarget(
            name: "CAPTCHAImageTests",
            dependencies: ["CAPTCHAImage", "TestUtils"]
        ),
    ]
)
