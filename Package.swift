// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sms-relay",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/soto-project/soto.git", from: "6.6.0"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha.1"),
//        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", from: "0.1.0")
        .package(url: "https://github.com/hiimtmac/swift-aws-lambda-events.git", branch: "fix/sns-coding-keys")
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
                .enableUpcomingFeature("BareSlashRegexLiterals")
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
