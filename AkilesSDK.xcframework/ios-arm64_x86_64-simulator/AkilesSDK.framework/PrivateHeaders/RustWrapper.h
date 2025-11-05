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

// Internal protocol for NFC card operations
@protocol CardProxy<NSObject>

- (void)update:(void (^ _Nonnull)(NSError * _Nullable error))completion;
- (bool)isAkilesCard;
- (NSData* _Nonnull)getUid;
- (void)close;

@end

@protocol CancelProxy<NSObject>

- (void)cancel;

@end

@interface Cancel: NSObject

@property (nonatomic) bool cancelled;
@property (nonatomic, retain) id<CancelProxy> proxy;

- (void)setCancel:(id<CancelProxy> _Nonnull)proxy;
- (void)cancel;
@end

// Internal protocol for main SDK operations
@protocol AkilesProxy<NSObject>

- (NSString* _Nonnull)getVersion;
- (NSString* _Nonnull)getClientInfo;
- (void)getSessionIds:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable sessionIds, NSError * _Nullable error))completion;
- (void)addSession:(NSString * _Nonnull)sessionId completion:(void (^ _Nonnull)(NSString * _Nullable session, NSError * _Nullable error))completion;
- (void)removeSession:(NSString * _Nonnull)sessionId completion:(void (^ _Nonnull)(NSError * _Nullable error))completion;
- (void)removeAllSessions:(void (^ _Nonnull)(NSError * _Nullable error))completion;
- (void)refreshSession:(NSString * _Nonnull)sessionId completion:(void (^ _Nonnull)(NSError * _Nullable error))completion;
- (void)refreshAllSessions:(void (^ _Nonnull)(NSError * _Nullable error))completion;
- (void)getGadgets:(NSString * _Nonnull)sessionId completion:(void (^ _Nonnull)(NSArray<Gadget *> * _Nullable gadgets, NSError * _Nullable error))completion;
- (void)getHardwares:(NSString * _Nonnull)sessionId completion:(void (^ _Nonnull)(NSArray<Hardware *> * _Nullable hardwares, NSError * _Nullable error))completion;

- (void)doGadgetAction:(Cancel * _Nonnull)cancel gadgetId:(NSString * _Nonnull)gadgetId actionId:(NSString * _Nonnull)actionId sessionId:(NSString * _Nonnull)sessionId options:(ActionOptions * _Nonnull)options callback:(id<ActionCallback> _Nonnull)callback completion:(void (^ _Nonnull)(void))completion;

- (void)doHardwareSync:(Cancel * _Nonnull)cancel hardwareId:(NSString * _Nonnull)hardwareId sessionId:(NSString * _Nonnull)sessionId callback:(id<SyncCallback> _Nonnull)callback completion:(void (^ _Nonnull)(void))completion;

- (void)doScanForNearbyHardwares:(Cancel * _Nonnull)cancel callback:(id<ScanCallback> _Nonnull)scanListener completion:(void (^ _Nonnull)(void))completion;

- (void)scanCard:(Cancel * _Nonnull)cancel completion:(void (^ _Nonnull)(id<CardProxy> _Nullable card, NSError * _Nullable error))completion;

@end

// Internal initialization function for the Rust backend
void ak_init(void (^ _Nonnull)(id<AkilesProxy> _Nullable handle, NSError * _Nullable error));

// Internal wrapper class for Rust C functions
@interface RustSwiftWrapper : NSObject

+ (const uint8_t * _Nullable)akApduReceived:(const uint8_t * _Nonnull)apdu length:(uintptr_t)length outLength:(uintptr_t * _Nonnull)outLength outStatus:(uintptr_t * _Nonnull)outStatus;
+ (void)deactivateApdu;
+ (void)freeRustBuffer:(uint8_t * _Nonnull)ptr length:(uintptr_t)len;

@end
