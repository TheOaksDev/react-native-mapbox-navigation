import Foundation
import React

// Keep the original RCTViewManager for the view component
@objc(MapboxNavigationViewManager)
class MapboxNavigationViewManager: RCTViewManager {
  override func view() -> UIView! {
    print("🔵 MapboxNavigationViewManager: Creating new MapboxNavigationView")
    let navigationView = MapboxNavigationView()
    print("🔵 MapboxNavigationViewManager: MapboxNavigationView created with tag: \(navigationView.tag)")
    
    // We'll register the view when it's actually added to the view hierarchy
    // The registration will happen in the view's layoutSubviews method
    
    return navigationView
  }

  override static func requiresMainQueueSetup() -> Bool {
    print("🔵 MapboxNavigationViewManager: requiresMainQueueSetup called")
    return true
  }
}