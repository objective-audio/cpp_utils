// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cpp-utils",
    platforms: [.macOS(.v10_15), .iOS(.v13), .macCatalyst(.v13)],
    products: [
        .library(
            name: "cpp-utils",
            targets: ["cpp-utils"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/objective-audio/objc_utils.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "cpp-utils",
            dependencies: [
                .product(name: "objc-utils", package: "objc_utils")
            ],
            cxxSettings: [
                .unsafeFlags(["-fcxx-modules"]),
            ]
        ),
        .testTarget(
            name: "cpp-utils-tests",
            dependencies: [
                "cpp-utils",
            ]
        ),
    ],
    cLanguageStandard: .gnu18,
    cxxLanguageStandard: .gnucxx2b
)
