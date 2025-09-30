// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RunRunApp",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .executable(name: "RunRunApp", targets: ["RunRunApp"])
    ],
    dependencies: [
        .package(path: "../RunRunCore"),
        .package(path: "../RunRuniOS")
    ],
    targets: [
        .executableTarget(
            name: "RunRunApp",
            dependencies: [
                "RunRunCore",
                "RunRuniOS"
            ]
        )
    ]
)
