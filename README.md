# SwiftClicker

A complete Swift client for uiautomator2 that enables touch and keypress automation on Android devices. **Zero configuration required** - SwiftClicker automatically handles server setup and management.

## ✨ Features

- 🎯 **Touch Events**: Send touch down, up, move events with fluent chaining
- ⌨️ **Key Events**: Send key presses by name or key code  
- 🤖 **Automatic Setup**: Auto-downloads and deploys uiautomator2 server
- 🚀 **Async/Await**: Modern Swift concurrency support
- 📱 **Device Management**: Complete server lifecycle management
- 🔧 **Zero Config**: Works out of the box with any Android device/emulator
- 🛡️ **Robust**: Comprehensive error handling and recovery

## 🚀 Quick Start

### 1. Install SwiftClicker

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/swiftclicker.git", from: "1.0.0")
]
```

Or add via Xcode: **File → Add Package Dependencies** → Enter repository URL

### 2. Basic Usage

```swift
import SwiftClicker

// Simple setup - everything is automatic!
let device = Device()
try await device.connect()  // Auto-sets up server if needed

// Touch events with fluent chaining
await device.touch.down(x: 100, y: 200)
    .move(x: 200, y: 300)
    .sleep(0.1)
    .up(x: 200, y: 300)

// Convenient gesture methods
await device.click(x: 300, y: 400)
await device.longPress(x: 400, y: 500, duration: 2.0)
await device.swipe(fromX: 100, fromY: 600, toX: 500, toY: 600)

// Key events
await device.press("home")
await device.press("back")
await device.press(keyCode: 4)  // back key

// Get device dimensions
if let dimensions = device.getDimensions() {
    print("Device size: \(dimensions.width)x\(dimensions.height)")
}

// Always cleanup when done
await device.disconnect()
```

### 3. Try the Demo

```bash
git clone <repository-url>
cd swiftclicker
swift run SwiftClickerDemo
```

The demo will automatically set up the server and demonstrate all functionality!

## 📋 Prerequisites

### Essential Requirements
- **macOS** with Swift 5.9+ (Xcode 15+)
- **Android device or emulator** connected via ADB
- **Network connection** for initial server download (3.7MB, one-time)

### Quick Setup Check
```bash
# Verify Swift
swift --version

# Verify Android device
adb devices
# Should show: device (not offline)

# That's it! SwiftClicker handles the rest automatically
```

## 📚 Complete API Reference

### Device Connection

```swift
// Basic connection (auto-detects and sets up server)
let device = Device()
try await device.connect()

// Advanced: specify device for multi-device setups
let device = Device(deviceSerial: "emulator-5554")
try await device.connect()

// Connect to existing server only (no auto-setup)
try await device.connect(autoSetupServer: false)
```

### Touch Events

```swift
// Individual touch events
await device.touch.down(x: 100, y: 200)
await device.touch.move(x: 150, y: 250)  
await device.touch.up(x: 150, y: 250)

// Fluent chaining with timing
await device.touch.down(x: 100, y: 200)
    .sleep(0.1)                    // Wait 100ms
    .move(x: 150, y: 250)
    .sleep(0.05)
    .up(x: 150, y: 250)

// Convenience methods
await device.click(x: 300, y: 400)                              // Simple tap
await device.longPress(x: 400, y: 500, duration: 2.0)          // 2-second press
await device.swipe(fromX: 100, fromY: 600, toX: 500, toY: 600) // Swipe gesture
```

### Key Events

```swift
// By key name (recommended)
await device.press("home")
await device.press("back") 
await device.press("menu")
await device.press("volume_up")
await device.press("volume_down")
await device.press("power")

// By key code (Android key codes)
await device.press(keyCode: 3)    // home
await device.press(keyCode: 4)    // back
await device.press(keyCode: 82)   // menu
await device.press(keyCode: 24)   // volume up
await device.press(keyCode: 25)   // volume down
await device.press(keyCode: 26)   // power
```

### Device Information

```swift
// Get device screen dimensions (automatically fetched on connect)
if let dimensions = device.getDimensions() {
    print("Screen size: \(dimensions.width)x\(dimensions.height)")
    
    // Use dimensions for relative positioning
    let centerX = dimensions.width / 2
    let centerY = dimensions.height / 2
    await device.click(x: centerX, y: centerY)
} else {
    print("Dimensions not available - ensure device is connected")
}
```

### Error Handling

```swift
do {
    let device = Device()
    try await device.connect()
    
    await device.click(x: 100, y: 100)
    
    await device.disconnect()
    
} catch DeviceError.connectionFailed {
    print("Could not connect - check device and ADB")
} catch DeviceError.serverError(let message) {
    print("Server error: \(message)")
} catch {
    print("Unexpected error: \(error)")
}
```

## 🔧 Advanced Usage

### Multi-Device Support

```swift
// Control multiple devices simultaneously
let phone = Device(deviceSerial: "device1")
let tablet = Device(deviceSerial: "emulator-5554")

