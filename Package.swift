// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sms-relay",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "Relay", targets: ["Run"]),
    ],
    dependencies: [
        .package(url: "https://github.com/soto-project/soto.git", from: "5.1.0"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", .upToNextMajor(from: "0.3.0"))
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
            .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime"),
            .product(name: "SotoPinpoint", package: "soto")
        ]),
        .target(name: "Run", dependencies: [
            .target(name: "App"),
            .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime")
        ]),
        .testTarget(
            name: "SMSRelayTests",
            dependencies: [
                .target(name: "App")
            ],
            resources: [
                .process("test.json")
            ]
        )
    ]
)
