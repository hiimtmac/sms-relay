// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sms-relay",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/soto-project/soto.git", from: "6.8.0"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha.2"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "Lambda",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
                .product(name: "SotoPinpoint", package: "soto")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SMSRelayTests",
            dependencies: [
                .target(name: "Lambda"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events")
            ],
            resources: [
                .process("test.json")
            ]
        )
    ]
)
