// swift-tools-version:5.3

import PackageDescription

let Auth22: Target.Dependency = .product(name: "FirewrapAuth", package: "Firewrap")
let Database: Target.Dependency = .product(name: "FirewrapDatabase", package: "Firewrap")

let package = Package(
    name: "FirebaseProfile",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "FirebaseProfile",
            targets: ["FirebaseProfile"]
        )
    ],
    dependencies: [
        .package(
            name: "Firewrap",
            url: "https://github.com/sparrowcode/Firewrap", .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        .target(
            name: "FirebaseProfile",
            dependencies: [Auth22, Database]
        )
    ],
    swiftLanguageVersions: [.v5]
)
