// swift-tools-version:5.1

/**
 *  https://github.com/tadija/AETool
 *  Copyright © 2020 Marko Tadić
 *  Licensed under the MIT license
 */

import PackageDescription

let package = Package(
    name: "AETool",
    products: [
        .library(
            name: "AETool",
            targets: ["AETool"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/tadija/AECli.git", from: "0.1.0"
        ),
        .package(
            url: "https://github.com/tadija/AEShell.git", from: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "AETool",
            dependencies: ["AECli", "AEShell"]
        ),
        .testTarget(
            name: "AEToolTests",
            dependencies: ["AETool"]
        ),
    ]
)
