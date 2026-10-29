/**
 * @file RustWrapper.h
 * @brief Internal interfaces for Rust integration
 * 
 * This header contains internal protocols and interfaces used to communicate
 * with the Rust backend. These types are not part of the public API and should
 * not be used directly by application code.
 * 
 * @note This file is part of the internal RustWrapper module and is not exported
 *       to consumers of the AkilesSDK framework.
 */

#import <Foundation/Foundation.h>
#import <AkilesSDK/AkilesSDK.h>

// Generic success/error callback for async SDK operations.
@protocol AkilesCallback<NSObject>

- (void)onSuccess:(id _Nullable)value;
- (void)onError:(NSError * _Nonnull)error;

@end

// Internal protocol for NFC card operations.
@protocol CardProxy<NSObject>

- (void)update:(id<AkilesCallback> _Nonnull)callback;
- (bool)isAkilesCard;
- (NSData* _Nonnull)getUid;
- (void)close;

@end

@protocol CancelProxy<NSObject>

- (void)cancel;

@end

@interface Cancel: NSObject

@property (nonatomic) bool cancelled;
@property (nonatomic, retain) id<CancelProxy> _Nullable proxy;

- (void)setCancel:(id<CancelProxy> _Nonnull)proxy;
- (void)cancel;
@end

// Status of an HCE APDU exchange. Kept in sync with `status` in lib.rs.
typedef NS_ENUM(NSInteger, ApduStatus) {
    ApduStatusContinue = 0,  // more APDUs expected
    ApduStatusDone = 1,      // transaction completed successfully
    ApduStatusError = 2,     // processing error
};

// Result of processing one HCE APDU: the response to send back to the reader,
// plus the resulting session status.
@interface ApduResult : NSObject
@property (nonatomic, strong) NSData * _Nonnull response;
@property (nonatomic) ApduStatus status;
@end

// Internal protocol for main SDK operations.
//
// Async operations submit work to the Akiles thread and return immediately;
// results are delivered through callbacks. Sync store getters and HCE run on
// the calling thread.
@protocol AkilesProxy<NSObject>

- (NSString* _Nonnull)getVersion;
- (NSString* _Nonnull)getClientInfo;
- (NSArray<NSString *> * _Nullable)getSessionIds:(NSError * _Nullable * _Nullable)error;
- (void)addSession:(NSString * _Nonnull)token callback:(id<AkilesCallback> _Nonnull)callback;
- (BOOL)removeSession:(NSString * _Nonnull)sessionId error:(NSError * _Nullable * _Nullable)error;
- (BOOL)removeAllSessions:(NSError * _Nullable * _Nullable)error;
- (void)refreshSession:(NSString * _Nonnull)sessionId callback:(id<AkilesCallback> _Nonnull)callback;
- (void)refreshAllSessions:(id<AkilesCallback> _Nonnull)callback;
- (NSArray<Gadget *> * _Nullable)getGadgets:(NSString * _Nonnull)sessionId error:(NSError * _Nullable * _Nullable)error;
- (NSArray<Hardware *> * _Nullable)getHardwares:(NSString * _Nonnull)sessionId error:(NSError * _Nullable * _Nullable)error;

- (void)doGadgetAction:(Cancel * _Nonnull)cancel gadgetId:(NSString * _Nonnull)gadgetId actionId:(NSString * _Nonnull)actionId sessionId:(NSString * _Nonnull)sessionId options:(ActionOptions * _Nonnull)options callback:(id<ActionCallback> _Nonnull)callback;

- (void)doHardwareSync:(Cancel * _Nonnull)cancel hardwareId:(NSString * _Nonnull)hardwareId sessionId:(NSString * _Nonnull)sessionId callback:(id<SyncCallback> _Nonnull)callback;

- (void)doScanForNearbyHardwares:(Cancel * _Nonnull)cancel callback:(id<ScanCallback> _Nonnull)scanListener;

- (void)scanCard:(Cancel * _Nonnull)cancel callback:(id<AkilesCallback> _Nonnull)callback;

- (void)captureDiagnostics:(Cancel * _Nonnull)cancel
                sessionId:(NSString * _Nonnull)sessionId
                  scanDuration:(int)scanDuration
                 required:(NSArray<NSString *> * _Nullable)required
               callback:(id<AkilesCallback> _Nonnull)callback;

// HCE: synchronous fast path on the CoreNFC thread.
- (ApduResult * _Nonnull)apduReceived:(NSData * _Nonnull)apdu;
- (void)apduDeactivated;

@end

// Internal initialization function for the Rust backend. Initialization is
// infallible and synchronous: it always returns a valid, owned (+1) handle.
// Must be called from the main thread.
id<AkilesProxy> _Nonnull ak_init(void) NS_RETURNS_RETAINED;
