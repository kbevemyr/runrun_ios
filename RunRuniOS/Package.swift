// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RunRuniOS",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "RunRuniOS", targets: ["RunRuniOS"])
    ],
    dependencies: [
        .package(path: "../RunRunCore")
    ],
    targets: [
        .target(
            name: "RunRuniOS",
            dependencies: ["RunRunCore"]
        )
    ]
)
