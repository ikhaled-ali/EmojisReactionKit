// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EmojisReactionKit",
    platforms: [.iOS(.v13), .macCatalyst(.v13)],
    products: [
        .library(
            name: "EmojisReactionKit",
            targets: ["EmojisReactionKit"]),
    ],
    targets: [
        .target(
            name: "EmojisReactionKit", path: "Sources", resources: [.copy("PrivacyInfo.xcprivacy")]),

    ]
)
