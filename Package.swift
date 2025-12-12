// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sms-relay",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/soto-project/soto.git", from: "7.10.0"),
        .package(url: "https://github.com/awslabs/swift-aws-lambda-runtime.git", from: "2.4.0"),
        .package(url: "https://github.com/awslabs/swift-aws-lambda-events.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-configuration.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Lambda",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
                .product(name: "SotoPinpointSMSVoiceV2", package: "soto"),
                .product(name: "Configuration", package: "swift-configuration")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .unsafeFlags(["-Xlinker", "-S"], .when(configuration: .release))
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
