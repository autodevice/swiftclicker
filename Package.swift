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
        ),
        .executable(
            name: "SwiftClickerPerformanceTest",
            targets: ["SwiftClickerPerformanceTest"]
        ),
        .executable(
            name: "SwiftClickerMultiDeviceDemo",
            targets: ["SwiftClickerMultiDeviceDemo"]
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
        .executableTarget(
            name: "SwiftClickerPerformanceTest",
            dependencies: ["SwiftClicker"]
        ),
        .executableTarget(
            name: "SwiftClickerMultiDeviceDemo",
            dependencies: ["SwiftClicker"]
        ),
        .testTarget(
            name: "SwiftClickerTests",
            dependencies: ["SwiftClicker"]
        )
    ]
)