# SwiftClicker - uiautomator2 Swift Client

## Overview
SwiftClicker is a Swift implementation of a uiautomator2 client, focused specifically on sending input events to Android devices. This project enables touch and keypress automation from Swift applications.

## Architecture

### Core Components
1. **Device** - Main connection and management class
2. **HTTPClient** - Handles HTTP/JSON-RPC communication with uiautomator2 server
3. **TouchEvents** - Touch down, up, move event handling
4. **KeyEvents** - Keypress and key code event handling

### Communication Protocol
- Uses HTTP/JSON-RPC protocol to communicate with uiautomator2 server running on Android device
- Server typically runs on port 9008
- All input events are sent via `injectInputEvent` and `pressKey`/`pressKeyCode` JSON-RPC methods

## Input Event API Reference

### Touch Events
Based on Python implementation analysis:

```swift
// Touch action constants
ACTION_DOWN = 0
ACTION_UP = 1  
ACTION_MOVE = 2

// Touch methods
touch.down(x, y)    // Send touch down at coordinates
touch.move(x, y)    // Send touch move to coordinates  
touch.up(x, y)      // Send touch up at coordinates
```

**JSON-RPC Call:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "injectInputEvent",
  "params": [ACTION_TYPE, x, y, 0]
}
```

### Key Events

```swift
// Key press methods
press(key: String)     // Press key by name (e.g., "home", "back")
press(keyCode: Int)    // Press key by code (e.g., 4 for back)
```

**JSON-RPC Calls:**
```json
// For string keys
{
  "jsonrpc": "2.0", 
  "id": 1,
  "method": "pressKey",
  "params": ["home"]
}

// For key codes
{
  "jsonrpc": "2.0",
  "id": 1, 
  "method": "pressKeyCode",
  "params": [4]
}
```

## Implementation Plan

1. **HTTP Client Setup** - Basic HTTP communication with device
2. **Device Connection** - Connect to uiautomator2 server on Android device
3. **Touch Events** - Implement touch down/up/move via injectInputEvent
4. **Key Events** - Implement key presses via pressKey/pressKeyCode
5. **Demo Application** - Example showing touch and keypress automation

## Device Setup Requirements

- Android device with uiautomator2 server running
- Device accessible via ADB or network
- Server typically running on port 9008
- Device coordinates need to be converted from relative to absolute

## Example Usage (Planned)

```swift
let device = Device(host: "localhost", port: 9008)
await device.connect()

// Touch events
await device.touch.down(x: 100, y: 200)
await device.touch.move(x: 150, y: 250) 
await device.touch.up(x: 150, y: 250)

// Key events
await device.press("home")
await device.press(keyCode: 4) // back key
```