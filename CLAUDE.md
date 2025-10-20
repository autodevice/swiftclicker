# SwiftClicker Development Context

This document provides essential context for future agents working on this Swift uiautomator2 client repository.

## Project Overview

**SwiftClicker** is a complete Swift implementation of a uiautomator2 client for Android device automation. It focuses specifically on input events (touch and key presses) and includes full server lifecycle management.

### Key Achievement
- ✅ **Fully functional** - Successfully tested with real Android emulator
- ✅ **Complete automation** - Handles server setup, JAR deployment, and cleanup
- ✅ **Production ready** - Robust error handling and resource management

## Technical Architecture

### Core Components

1. **ServerManager** (`Sources/SwiftClicker/ServerManager.swift`)
   - Handles complete uiautomator2 server lifecycle
   - Downloads JAR from GitHub releases
   - Deploys to Android device at `/data/local/tmp/u2.jar`
   - Starts server: `CLASSPATH=/data/local/tmp/u2.jar app_process / com.wetest.uia2.Main`
   - Manages port forwarding and cleanup

2. **Device** (`Sources/SwiftClicker/Device.swift`)
   - Main API class for users
   - Manages connection state and touch/key operations
   - Provides convenience methods (click, longPress, swipe)
   - Auto-detects existing servers vs. starting new ones

3. **HTTPClient** (`Sources/SwiftClicker/HTTPClient.swift`)
   - Handles HTTP/JSON-RPC communication with uiautomator2 server
   - Ping endpoint testing
   - JSON-RPC 2.0 protocol implementation

4. **TouchEvents** (`Sources/SwiftClicker/Device.swift`)
   - Fluent API for touch event chaining
   - Maps to uiautomator2 `injectInputEvent` method
   - Action constants: DOWN=0, UP=1, MOVE=2

### Communication Protocol

**uiautomator2 Server Details:**
- **Port**: 9008 (on device, forwarded to localhost:9008)
- **Protocol**: HTTP with JSON-RPC 2.0
- **Server Command**: `CLASSPATH=/data/local/tmp/u2.jar app_process / com.wetest.uia2.Main`
- **JAR Source**: https://github.com/openatx/uiautomator2/releases/download/3.4.2/u2.jar

**Key Endpoints:**
- `GET /ping` → "pong" (server health check)
- `POST /jsonrpc/0` → JSON-RPC calls

**Critical JSON-RPC Methods:**
- `injectInputEvent(action, x, y, pointer)` - Touch events
- `pressKey(keyName)` - Key press by name
- `pressKeyCode(keyCode, meta?)` - Key press by code
- `deviceInfo()` - Device information (lightweight connectivity test)

### Server Lifecycle Management

**Why This Was Critical:**
The Python uiautomator2 package handles server management automatically, but Swift clients need to do this manually. Key discoveries:

1. **JAR Deployment Required**: The 3.7MB `u2.jar` must be on the device
2. **Server Process**: Must be started as background process with specific classpath
3. **Port Forwarding**: ADB forward required for localhost access
4. **Cleanup**: Server should be stopped to free resources

**Server States:**
- `Stopped` - No server running
- `Starting` - JAR deployed, server launching
- `Ready` - Server responding to ping and JSON-RPC
- `Connected` - Swift client connected and ready for operations

## Usage Patterns

### Basic Usage
```swift
import SwiftClicker

let device = Device()
try await device.connect()  // Auto-sets up server if needed

// Touch events
await device.touch.down(x: 100, y: 200)
    .move(x: 200, y: 300)
    .up(x: 200, y: 300)

// Convenience methods
await device.click(x: 300, y: 400)
await device.longPress(x: 400, y: 500, duration: 2.0)
await device.swipe(fromX: 100, fromY: 600, toX: 500, toY: 600)

// Key events
await device.press("home")
await device.press(keyCode: 4)  // back key

// Cleanup
await device.disconnect()
```

### Advanced Usage
```swift
// Specify device serial for multiple devices
let device = Device(deviceSerial: "emulator-5554")

// Connect without auto-setup (use existing server)
try await device.connect(autoSetupServer: false)

// Manual server management
let serverManager = ServerManager(deviceSerial: "emulator-5554")
try await serverManager.setupAndStartServer()
// ... use device ...
await serverManager.stopServer()
```

## Key Implementation Details

