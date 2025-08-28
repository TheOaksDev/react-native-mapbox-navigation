import Foundation
import React

// Keep the original RCTViewManager for the view component
@objc(MapboxNavigationViewManager)
class MapboxNavigationViewManager: RCTViewManager {
  override func view() -> UIView! {
    print("🔵 MapboxNavigationViewManager: Creating new MapboxNavigationView")
    let navigationView = MapboxNavigationView()
    print("🔵 MapboxNavigationViewManager: MapboxNavigationView created with tag: \(navigationView.tag)")
    return navigationView
  }

  override static func requiresMainQueueSetup() -> Bool {
    print("🔵 MapboxNavigationViewManager: requiresMainQueueSetup called")
    return true
  }
}