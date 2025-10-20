// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftClicker",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftClicker",
            targets: ["SwiftClicker"]
        ),
        .executable(
            name: "SwiftClickerDemo",
            targets: ["SwiftClickerDemo"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftClicker",
            dependencies: []
        ),
        .executableTarget(
            name: "SwiftClickerDemo",
            dependencies: ["SwiftClicker"]
        ),
        .testTarget(
            name: "SwiftClickerTests",
            dependencies: ["SwiftClicker"]
        )
    ]
)