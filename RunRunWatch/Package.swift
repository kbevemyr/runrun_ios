// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RunRunWatch",
    platforms: [.watchOS(.v6)],
    products: [
        .library(name: "RunRunWatch", targets: ["RunRunWatch"])
    ],
    dependencies: [
        .package(path: "../RunRunCore")
    ],
    targets: [
        .target(
            name: "RunRunWatch",
            dependencies: ["RunRunCore"]
        )
    ]
)