### Error Handling Strategy
- **DeviceError.connectionFailed**: Server setup or connection issues
- **DeviceError.notConnected**: Operations attempted without connection
- **DeviceError.serverError**: JSON-RPC errors from server
- **ServerError**: Various server setup failures

### Connection Logic
1. **Quick Test**: Try ping + lightweight JSON-RPC call
2. **Auto Setup**: If enabled and no server found, full setup
3. **Retry Logic**: Multiple attempts with delays
4. **Fallback**: Detailed troubleshooting instructions

### Touch Event Mapping
```swift
// Swift API → uiautomator2 JSON-RPC
device.touch.down(x, y) → injectInputEvent(0, x, y, 0)
device.touch.move(x, y) → injectInputEvent(2, x, y, 0)  
device.touch.up(x, y) → injectInputEvent(1, x, y, 0)
```

### Key Event Mapping
```swift
// Swift API → uiautomator2 JSON-RPC
device.press("home") → pressKey("home")
device.press(keyCode: 4) → pressKeyCode(4)
```

## Development Environment

### Prerequisites
- macOS with Xcode/Swift 5.9+
- Android device/emulator with ADB access
- Network connectivity for JAR download

### Build and Test
```bash
swift build          # Build library
swift test           # Run unit tests
swift run SwiftClickerDemo  # Run demo
```

### Testing Setup
The demo (`Sources/SwiftClickerDemo/main.swift`) provides complete testing:
- Server setup verification
- All input event types
- Error handling scenarios
- Proper cleanup

## File Structure
```
SwiftClicker/
├── Package.swift                 # Swift package definition
├── README.md                     # User documentation  
├── AGENTS.md                     # Original implementation notes
├── CLAUDE.md                     # This context document
├── Sources/SwiftClicker/
│   ├── SwiftClicker.swift        # Main exports
│   ├── Device.swift              # Main API + TouchEvents
│   ├── HTTPClient.swift          # JSON-RPC communication
│   └── ServerManager.swift       # Server lifecycle
├── Sources/SwiftClickerDemo/
│   └── main.swift                # Complete demo application
└── Tests/SwiftClickerTests/
    └── SwiftClickerTests.swift   # Unit tests
```

## Common Development Tasks

### Adding New Input Methods
1. Add method to `Device` class
2. Map to appropriate JSON-RPC call in `HTTPClient`
3. Add error handling for new failure modes
4. Update demo to test new functionality

### Debugging Connection Issues
1. Check `adb devices` output
2. Test manual curl to `http://127.0.0.1:9008/ping`
3. Verify port forwarding: `adb forward --list`
4. Check device logs: `adb logcat | grep -i uiautomator`

### Server Management Debugging
1. Check JAR exists: `adb shell ls -la /data/local/tmp/u2.jar`
2. Check server process: `adb shell ps | grep uiautomator`
3. Manual server start: `adb shell 'CLASSPATH=/data/local/tmp/u2.jar app_process / com.wetest.uia2.Main'`

## Known Limitations & Future Work

### Current Limitations
- Only supports input events (no element finding/interaction)
- Single device connection at a time per Device instance
- No screenshot or UI hierarchy analysis
- Limited to basic touch/key events

### Potential Enhancements
1. **Element Selection**: XPath/CSS selector support
2. **UI Analysis**: Screenshot and element detection
3. **Multi-Device**: Concurrent device management
4. **Advanced Gestures**: Pinch, rotate, complex paths
5. **App Management**: Install, launch, manage applications

### Architecture Extension Points
- `Device` class can be extended with new method categories
- `HTTPClient` can support additional JSON-RPC methods
- `ServerManager` can handle multiple server versions
- New classes for UI analysis, element interaction, etc.

## Reference Implementation

The Python uiautomator2 package (`reference/` directory) served as the reference. Key files studied:
- `uiautomator2/core.py` - Server lifecycle management
- `uiautomator2/__init__.py` - Touch and key event implementations
- `uiautomator2/_input.py` - Input method details

## Testing Results

**Last Successful Test:** Demo completed successfully with Android emulator
- ✅ Server auto-setup and JAR deployment
- ✅ All touch events (down, move, up, click, longPress, swipe)
- ✅ All key events (home, back, menu, volume keys)
- ✅ Proper cleanup and resource management

The implementation is **production-ready** for input event automation use cases.