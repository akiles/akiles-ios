/**
 * @file AkilesSDK.h
 * @brief Main header file for the AkilesSDK
 *
 * The AkilesSDK provides a comprehensive interface for iOS applications to interact
 * with Akiles. This includes online and offline open, NFC card operations and session management.
 *
 * ## Key Features
 * - Session management with the Akiles API
 * - Opening Akiles devices online and offline
 * - NFC card scanning and updating
 *
 * ## Getting Started
 * 1. Import the framework: `#import <AkilesSDK/AkilesSDK.h>`
 * 2. Create an Akiles instance: `Akiles *akiles = [[Akiles alloc] init];`
 * 3. Add a session token from the Akiles API
 * 4. Discover and interact with Akiles devices
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enums

/**
 * Status values for internet-based action operations via the Akiles API.
 *
 * These status values are reported during actions that communicate
 * with Akiles devices through the Akiles API over the internet.
 */
typedef NS_ENUM(NSInteger, ActionInternetStatus) {
    /** The action is being executed via the Akiles API */
    ActionInternetStatusExecutingAction = 0,
    /** The SDK is acquiring the device's current location */
    ActionInternetStatusAcquiringLocation = 1,
    /** Waiting for the device to be within the required radius of the target */
    ActionInternetStatusWaitingForLocationInRadius = 2
};

/**
 * Status values for Bluetooth-based action operations with Akiles devices.
 *
 * These status values are reported during actions that communicate
 * directly with Akiles devices via Bluetooth.
 */
typedef NS_ENUM(NSInteger, ActionBluetoothStatus) {
    /** Scanning for nearby Akiles devices via Bluetooth */
    ActionBluetoothStatusScanning = 0,
    /** Connecting to an Akiles device via Bluetooth */
    ActionBluetoothStatusConnecting = 1,
    /** Synchronizing the Akiles device configuration */
    ActionBluetoothStatusSyncingDevice = 2,
    /** Synchronizing with the Akiles API */
    ActionBluetoothStatusSyncingServer = 3,
    /** Executing the action on the Akiles device */
    ActionBluetoothStatusExecutingAction = 4
};

/**
 * Status values for Akiles device synchronization operations.
 *
 * These status values are reported during device synchronization
 * operations that update device configurations and firmware.
 */
typedef NS_ENUM(NSInteger, SyncStatus) {
    /** Scanning for the target Akiles device */
    SyncStatusScanning = 0,
    /** Connecting to the Akiles device */
    SyncStatusConnecting = 1,
    /** Synchronizing the device configuration */
    SyncStatusSyncingDevice = 2,
    /** Synchronizing with the Akiles API */
    SyncStatusSyncingServer = 3
};

/**
 * Error codes for Akiles oeprations.
 */
typedef NS_ENUM(NSInteger, ErrorCode) {
    ErrorCodeInternal = 0,                                  // Something went wrong internally.
    ErrorCodeInvalidParam = 1,                              // Invalid parameter.
    ErrorCodePermissionDenied = 2,                          // No permission for the requested action.
    ErrorCodeInvalidSession = 11,                           // The session token is invalid.
    ErrorCodeAllCommMethodsFailed = 12,                     // All communication methods failed.
    ErrorCodeInternetNotAvailable = 13,                     // Phone has no internet access.
    ErrorCodeInternetDeviceOffline = 14,                    // Server could not reach device.
    ErrorCodeInternetLocationOutOfRadius = 15,              // Outside the maximum radius.
    ErrorCodeInternetNotPermitted = 16,                     // Internet communication method not accepted.
    ErrorCodeBluetoothDeviceNotFound = 3,                   // Device not within Bluetooth range.
    ErrorCodeBluetoothDisabled = 4,                         // Bluetooth turned off.
    ErrorCodeBluetoothNotAvailable = 5,                     // No Bluetooth support.
    ErrorCodeBluetoothPermissionNotGranted = 6,             // Bluetooth permission not granted.
    ErrorCodeTimeout = 8,                                   // Operation timed out.
    ErrorCodeCanceled = 9,                                  // Operation canceled.
    ErrorCodeNFCReadError = 10,                             // NFC read error.
    ErrorCodeLocationDisabled = 17,                         // Location Disabled.
    ErrorCodeLocationNotAvailable = 18,                     // Location not available.
    ErrorCodeLocationPermissionNotGranted = 19,             // Location permission not granted.
    ErrorCodeLocationFailed = 20,                           // Failed to acquire location.
    ErrorCodeNfcNotAvailable = 22,                          // NFC is not available on device.
    ErrorCodeBluetoothPermissionNotGrantedPermanently = 23, // Bluetooth permission is permanently denied.
    ErrorCodeLocationPermissionNotGrantedPermanently = 24,  // Location permission is permanently denied.
};

/// Converts ActionInternetStatus to UPPER_CASE_WITH_UNDERSCORES string.
FOUNDATION_EXPORT NSString *NSStringFromActionInternetStatus(ActionInternetStatus status);

/// Converts ActionBluetoothStatus to UPPER_CASE_WITH_UNDERSCORES string.
FOUNDATION_EXPORT NSString *NSStringFromActionBluetoothStatus(ActionBluetoothStatus status);

/// Converts SyncStatus to UPPER_CASE_WITH_UNDERSCORES string.
FOUNDATION_EXPORT NSString *NSStringFromSyncStatus(SyncStatus status);