try await phone.connect()
try await tablet.connect()

// Perform different actions on each device
await phone.click(x: 100, y: 100)
await tablet.swipe(fromX: 0, fromY: 500, toX: 1000, toY: 500)

await phone.disconnect()
await tablet.disconnect()
```

### Manual Server Management

```swift
// For advanced use cases where you need server control
let serverManager = ServerManager(deviceSerial: "emulator-5554")
try await serverManager.setupAndStartServer()

// Use device with existing server
let device = Device(deviceSerial: "emulator-5554")
try await device.connect(autoSetupServer: false)

// ... perform operations ...

await device.disconnect()
await serverManager.stopServer()
```

### Custom Connection Parameters

```swift
// Connect to non-standard host/port
let device = Device(host: "192.168.1.100", port: 9008)
try await device.connect()
```

## 🛠️ How It Works

SwiftClicker provides **complete automation** of the uiautomator2 setup process:

1. **Auto-Detection**: Checks if uiautomator2 server is already running
2. **JAR Download**: Downloads uiautomator2 JAR from GitHub releases (one-time)
3. **Device Deployment**: Pushes JAR to Android device via ADB
4. **Server Startup**: Launches uiautomator2 server process on device
5. **Port Forwarding**: Sets up ADB port forwarding for localhost access
6. **Connection Verification**: Tests connectivity and functionality
7. **Ready to Use**: Provides simple API for touch and key events
8. **Cleanup**: Properly stops server and frees resources

**No manual setup required** - everything is automatic!

## 🧪 Testing Your Setup

### Quick Verification
```bash
# Clone and run the demo
git clone <repository-url>
cd swiftclicker
swift run SwiftClickerDemo

# Should output:
# ✅ Connected to device
# ✅ Touch events working
# ✅ Key events working
# ✅ Demo completed successfully
```

### Manual Testing
```swift
// Minimal test in your own code
import SwiftClicker

let device = Device()
try await device.connect()
await device.click(x: 100, y: 100)  // Should tap the screen
await device.press("home")           // Should go to home screen
await device.disconnect()
```

## 🐛 Troubleshooting

### Connection Issues

**Problem**: `DeviceError.connectionFailed`

**Solutions**:
1. Check device connection: `adb devices` (should show "device", not "offline")
2. Ensure device is unlocked and accessible
3. Try restarting ADB: `adb kill-server && adb start-server`
4. Check network connectivity for JAR download

**Problem**: "Server not ready"

**Solutions**:
1. Device may need accessibility permissions for uiautomator2
2. Try manual cleanup: `adb shell pkill -f uiautomator`
3. Restart device/emulator if issues persist

### Development Issues

**Problem**: Build failures

**Solutions**:
1. Ensure Swift 5.9+ is installed
2. Clean build: `rm -rf .build && swift build`
3. Check Xcode version compatibility

**Problem**: Touch events not working

**Solutions**:
1. Verify screen coordinates are within device bounds
2. Check device orientation (coordinates may be rotated)
3. Ensure device screen is unlocked and interactive

### Getting Help

1. **Run the demo**: `swift run SwiftClickerDemo` - provides comprehensive testing
2. **Check documentation**: See `DEVELOPMENT.md` for detailed troubleshooting
3. **Enable debug mode**: See source code for debugging options

## 🔍 Common Key Codes Reference

| Key | Code | String Name |
|-----|------|-------------|
| Back | 4 | "back" |
| Home | 3 | "home" |
| Menu | 82 | "menu" |
| Volume Up | 24 | "volume_up" |
| Volume Down | 25 | "volume_down" |
| Power | 26 | "power" |
| Enter | 66 | "enter" |
| Delete | 67 | "delete" |
| Search | 84 | "search" |
| Camera | 27 | "camera" |

## ✅ Requirements

### System Requirements
- **macOS** 12+ with Xcode 15+ (Swift 5.9+)
- **Android** device or emulator (API 19+, Android 4.4+)
- **ADB** access to device
- **Network connection** for initial setup

### Supported Android Versions
- ✅ **Android 4.4+** (API 19+)
- ✅ **All architectures** (ARM, x86, x86_64)
- ✅ **Physical devices and emulators**

## 📄 License

MIT License - see LICENSE file for details.

---

**SwiftClicker** provides the easiest way to automate Android input events from Swift. No complex setup, no manual configuration - just import and use! 🚀