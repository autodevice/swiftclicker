# SwiftClicker Integration Examples

Real-world examples of using SwiftClicker in your Swift projects.

## 📱 iOS App Testing

Automate your Android app testing from an iOS test suite:

```swift
import XCTest
import SwiftClicker

class AndroidAppTests: XCTestCase {
    var device: Device!
    
    override func setUp() async throws {
        device = Device()
        try await device.connect()
    }
    
    override func tearDown() async throws {
        await device.disconnect()
    }
    
    func testLoginFlow() async throws {
        // Navigate to login screen
        await device.click(x: 540, y: 1000)  // Login button
        
        // Enter credentials
        await device.click(x: 540, y: 800)   // Username field
        await device.press("delete")         // Clear field
        // Type username via multiple key presses or use clipboard
        
        await device.click(x: 540, y: 900)   // Password field
        // Enter password...
        
        await device.click(x: 540, y: 1100)  // Submit button
        
        // Verify navigation (check UI elements, take screenshot, etc.)
    }
    
    func testGestureNavigation() async throws {
        // Swipe through onboarding screens
        for _ in 0..<3 {
            await device.swipe(fromX: 800, fromY: 1200, toX: 200, toY: 1200)
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        // Long press for context menu
        await device.longPress(x: 400, y: 600, duration: 1.5)
    }
}
```

## 🎮 Game Automation

Automate repetitive game actions:

```swift
import SwiftClicker

class GameBot {
    private let device = Device()
    
    func startBot() async throws {
        try await device.connect()
        
        // Main game loop
        while true {
            await performDailyQuests()
            await collectRewards()
            try await Task.sleep(nanoseconds: 300_000_000_000) // 5 minutes
        }
    }
    
    private func performDailyQuests() async {
        // Navigate to quests
        await device.click(x: 200, y: 2200)  // Quest tab
        
        // Complete available quests
        for questIndex in 0..<5 {
            let questY = 800 + (questIndex * 200)
            await device.click(x: 900, y: questY)  // Start quest
            
            // Wait for quest completion
            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
            
            await device.click(x: 540, y: 1800)   // Collect reward
        }
    }
    
    private func collectRewards() async {
        // Open rewards screen
        await device.click(x: 100, y: 100)   // Menu
        await device.click(x: 300, y: 400)   // Rewards
        
        // Tap all reward chests
        let chestPositions = [
            (200, 600), (400, 600), (600, 600),
            (200, 900), (400, 900), (600, 900)
        ]
        
        for (x, y) in chestPositions {
            await device.click(x: x, y: y)
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        await device.press("back")  // Return to main screen
    }
}

// Usage
let bot = GameBot()
try await bot.startBot()
```

## 🔄 CI/CD Integration

Integrate with your continuous integration pipeline:

```swift
// CI Test Script
import Foundation
import SwiftClicker

@main
struct CITestRunner {
    static func main() async {
        let device = Device()
        
        do {
            try await device.connect()
            print("✅ Device connected")
            
            // Run smoke tests
            await runSmokeTests(device: device)
            
            // Run specific test scenarios
            await runRegressionTests(device: device)
            
            await device.disconnect()
            print("✅ All tests completed")
            
        } catch {
            print("❌ Test failed: \(error)")
            exit(1)
        }
    }
    
    static func runSmokeTests(device: Device) async {
        // Basic app functionality
        await device.press("home")
        await device.click(x: 540, y: 1200)  // Open app
        
        // Wait for app to load
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        // Test basic navigation
        await device.swipe(fromX: 100, fromY: 1200, toX: 900, toY: 1200)
        await device.press("back")
    }
    
    static func runRegressionTests(device: Device) async {
        // Detailed test scenarios
        // ... implement specific test cases
    }
}
```

## 📊 Performance Testing

Monitor app performance during automated interactions:

```swift
import SwiftClicker
import Foundation

class PerformanceMonitor {
    private let device = Device()
    private var startTime: Date!
    
    func runPerformanceTest() async throws {
        try await device.connect()
        
        startTime = Date()
        
        // Stress test: rapid interactions
        for i in 0..<100 {
            let x = Int.random(in: 100...900)
            let y = Int.random(in: 300...2000)
            
            await device.click(x: x, y: y)
            
            if i % 10 == 0 {
                let elapsed = Date().timeIntervalSince(startTime)
                print("Completed \(i) interactions in \(elapsed)s")
            }
        }
        
        // Memory pressure test: complex gestures
        for _ in 0..<50 {
            await device.swipe(
                fromX: Int.random(in: 100...400),
                fromY: Int.random(in: 300...1000),
                toX: Int.random(in: 500...900),
                toY: Int.random(in: 1200...2000),
                duration: Double.random(in: 0.5...2.0)
            )
        }
        
        await device.disconnect()
        
        let totalTime = Date().timeIntervalSince(startTime)
        print("Performance test completed in \(totalTime)s")
    }
}
```

