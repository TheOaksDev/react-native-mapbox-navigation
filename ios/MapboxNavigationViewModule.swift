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
  func startNavigation(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      do {
        view.startNavigation()
        resolve(["success": true])
      } catch {
        reject("ERROR", "Failed to start navigation: \(error.localizedDescription)", error)
      }
    }
  }
  
  @objc
  func stopNavigation(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      do {
        view.stopNavigation()
        resolve(["success": true])
      } catch {
        reject("ERROR", "Failed to stop navigation: \(error.localizedDescription)", error)
      }
    }
  }
  
  @objc
  func startFreeDrive(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      do {
        view.startFreeDrive()
        resolve(["success": true])
      } catch {
        reject("ERROR", "Failed to start free drive: \(error.localizedDescription)", error)
      }
    }
  }
  
  @objc
  func stopFreeDrive(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      do {
        view.stopFreeDrive()
        resolve(["success": true])
      } catch {
        reject("ERROR", "Failed to stop free drive: \(error.localizedDescription)", error)
      }
    }
  }
  
  @objc
  func showRoutePreview(_ viewRef: NSNumber, coordinates: [[String: Any]], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      do {
        view.showRoutePreview(coordinates: coordinates)
        resolve(["success": true])
      } catch {
        reject("ERROR", "Failed to show route preview: \(error.localizedDescription)", error)
      }
    }
  }
  
  @objc
  func hideRoutePreview(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      do {
        view.hideRoutePreview()
        resolve(["success": true])
      } catch {
        reject("ERROR", "Failed to hide route preview: \(error.localizedDescription)", error)
      }
    }
  }
  
  @objc
  func setCameraZoom(_ viewRef: NSNumber, zoomLevel: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      do {
        view.setCameraZoom(zoomLevel: zoomLevel.doubleValue)
        resolve(["success": true])
      } catch {
        reject("ERROR", "Failed to set camera zoom: \(error.localizedDescription)", error)
      }
    }
  }
  
  @objc
  func getCameraZoom(_ viewRef: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      do {
        let zoomLevel = view.getCameraZoom()
        resolve(["zoom": zoomLevel])
      } catch {
        reject("ERROR", "Failed to get camera zoom: \(error.localizedDescription)", error)
      }
    }
  }
  
  @objc
  func setVisibleArea(_ viewRef: NSNumber, visibleArea: [String: Any], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        reject("ERROR", "Module instance is nil", nil)
        return
      }
      
      guard let view = self.navigationViews[viewRef.intValue] else {
        reject("ERROR", "Navigation view not found", nil)
        return
      }
      
      do {
        view.setVisibleArea(visibleArea: visibleArea)
        resolve(["success": true])
      } catch {
        reject("ERROR", "Failed to set visible area: \(error.localizedDescription)", error)
      }
    }
  }
  
  // Helper method to register navigation views
  func registerNavigationView(_ viewRef: Int, view: MapboxNavigationView) {
    navigationViews[viewRef] = view
  }
  
  func unregisterNavigationView(_ viewRef: Int) {
    navigationViews.removeValue(forKey: viewRef)
  }
}
