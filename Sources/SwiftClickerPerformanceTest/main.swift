import Foundation
import SwiftClicker

@main
struct PerformanceTest {
    static func main() async throws {
        print("🚀 SwiftClicker Performance Test")
        print("================================")
        
        let device = Device()
        
        // Connect to device
        print("📱 Connecting to device...")
        let connectStart = CFAbsoluteTimeGetCurrent()
        try await device.connect()
        let connectTime = CFAbsoluteTimeGetCurrent() - connectStart
        print("✅ Connected in \(String(format: "%.3f", connectTime))s")
        
        print("\n⏱️  Measuring tap performance...")
        
        // Warm up with a few taps
        print("🔥 Warming up...")
        for _ in 0..<3 {
            try await device.click(x: 500, y: 1000)
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }
        
        // Measure single tap times
        print("\n📊 Single tap measurements:")
        var singleTapTimes: [Double] = []
        
        for i in 1...10 {
            let start = CFAbsoluteTimeGetCurrent()
            try await device.click(x: 500, y: 1000)
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            singleTapTimes.append(elapsed)
            print("   Tap #\(i): \(String(format: "%.3f", elapsed * 1000))ms")
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2s delay
        }
        
        // Measure rapid tap sequence
        print("\n⚡ Rapid tap sequence (10 taps):")
        let rapidStart = CFAbsoluteTimeGetCurrent()
        for i in 1...10 {
            try await device.click(x: 500 + (i * 10), y: 1000)
        }
        let rapidTotal = CFAbsoluteTimeGetCurrent() - rapidStart
        print("   Total time: \(String(format: "%.3f", rapidTotal * 1000))ms")
        print("   Average per tap: \(String(format: "%.3f", (rapidTotal * 1000) / 10))ms")
        
        // Measure different input types
        print("\n🎯 Different input type comparisons:")
        
        // Touch sequence
        let touchStart = CFAbsoluteTimeGetCurrent()
        try await device.touch.down(x: 300, y: 800)
            .move(x: 400, y: 800)
            .up(x: 400, y: 800)
        let touchTime = CFAbsoluteTimeGetCurrent() - touchStart
        print("   Touch sequence: \(String(format: "%.3f", touchTime * 1000))ms")
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Long press
        let longPressStart = CFAbsoluteTimeGetCurrent()
        try await device.longPress(x: 600, y: 800, duration: 0.5)
        let longPressTime = CFAbsoluteTimeGetCurrent() - longPressStart
        print("   Long press (0.5s): \(String(format: "%.3f", longPressTime * 1000))ms")
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Swipe
        let swipeStart = CFAbsoluteTimeGetCurrent()
        try await device.swipe(fromX: 200, fromY: 1200, toX: 800, toY: 1200)
        let swipeTime = CFAbsoluteTimeGetCurrent() - swipeStart
        print("   Swipe: \(String(format: "%.3f", swipeTime * 1000))ms")
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Key press
        let keyStart = CFAbsoluteTimeGetCurrent()
        try await device.press("back")
        let keyTime = CFAbsoluteTimeGetCurrent() - keyStart
        print("   Key press: \(String(format: "%.3f", keyTime * 1000))ms")
        
        // Calculate statistics
        print("\n📈 Single Tap Statistics:")
        let avgSingle = singleTapTimes.reduce(0, +) / Double(singleTapTimes.count)
        let minSingle = singleTapTimes.min() ?? 0
        let maxSingle = singleTapTimes.max() ?? 0
        
        print("   Average: \(String(format: "%.3f", avgSingle * 1000))ms")
        print("   Minimum: \(String(format: "%.3f", minSingle * 1000))ms")
        print("   Maximum: \(String(format: "%.3f", maxSingle * 1000))ms")
        
        // Calculate throughput
        let rapidThroughput = 10.0 / rapidTotal
        print("\n🔥 Throughput:")
        print("   Rapid taps: \(String(format: "%.1f", rapidThroughput)) taps/second")
        
        // Disconnect
        print("\n🔌 Disconnecting...")
        await device.disconnect()
        print("✅ Test completed successfully!")
    }
}