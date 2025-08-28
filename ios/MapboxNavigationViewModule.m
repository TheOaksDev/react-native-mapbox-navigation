#import "React/RCTViewManager.h"
#import "React/RCTBridgeModule.h"

// Native Module Interface
@interface RCT_EXTERN_MODULE(MapboxNavigationViewModule, NSObject)

RCT_EXTERN_METHOD(startNavigation:(nonnull NSNumber *)viewRef
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopNavigation:(nonnull NSNumber *)viewRef
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startFreeDrive:(nonnull NSNumber *)viewRef
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopFreeDrive:(nonnull NSNumber *)viewRef
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(showRoutePreview:(nonnull NSNumber *)viewRef
                  coordinates:(nonnull NSArray *)coordinates
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(hideRoutePreview:(nonnull NSNumber *)viewRef
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setCameraZoom:(nonnull NSNumber *)viewRef
                  zoomLevel:(nonnull NSNumber *)zoomLevel
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getCameraZoom:(nonnull NSNumber *)viewRef
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setVisibleArea:(nonnull NSNumber *)viewRef
                  visibleArea:(nonnull NSDictionary *)visibleArea
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(testMethod:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end

