import Foundation
import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import React

@objc(MapboxNavigationViewModule)
class MapboxNavigationViewModule: NSObject, RCTBridgeModule {
  private var navigationViews: [Int: MapboxNavigationView] = [:]
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc
  static func moduleName() -> String! {
    return "MapboxNavigationViewModule"
  }
  
  @objc
  func testMethod(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    resolve(["message": "MapboxNavigationViewModule is working!"])
  }
  
  @objc
  func registerView(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: registerView called with viewRef: \(viewRef)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      // Find the view by tag
      if let bridge = RCTBridge.current(),
         let viewManager = bridge.module(forName: "MapboxNavigationViewManager") as? MapboxNavigationViewManager {
        // This is a bit of a workaround - we'll need to find the view differently
        print("🔵 MapboxNavigationViewModule: Attempting to register view with ref: \(viewRef.intValue)")
        resolve(["success": true, "message": "View registration attempted"])
      } else {
        reject("ERROR", "Could not find view manager", nil)
      }
    }
  }
  
  @objc
  func startNavigation(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: startNavigation called with viewRef: \(viewRef)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        print("🔴 MapboxNavigationViewModule: Module instance is nil")
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        print("🔴 MapboxNavigationViewModule: Navigation view not found for ref: \(viewRef.intValue)")
        print("🔴 MapboxNavigationViewModule: Available views: \(self.navigationViews.keys)")
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      print("🔵 MapboxNavigationViewModule: Found view, calling startNavigation")
      view.startNavigation()
      resolve(["success": true])
    }
  }
  

  
  @objc
  func stopNavigation(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: stopNavigation called with viewRef: \(viewRef)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      view.stopNavigation()
      resolve(["success": true])
    }
  }
  
  @objc
  func startFreeDrive(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: startFreeDrive called with viewRef: \(viewRef)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      view.startFreeDrive()
      resolve(["success": true])
    }
  }
  
  @objc
  func stopFreeDrive(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: stopFreeDrive called with viewRef: \(viewRef)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      view.stopFreeDrive()
      resolve(["success": true])
    }
  }
  
  @objc
  func showRoutePreview(_ viewRef: NSNumber, coordinates: [[String: Any]], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: showRoutePreview called with viewRef: \(viewRef)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      view.showRoutePreview(coordinates: coordinates)
      resolve(["success": true])
    }
  }
  
  @objc
  func hideRoutePreview(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: hideRoutePreview called with viewRef: \(viewRef)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      view.hideRoutePreview()
      resolve(["success": true])
    }
  }
  
  @objc
  func setCameraZoom(_ viewRef: NSNumber, zoomLevel: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: setCameraZoom called with viewRef: \(viewRef), zoom: \(zoomLevel)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      view.setCameraZoom(zoomLevel: zoomLevel.doubleValue)
      resolve(["success": true])
    }
  }
  
  @objc
  func getCameraZoom(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: getCameraZoom called with viewRef: \(viewRef)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      let zoomLevel = view.getCameraZoom()
      resolve(["zoom": zoomLevel])
    }
  }
  
  @objc
  func setVisibleArea(_ viewRef: NSNumber, visibleArea: [String: Any], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    print("🔵 MapboxNavigationViewModule: setVisibleArea called with viewRef: \(viewRef)")
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      view.setVisibleArea(visibleArea: visibleArea)
      resolve(["success": true])
    }
  }
  
  // Helper method to register navigation views
  func registerNavigationView(_ viewRef: Int, view: MapboxNavigationView) {
    print("🔵 MapboxNavigationViewModule: Registering navigation view with ref: \(viewRef)")
    navigationViews[viewRef] = view
    print("🔵 MapboxNavigationViewModule: Total registered views: \(navigationViews.count)")
  }
  
  func unregisterNavigationView(_ viewRef: Int) {
    print("🔵 MapboxNavigationViewModule: Unregistering navigation view with ref: \(viewRef)")
    navigationViews.removeValue(forKey: viewRef)
    print("🔵 MapboxNavigationViewModule: Total registered views: \(navigationViews.count)")
  }
}
