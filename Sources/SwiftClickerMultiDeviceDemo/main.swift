import Foundation
import SwiftClicker

@main
struct MultiDeviceDemo {
    static func main() async throws {
        print("🚀 SwiftClicker Multi-Device Demo")
        print("==================================")
        
        // Check available devices first
        print("📱 Checking available devices...")
        let devicesOutput = try await runCommand("adb", args: ["devices"])
        print(devicesOutput)
        
        let deviceLines = devicesOutput.components(separatedBy: "\n")
            .filter { $0.contains("\tdevice") }
        
        guard deviceLines.count >= 2 else {
            print("❌ Need at least 2 devices connected")
            print("   Connect more devices or start additional emulators")
            return
        }
        
        let deviceSerials = deviceLines.compactMap { line -> String? in
            let parts = line.components(separatedBy: "\t")
            return parts.first?.trimmingCharacters(in: .whitespaces)
        }
        
        print("✅ Found \(deviceSerials.count) devices:")
        for (index, serial) in deviceSerials.enumerated() {
            print("   Device \(index + 1): \(serial)")
        }
        
        // Take first two devices for demo
        let device1Serial = deviceSerials[0]
        let device2Serial = deviceSerials[1]
        
        print("\n🔧 Setting up devices...")
        
        // Create device instances (ports will be allocated automatically)
        let device1 = Device(deviceSerial: device1Serial)
        let device2 = Device(deviceSerial: device2Serial)
        
        print("   Device 1 (\(device1Serial)) - Auto-allocated port")
        print("   Device 2 (\(device2Serial)) - Auto-allocated port")
        
        // Connect both devices in parallel
        print("\n🔌 Connecting devices in parallel...")
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await device1.connect()
                    print("✅ Device 1 connected successfully")
                } catch {
                    print("❌ Device 1 failed to connect: \(error)")
                }
            }
            
            group.addTask {
                do {
                    try await device2.connect()
                    print("✅ Device 2 connected successfully")
                } catch {
                    print("❌ Device 2 failed to connect: \(error)")
                }
            }
        }
        
        print("\n🎯 Performing parallel operations...")
        
        // Perform different operations on each device simultaneously
        await withTaskGroup(of: Void.self) { group in
            // Device 1: Tap sequence in top half
            group.addTask {
                do {
                    print("📱 Device 1: Starting tap sequence...")
                    for i in 1...5 {
                        try await device1.click(x: 200 + (i * 50), y: 300)
                        print("   Device 1: Tap \(i) completed")
                        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                    }
                    print("✅ Device 1: Tap sequence completed")
                } catch {
                    print("❌ Device 1 operation failed: \(error)")
                }
            }
            
            // Device 2: Swipe sequence in bottom half
            group.addTask {
                do {
                    print("📱 Device 2: Starting swipe sequence...")
                    for i in 1...3 {
                        let startX = 100 + (i * 100)
                        let endX = startX + 200
                        try await device2.swipe(fromX: startX, fromY: 800, toX: endX, toY: 800)
                        print("   Device 2: Swipe \(i) completed")
                        try await Task.sleep(nanoseconds: 700_000_000) // 0.7s
                    }
                    print("✅ Device 2: Swipe sequence completed")
                } catch {
                    print("❌ Device 2 operation failed: \(error)")
                }
            }
        }
        
        // Key press test on both devices
        print("\n⌨️  Testing key presses...")
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await device1.press("home")
                    print("✅ Device 1: Home key pressed")
                } catch {
                    print("❌ Device 1 key press failed: \(error)")
                }
            }
            
            group.addTask {
                do {
                    try await device2.press("back")
                    print("✅ Device 2: Back key pressed")
                } catch {
                    print("❌ Device 2 key press failed: \(error)")
                }
            }
        }
        
        // Performance comparison
        print("\n⏱️  Performance comparison...")
        
        let device1Start = CFAbsoluteTimeGetCurrent()
        do {
            try await device1.click(x: 400, y: 500)
        } catch {
            print("❌ Device 1 performance test failed")
        }
        let device1Time = CFAbsoluteTimeGetCurrent() - device1Start
        
        let device2Start = CFAbsoluteTimeGetCurrent()
        do {
            try await device2.click(x: 400, y: 500)
        } catch {
            print("❌ Device 2 performance test failed")
        }
        let device2Time = CFAbsoluteTimeGetCurrent() - device2Start
        
        print("   Device 1 tap time: \(String(format: "%.3f", device1Time * 1000))ms")
        print("   Device 2 tap time: \(String(format: "%.3f", device2Time * 1000))ms")
        
        // Cleanup
        print("\n🧹 Cleaning up...")
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await device1.disconnect()
                print("✅ Device 1 disconnected")
            }
            
            group.addTask {
                await device2.disconnect()
                print("✅ Device 2 disconnected")
            }
        }
        
        print("\n🎉 Multi-device demo completed successfully!")
        print("   Both devices operated independently with separate ports")
        print("   Parallel operations executed simultaneously")
    }
    
    private static func runCommand(_ command: String, args: [String]) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            let pipe = Pipe()
            
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = [command] + args
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                process.waitUntilExit()
                continuation.resume(returning: output)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}