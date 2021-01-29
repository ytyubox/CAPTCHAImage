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
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ytyubox/TestUtils.git",
                 from: "1.0.0"
                 ),
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
