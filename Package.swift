// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "SubstrateClientSwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SubstrateClientSwift",
            targets: ["SubstrateClientSwift"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sublabdev/common-swift.git", exact: "1.0.0"),
        .package(url: "https://github.com/sublabdev/hashing-swift.git", exact: "1.0.0"),
        .package(url: "https://github.com/sublabdev/encrypting-swift.git", exact: "1.0.0"),
        .package(url: "https://github.com/sublabdev/scale-codec-swift.git", exact: "1.0.0")
    ],
    targets: [
        .target(
            name: "SubstrateClientSwift",
            dependencies: [
                .productItem(name: "CommonSwift", package: "common-swift"),
                .productItem(name: "HashingSwift", package: "hashing-swift"),
                .productItem(name: "EncryptingSwift", package: "encrypting-swift"),
                .productItem(name: "ScaleCodecSwift", package: "scale-codec-swift")
            ]
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

