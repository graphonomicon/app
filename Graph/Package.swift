// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Graph",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "Graph",
            targets: ["Graph"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Graph",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "Tests",
            dependencies: ["Graph"],
            path: "Tests")
    ]
)
