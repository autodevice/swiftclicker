import Foundation
import SwiftClicker

@main
struct SwiftClickerDemo {
    static func main() async {
        print("🚀 SwiftClicker Demo - uiautomator2 Input Events")
        print("=" * 50)
        
        let device = Device(host: "127.0.0.1", port: 9008)
        
        do {
            print("📱 Connecting to device...")
            try await device.connect()
            print("✅ Connected successfully!")
            
            print("\n🎯 Testing Touch Events")
            print("-" * 30)
            
            // Test touch down, move, up sequence
            print("👆 Touch down at (100, 200)")
            try await device.touch.down(x: 100, y: 200)
            
            print("👈 Touch move to (200, 300)")
            try await device.touch.move(x: 200, y: 300)
            
            print("👆 Touch up at (200, 300)")
            try await device.touch.up(x: 200, y: 300)
            
            await device.touch.sleep(1.0)
            
            // Test simple click
            print("👆 Click at (300, 400)")
            try await device.click(x: 300, y: 400)
            
            await device.touch.sleep(1.0)
            
            // Test long press
            print("⏰ Long press at (400, 500) for 2 seconds")
            try await device.longPress(x: 400, y: 500, duration: 2.0)
            
            await device.touch.sleep(1.0)
            
            // Test swipe
            print("👋 Swipe from (100, 600) to (500, 600)")
            try await device.swipe(fromX: 100, fromY: 600, toX: 500, toY: 600, duration: 1.0)
            
            print("\n⌨️  Testing Key Events")
            print("-" * 30)
            
            // Test key presses by name
            print("🏠 Press HOME key")
            try await device.press("home")
            
            await device.touch.sleep(1.0)
            
            print("🔙 Press BACK key")
            try await device.press("back")
            
            await device.touch.sleep(1.0)
            
            // Test key presses by code
            print("🔙 Press BACK key (by code 4)")
            try await device.press(keyCode: 4)
            
            await device.touch.sleep(1.0)
            
            print("📋 Press MENU key (by code 82)")
            try await device.press(keyCode: 82)
            
            await device.touch.sleep(1.0)
            
            // Test volume keys
            print("🔊 Press VOLUME_UP")
            try await device.press("volume_up")
            
            await device.touch.sleep(0.5)
            
            print("🔉 Press VOLUME_DOWN")
            try await device.press("volume_down")
            
            print("\n✨ Demo completed successfully!")
            print("All touch and key events were sent to the device.")
            
        } catch DeviceError.connectionFailed {
            print("❌ Failed to connect to device")
            print("Make sure:")
            print("• Android device/emulator is running")
            print("• uiautomator2 server is running on port 9008")
            print("• Device is accessible at 127.0.0.1:9008")
        } catch DeviceError.notConnected {
            print("❌ Device not connected")
        } catch DeviceError.serverError(let message) {
            print("❌ Server error: \(message)")
        } catch HTTPClientError.networkError(let error) {
            print("❌ Network error: \(error.localizedDescription)")
        } catch HTTPClientError.httpError(let code, let message) {
            print("❌ HTTP error \(code): \(message)")
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
}

extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}