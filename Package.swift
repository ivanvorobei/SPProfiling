// swift-tools-version:5.3

import PackageDescription

let FirebaseWrapper: Target.Dependency = .product(name: "FirebaseWrapper", package: "FirebaseWrapper")
let FirebaseWrapperAuth: Target.Dependency = .product(name: "FirebaseWrapperAuth", package: "FirebaseWrapper")

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
            name: "FirebaseWrapper",
            url: "https://github.com/sparrowcode/FirebaseWrapper", .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        .target(
            name: "FirebaseProfile",
            dependencies: [FirebaseWrapper, FirebaseWrapperAuth]
        )
    ],
    swiftLanguageVersions: [.v5]
)
