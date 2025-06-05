# Akiles iOS SDK

iOS SDK for integrating with [Akiles](https://akiles.app/en) access control systems. Provides session management, hardware device interaction, NFC card handling, and Bluetooth integration.

## Features

- Session management.
- Gadget control and action execution online and offline (via Bluetooth)
- NFC card scanning and updating.
- Real-time progress tracking and callbacks.

## Installation

### CocoaPods

```ruby
pod 'AkilesSDK', '~> 1.0'
```

## Usage

```swift
import AkilesSDK

let akiles = Akiles()

// Add session
let sessionID = try await akiles.addSession(token: "your-token")

// Get available gadgets
let gadgets = try await akiles.getGadgets(sessionID: sessionID)

// Execute action
await akiles.action(sessionID: sessionID, gadgetID: gadget.id, actionID: action.id, callback: callback)
```

## Example

See the complete demo application in the `example/` directory for comprehensive usage examples including session management, opening, synchronization and NFC card handling.

## Requirements

- iOS 12.0+
- Swift 5.0+