## 🤖 Multi-Device Coordination

Control multiple devices simultaneously:

```swift
import SwiftClicker

class MultiDeviceController {
    private let devices: [String: Device] = [
        "phone": Device(deviceSerial: "device1"),
        "tablet": Device(deviceSerial: "emulator-5554"),
        "tv": Device(host: "192.168.1.100", port: 9008)
    ]
    
    func setupAllDevices() async throws {
        // Connect all devices in parallel
        try await withThrowingTaskGroup(of: Void.self) { group in
            for (name, device) in devices {
                group.addTask {
                    try await device.connect()
                    print("✅ Connected to \(name)")
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func coordinatedDemo() async {
        // Synchronized actions across devices
        await withTaskGroup(of: Void.self) { group in
            // Phone: Navigate through app
            group.addTask {
                await self.devices["phone"]?.swipe(fromX: 100, fromY: 1000, toX: 900, toY: 1000)
            }
            
            // Tablet: Different interaction
            group.addTask {
                await self.devices["tablet"]?.click(x: 400, y: 600)
            }
            
            // TV: Remote control simulation
            group.addTask {
                await self.devices["tv"]?.press("volume_up")
            }
        }
    }
    
    func cleanup() async {
        for device in devices.values {
            await device.disconnect()
        }
    }
}
```

## 🛠️ Development Tools

Create development utilities with SwiftClicker:

```swift
import SwiftClicker
import ArgumentParser

@main
struct AndroidController: AsyncParsableCommand {
    @Option(help: "Device serial number")
    var device: String?
    
    @Option(help: "X coordinate")
    var x: Int?
    
    @Option(help: "Y coordinate")  
    var y: Int?
    
    @Option(help: "Key to press")
    var key: String?
    
    func run() async throws {
        let androidDevice = Device(deviceSerial: device)
        try await androidDevice.connect()
        
        if let x = x, let y = y {
            await androidDevice.click(x: x, y: y)
            print("Clicked at (\(x), \(y))")
        }
        
        if let key = key {
            await androidDevice.press(key)
            print("Pressed key: \(key)")
        }
        
        await androidDevice.disconnect()
    }
}

// Usage from command line:
// swift run android-controller --x 100 --y 200
// swift run android-controller --key home
```

## 📱 App Store Connect Automation

Automate app submission testing:

```swift
import SwiftClicker

class AppSubmissionTester {
    private let device = Device()
    
    func testAppStoreFlow() async throws {
        try await device.connect()
        
        // Open Play Store
        await findAndClickPlayStore()
        
        // Search for app
        await searchForApp("YourAppName")
        
        // Test install flow
        await testInstallProcess()
        
        // Test app launch
        await testAppLaunch()
        
        await device.disconnect()
    }
    
    private func findAndClickPlayStore() async {
        // Implementation depends on device launcher
        await device.click(x: 540, y: 1800)  // App drawer
        await device.swipe(fromX: 540, fromY: 1200, toX: 540, toY: 600)  // Scroll
        // Find Play Store icon and click
    }
    
    private func searchForApp(_ appName: String) async {
        await device.click(x: 800, y: 200)   // Search button
        // Type app name (would need text input implementation)
        await device.press("search")
    }
    
    private func testInstallProcess() async {
        await device.click(x: 800, y: 800)   // Install button
        // Wait for installation
        try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
    }
    
    private func testAppLaunch() async {
        await device.click(x: 600, y: 800)   // Open button
        // Test basic app functionality
    }
}
```

## 🔧 Integration Tips

### Error Handling Best Practices

```swift
extension Device {
    func safeClick(x: Int, y: Int, retries: Int = 3) async -> Bool {
        for attempt in 1...retries {
            do {
                await self.click(x: x, y: y)
                return true
            } catch {
                print("Click attempt \(attempt) failed: \(error)")
                if attempt < retries {
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                }
            }
        }
        return false
    }
}
```

### Resource Management

```swift
class DeviceManager {
    private var device: Device?
    
    func withDevice<T>(_ operation: (Device) async throws -> T) async throws -> T {
        if device == nil {
            device = Device()
            try await device!.connect()
        }
        
        return try await operation(device!)
    }
    
    deinit {
        Task {
            await device?.disconnect()
        }
    }
}
```

These examples demonstrate how SwiftClicker can be integrated into various Swift projects for Android automation, testing, and development workflows.