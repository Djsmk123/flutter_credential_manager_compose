// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "credential_manager_ios",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "credential-manager-ios", targets: ["credential_manager_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "credential_manager_ios",
            dependencies: []
        )
    ]
)
