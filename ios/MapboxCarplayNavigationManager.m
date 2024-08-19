#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(MapboxCarplayNavigationManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(onLocationChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onRouteProgressChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCancelNavigation, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onArrive, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(origin, NSArray)
RCT_EXPORT_VIEW_PROPERTY(destination, NSArray)
RCT_EXPORT_VIEW_PROPERTY(shouldSimulateRoute, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsEndOfRouteFeedback, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideStatusView, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideLanesView, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideTopBannerView, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideBottomBannerView, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideInstructionsBannerView, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideNextBannerView, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideStepInstructionsView, BOOL)
RCT_EXPORT_VIEW_PROPERTY(mute, BOOL)
RCT_EXPORT_VIEW_PROPERTY(viewStyles, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(mapStyleURL, NSString)
RCT_EXPORT_VIEW_PROPERTY(hideReportFeedback, BOOL)

@end
