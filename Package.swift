// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GeoURI",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "GeoURI",
            targets: ["GeoURI"]),
    ],
    targets: [
        .target(
            name: "GeoURI"),
        .testTarget(
            name: "GeoURITests",
            dependencies: ["GeoURI"]),
    ]
)
