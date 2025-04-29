// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cpp-utils",
    platforms: [.macOS(.v14), .iOS(.v17), .macCatalyst(.v17)],
    products: [
        .library(
            name: "cpp-utils",
            targets: ["cpp-utils", "objc-utils", "observing"]
        ),
    ],
    targets: [
        .target(
            name: "objc-utils",
            cSettings: [
                .unsafeFlags(["-fno-objc-arc"])
            ]),
        .target(
            name: "cpp-utils",
            dependencies: [
                "objc-utils",
            ],
            cxxSettings: [
                .unsafeFlags(["-fcxx-modules"]),
                .define("ACCELERATE_NEW_LAPACK", to: "1"),
                .define("ACCELERATE_LAPACK_ILP64", to: "1"),
            ],
            linkerSettings: [
                .linkedFramework("Accelerate"),
            ]
        ),
        .target(
            name: "observing",
            dependencies: [
                "cpp-utils"
            ]
        ),
        .testTarget(
            name: "objc-utils-tests",
            dependencies: [
                "objc-utils",
            ],
            cSettings: [
                .unsafeFlags(["-fno-objc-arc"])
            ]),
        .testTarget(
            name: "cpp-utils-tests",
            dependencies: [
                "cpp-utils",
            ]
        ),
        .testTarget(
            name: "observing-tests",
            dependencies: [
                "observing",
            ],
            cxxSettings: [
                .unsafeFlags(["-fcxx-modules"])
            ]
        ),
    ],
    cLanguageStandard: .gnu2x,
    cxxLanguageStandard: .gnucxx2b
)
