// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RunRunWatchTestApp",
    platforms: [.watchOS(.v9)],
    products: [
        .executable(name: "RunRunWatchTestApp", targets: ["RunRunWatchTestApp"])
    ],
    dependencies: [
        .package(path: "../../RunRunCore"),
        .package(path: "../../RunRunWatch")
    ],
    targets: [
        .executableTarget(
            name: "RunRunWatchTestApp",
            dependencies: ["RunRunCore", "RunRunWatch"]
        )
    ]
)