/// Converts ErrorCode to UPPER_CASE_WITH_UNDERSCORES string.
FOUNDATION_EXPORT NSString *NSStringFromErrorCode(ErrorCode code);

FOUNDATION_EXPORT NSDictionary *NSDictionaryFromNSError(NSError *error);

#pragma - Interfaces

/**
 * Represents an Akiles device that can be discovered and synchronized.
 *
 * Hardware objects contain information about physical Akiles devices
 * that can be communicated with via Bluetooth or other protocols.
 */
@interface Hardware : NSObject

/** Unique identifier for this Akiles device */
@property (nonatomic, strong) NSString *id;

/** Human-readable name of the Akiles device */
@property (nonatomic, strong) NSString *name;

/** Product identifier indicating the type of Akiles device */
@property (nonatomic, strong) NSString *productId;

/** Revision identifier for the device firmware/hardware version */
@property (nonatomic, strong) NSString *revisionId;

/** Array of session IDs that have access to this device */
@property (nonatomic, strong) NSArray<NSString *> *sessions;

@end

/**
 * Represents an action that can be performed on an Akiles device.
 *
 * Actions are specific operations like opening doors, turning on lights,
 * or other automated functions that Akiles devices can perform.
 */
@interface Action : NSObject

/** Unique identifier for this action */
@property (nonatomic, strong) NSString *id;

/** Human-readable name describing what this action does */
@property (nonatomic, strong) NSString *name;

@end

/**
 * Represents an Akiles device (gadget) that can perform actions.
 *
 * Gadgets are Akiles devices that have been configured with specific
 * actions and are accessible through the Akiles API. They represent
 * the functional interface to physical devices.
 */
@interface Gadget : NSObject

/** Unique identifier for this Akiles device */
@property (nonatomic, strong) NSString *id;

/** Human-readable name of the Akiles device */
@property (nonatomic, strong) NSString *name;

/** Array of actions that can be performed on this device */
@property (nonatomic, strong) NSArray<Action *> *actions;

@end

/**
 * Configuration options for action execution.
 *
 * These options control how the SDK attempts to communicate with
 * Akiles devices and what permissions it should request.
 */
@interface ActionOptions : NSObject

/** Whether to request Bluetooth permission if not already granted */
@property (nonatomic) bool requestBluetoothPermission;

/** Whether to request location permission if not already granted */
@property (nonatomic) bool requestLocationPermission;

/** Whether to attempt communication via the Akiles API (requires internet) */
@property (nonatomic) bool useInternet;

/** Whether to attempt communication via Bluetooth */
@property (nonatomic) bool useBluetooth;

/**
 * Creates an ActionOptions instance with recommended default values.
 * @return ActionOptions instance with sensible defaults
 */
+ (ActionOptions *)initWithDefaults;
@end

#pragma mark - Protocol Definitions

/**
 * Protocol for an operation that can be cancelled.
 */
@protocol Cancellable<NSObject>

/**
 * Cancels the operation.
 */
- (void)cancel;

@end

/**
 * Protocol for receiving Akiles device discovery callbacks during scanning operations.
 *
 * Implement this protocol to receive notifications when Akiles devices
 * are discovered during Bluetooth scanning operations.
 */
@protocol ScanCallback <NSObject>

/**
 * Called when an Akiles device is discovered during scanning.
 * @param info Information about the discovered Akiles device
 */
- (void)onDiscover:(Hardware *)info;

@end

/**
 * Protocol for receiving callbacks during Akiles device action execution.
 *
 * Implement this protocol to receive status updates, progress information,
 * and completion notifications during action execution on Akiles devices.
 */
@protocol ActionCallback <NSObject>

/**
 * Called when the action completes successfully
 */
- (void)onSuccess;

/**
 * Called when the action fails with an error
 * @param error The error that occurred during action execution
 */
- (void)onError:(NSError *)error;

/**
 * Called to report status updates for Akiles API-based operations
 * @param status The current status of the internet operation
 */
- (void)onInternetStatus:(ActionInternetStatus)status;

/**
 * Called when the Akiles API portion of the action completes successfully
 */
- (void)onInternetSuccess;

/**
 * Called when the Akiles API portion of the action fails
 * @param error The error that occurred during the internet operation
 */
- (void)onInternetError:(NSError *)error;

/**
 * Called to report status updates for Bluetooth-based operations
 * @param status The current status of the Bluetooth operation
 */
- (void)onBluetoothStatus:(ActionBluetoothStatus)status;

/**
 * Called to report progress updates for Bluetooth operations
 * @param percent Progress as a percentage (0.0 to 100.0)
 */
- (void)onBluetoothStatusProgress:(float)percent;

/**
 * Called when the Bluetooth portion of the action completes successfully
 */
- (void)onBluetoothSuccess;

/**
 * Called when the Bluetooth portion of the action fails
 * @param error The error that occurred during the Bluetooth operation
 */
- (void)onBluetoothError:(NSError *)error;

@end

/**
 * Protocol for receiving callbacks during Akiles device synchronization operations.
 *
 * Implement this protocol to receive status updates and progress information
 * during device synchronization with the Akiles API.
 */
@protocol SyncCallback <NSObject>

/**
 * Called to report status updates during synchronization
 * @param status The current status of the sync operation
 */
- (void)onStatus:(SyncStatus)status;

/**
 * Called to report progress updates during synchronization
 * @param percent Progress as a percentage (0.0 to 100.0)
 */
- (void)onStatusProgress:(float)percent;

@end


NS_ASSUME_NONNULL_END
