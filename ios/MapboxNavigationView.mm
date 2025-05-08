#import "MapboxNavigationView.h"
#import "MapboxNavigationView-Swift.h"

#import <react/renderer/components/MapboxNavigationSpec/ComponentDescriptors.h>
#import <react/renderer/components/MapboxNavigationSpec/EventEmitters.h>
#import <react/renderer/components/MapboxNavigationSpec/Props.h>
#import <react/renderer/components/MapboxNavigationSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface MapboxNavigationView () <RCTMapboxNavigationViewViewProtocol>
@end

@implementation MapboxNavigationView {
    MapboxNavigationView *_view;
}

- (instancetype)init
{
    if (self = [super init]) {
        _view = [[MapboxNavigationView alloc] init];
        [self addSubview:_view];
    }
    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<MapboxNavigationViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<MapboxNavigationViewProps const>(props);

    // Update Swift view properties
    if (oldViewProps.origin != newViewProps.origin) {
        _view.origin = newViewProps.origin;
    }
    if (oldViewProps.destination != newViewProps.destination) {
        _view.destination = newViewProps.destination;
    }
    if (oldViewProps.mapStyleURL != newViewProps.mapStyleURL) {
        _view.mapStyleURL = newViewProps.mapStyleURL;
    }
    if (oldViewProps.isCarplayView != newViewProps.isCarplayView) {
        _view.isCarplayView = newViewProps.isCarplayView;
    }
    if (oldViewProps.shouldSimulateRoute != newViewProps.shouldSimulateRoute) {
        _view.shouldSimulateRoute = newViewProps.shouldSimulateRoute;
    }
    if (oldViewProps.showsEndOfRouteFeedback != newViewProps.showsEndOfRouteFeedback) {
        _view.showsEndOfRouteFeedback = newViewProps.showsEndOfRouteFeedback;
    }
    if (oldViewProps.hideReportFeedback != newViewProps.hideReportFeedback) {
        _view.hideReportFeedback = newViewProps.hideReportFeedback;
    }
    if (oldViewProps.mute != newViewProps.mute) {
        _view.mute = newViewProps.mute;
    }
    if (oldViewProps.viewStyles != newViewProps.viewStyles) {
        _view.viewStyles = newViewProps.viewStyles;
    }

    [super updateProps:props oldProps:oldProps];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _view.frame = self.bounds;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<MapboxNavigationViewComponentDescriptor>();
}

@end