# AkilesSDK Documentation

Welcome to the AkilesSDK for iOS - your gateway to seamless integration with Akiles smart access control devices.

## What is AkilesSDK?

AkilesSDK is a powerful iOS framework that enables your applications to communicate with Akiles devices, manage access control systems, and provide secure, convenient user experiences. Built with modern Swift async/await patterns and full Objective-C compatibility, it's designed to integrate seamlessly into any iOS project.

## Why Choose AkilesSDK?

- **🔒 Secure**: Built-in security best practices and encrypted communication with Akiles devices
- **🚀 Fast**: Optimized for quick device discovery and responsive action execution
- **🔄 Reliable**: Multiple communication methods with automatic fallback mechanisms
- **📱 Native**: Designed specifically for iOS with proper permission handling and lifecycle management
- **🛠 Developer Friendly**: Clear APIs, comprehensive error handling, and extensive documentation
- **🔧 Flexible**: Support for both modern Swift async/await and traditional completion handlers

## Quick Start Guide

### 1. Setup

Import the framework in your Swift files:
```swift
import AkilesSDK
```

Or in Objective-C:
```objc
#import <AkilesSDK/AkilesSDK.h>
```

### 2. Initialize

Create an Akiles instance:
```swift
let akiles = Akiles()
```

### 3. Authenticate

Add a session token from the Akiles API:
```swift
do {
    let sessionId = try await akiles.addSession(token: "your-session-token")
    print("Session added: \(sessionId)")
} catch {
    print("Authentication failed: \(error)")
}
```

### 4. Discover Devices

Find available Akiles devices:
```swift
let gadgets = try await akiles.getGadgets(sessionID: sessionId)
for gadget in gadgets {
    print("Device: \(gadget.name)")
    for action in gadget.actions {
        print("  Action: \(action.name)")
    }
}
```

### 5. Execute Actions

Perform actions on devices:
```swift
let options = ActionOptions()
options.useBluetooth = true
options.useInternet = true

let callback = MyActionCallback() // Your callback implementation

await akiles.action(
    sessionID: sessionId,
    gadgetID: gadgets[0].id,
    actionID: gadgets[0].actions[0].id,
    options: options,
    callback: callback
)
```

## Core Concepts

### Sessions
Sessions represent authenticated connections to the Akiles API. Each session provides access to a specific set of devices and permissions.

### Devices (Gadgets)
Gadgets are Akiles devices that can perform specific actions. Each gadget has:
- A unique identifier
- A human-readable name  
- A list of available actions

### Actions
Actions are operations that can be performed on devices, such as:
- Opening doors
- Controlling lights
- Managing access points
- Custom automation functions

### Communication Methods
The SDK supports multiple communication methods:
- **Bluetooth**: Direct device communication for nearby devices
- **Internet**: Communication through the Akiles API for remote access
- **Automatic Fallback**: The SDK automatically tries multiple methods for maximum reliability

## Common Use Cases

### Building Access Control
```swift
// Open a door
await openDoor(gadgetId: "door-123", actionId: "open")

// Check access permissions
let schedule = gadget.schedule
if schedule.isAccessAllowed(at: Date()) {
    // Proceed with action
}
```

### NFC Integration
```swift
// Scan and update NFC cards
let card = try await akiles.scanCard()
if !card.isAkilesCard() {
    try await card.update()
    print("Card updated for Akiles compatibility")
}
```

### Device Management
```swift
// Discover nearby devices
try await akiles.scan { hardware in
    print("Found: \(hardware.name)")
}

// Synchronize device configuration
try await akiles.sync(
    sessionID: sessionId,
    hardwareID: hardware.id,
    callback: MySyncCallback()
)
```

## Best Practices

### Error Handling
Always handle errors appropriately:
```swift
do {
    try await performAction()
} catch let error as NSError {
    switch ErrorCode(rawValue: error.code) {
    case .bluetoothPermissionNotGranted:
        // Guide user to enable Bluetooth permissions
    case .internetNotAvailable:
        // Show offline message
    case .deviceNotFound:
        // Suggest moving closer to device
    default:
        // Handle other errors
    }
}
```

### Permissions
Request permissions proactively:
```swift
let options = ActionOptions()
options.requestBluetoothPermission = true
options.requestLocationPermission = true
```

### Cancellation
Use cancellable operations for better UX:
```swift
let cancellable = akiles.scan(callback) { error in
    // Handle completion
}

// Later, if needed:
cancellable.cancel()
```

### Background Handling
The SDK handles iOS background modes appropriately, but consider your app's lifecycle:
- Cache session data for offline scenarios
- Refresh sessions when returning to foreground
- Handle permission changes gracefully

## Support and Resources

- **API Reference**: Complete documentation for all classes and methods
- **Sample Code**: Working examples for common integration scenarios  
- **Error Codes**: Comprehensive error handling guide
- **Best Practices**: Recommended patterns for production apps

## What's Next?

- Explore the complete API reference
- Check out the example implementations
- Review the error handling guide
- Learn about advanced features like scheduling and device synchronization

Ready to get started? Begin with the ``Akiles`` class documentation.