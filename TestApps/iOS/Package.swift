// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RunRunTestApp",
    platforms: [.iOS(.v16)],
    products: [
        .executable(name: "RunRunTestApp", targets: ["RunRunTestApp"])
    ],
    dependencies: [
        .package(path: "../../RunRunCore"),
        .package(path: "../../RunRuniOS")
    ],
    targets: [
        .executableTarget(
            name: "RunRunTestApp",
            dependencies: ["RunRunCore", "RunRuniOS"]
        )
    ]
)
