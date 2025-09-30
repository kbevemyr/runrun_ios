// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RunRunCore",
    platforms: [
        .iOS(.v17), .watchOS(.v6)
    ],
    products: [
        .library(name: "RunRunCore", targets: ["RunRunCore"]),
        .executable(name: "Runner", targets: ["Runner"])
    ],
    targets: [
        .target(name: "RunRunCore"),
        .executableTarget(name: "Runner", dependencies: ["RunRunCore"]),
        .testTarget(name: "RunRunCoreTests", dependencies: ["RunRunCore"])
    ]
)
