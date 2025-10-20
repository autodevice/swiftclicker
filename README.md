# SwiftClicker 

A Swift client for uiautomator2 that enables touch and keypress automation on Android devices.

## Features

- 🎯 **Touch Events**: Send touch down, up, move events
- ⌨️ **Key Events**: Send key presses by name or key code  
- 🔄 **Chaining**: Fluent API for chaining touch events
- 🚀 **Async/Await**: Modern Swift concurrency support
- 📱 **Device Management**: Simple connection handling

## Quick Start

```swift
import SwiftClicker

let device = Device(host: "127.0.0.1", port: 9008)
try await device.connect()

// Touch events
await device.touch.down(x: 100, y: 200)
    .move(x: 200, y: 300)
    .up(x: 200, y: 300)

// Simple click
await device.click(x: 300, y: 400)

// Key events  
await device.press("home")
await device.press(keyCode: 4) // back key
```

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/swiftclicker.git", from: "1.0.0")
]
```

## Setup

### 1. Android Device/Emulator

Ensure you have an Android device or emulator running:

```bash
# Check connected devices
adb devices
```

### 2. uiautomator2 Server

The Swift client communicates with a uiautomator2 server running on the device. 

**Option A: Using Python uiautomator2**
```bash
pip install uiautomator2
python3 -c "import uiautomator2 as u2; u2.connect().server.start()"
```

**Option B: Manual server setup**
- Deploy the uiautomator2 JAR to the device
- Start the server on port 9008

### 3. Verify Connection

```bash
curl http://127.0.0.1:9008/ping
# Should return: pong
```

## API Reference

### Device Connection

```swift
let device = Device(host: "127.0.0.1", port: 9008)
try await device.connect()
```

### Touch Events

```swift
// Individual touch events
await device.touch.down(x: 100, y: 200)
await device.touch.move(x: 150, y: 250)  
await device.touch.up(x: 150, y: 250)

// Chained touch events
await device.touch.down(x: 100, y: 200)
    .sleep(0.1)
    .move(x: 150, y: 250)
    .sleep(0.1) 
    .up(x: 150, y: 250)

// Convenience methods
await device.click(x: 300, y: 400)
await device.longPress(x: 400, y: 500, duration: 2.0)
await device.swipe(fromX: 100, fromY: 600, toX: 500, toY: 600)
```

### Key Events

```swift
// By key name
await device.press("home")
await device.press("back") 
await device.press("volume_up")

// By key code
await device.press(keyCode: 4)    // back
await device.press(keyCode: 82)   // menu
await device.press(keyCode: 24)   // volume up
```

## Demo

Run the included demo:

```bash
swift run SwiftClickerDemo
```

This will demonstrate various touch and key events if a device is connected.

## Development

### Build

```bash
swift build
```

### Test

```bash
swift test
```

### Common Key Codes

| Key | Code | Name |
|-----|------|------|
| Back | 4 | "back" |
| Home | 3 | "home" |
| Menu | 82 | "menu" |
| Volume Up | 24 | "volume_up" |
| Volume Down | 25 | "volume_down" |
| Power | 26 | "power" |

## Troubleshooting

### Connection Issues

1. **Check device connection**: `adb devices`
2. **Verify server running**: `curl http://127.0.0.1:9008/ping`
3. **Check port forwarding**: `adb forward tcp:9008 tcp:9008`
4. **Restart uiautomator2 server** if needed

### Permission Issues

Make sure the uiautomator2 service has accessibility permissions on the device.

## License

MIT License - see LICENSE file for details.