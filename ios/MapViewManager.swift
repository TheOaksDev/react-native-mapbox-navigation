import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import MapboxMaps

class MapViewManager {
    
    // MARK: - Properties
    weak var navigationMapView: NavigationMapView?
    weak var navigationViewController: NavigationViewController?
    private var viewportDataSource: ViewportDataSource?
    private var currentZoomLevel: Double = 10.0
    private var visibleArea: [String: Any]?
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Public Methods
    
    func setupNavigationMapView(frame: CGRect, mapStyleURL: String?) -> NavigationMapView {
        print("🔵 MapViewManager: setupNavigationMapView called")
        
        let mapView = NavigationMapView(frame: frame)
        self.navigationMapView = mapView
        
        // Set map style if provided
        if let mapStyleURL = mapStyleURL, !mapStyleURL.isEmpty {
            mapView.mapView.mapboxMap.style.styleManager.setStyleURIForUri(mapStyleURL)
        }
        
        // Set initial camera position
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let cameraOptions = CameraOptions(center: defaultCoordinate, zoom: currentZoomLevel)
        mapView.mapView.mapboxMap.setCamera(to: cameraOptions)
        
        return mapView
    }
    
    func setupViewportDataSource(for mapView: NavigationMapView, type: ViewportDataSourceType) {
        print("🔵 MapViewManager: setupViewportDataSource called with type: \(type)")
        
        let newViewportDataSource = NavigationViewportDataSource(mapView.mapView, viewportDataSourceType: type)
        viewportDataSource = newViewportDataSource
        mapView.navigationCamera.viewportDataSource = newViewportDataSource
        mapView.navigationCamera.follow()
    }
    
    func setCameraZoom(zoomLevel: Double) {
        print("🔵 MapViewManager: setCameraZoom called with zoom: \(zoomLevel)")
        
        currentZoomLevel = zoomLevel
        
        if let mapView = navigationMapView {
            let cameraOptions = CameraOptions(zoom: zoomLevel)
            mapView.mapView.mapboxMap.setCamera(to: cameraOptions)
        } else if let navVC = navigationViewController {
            if let navigationMapView = navVC.navigationMapView {
                let cameraOptions = CameraOptions(zoom: zoomLevel)
                navigationMapView.mapView.mapboxMap.setCamera(to: cameraOptions)
            }
        }
    }
    
    func getCameraZoom() -> Double {
        print("🔵 MapViewManager: getCameraZoom called")
        
        if let mapView = navigationMapView {
            currentZoomLevel = mapView.mapView.mapboxMap.cameraState.zoom
        } else if let navVC = navigationViewController {
            if let navigationMapView = navVC.navigationMapView {
                currentZoomLevel = navigationMapView.mapView.mapboxMap.cameraState.zoom
            }
        }
        
        return currentZoomLevel
    }
    
    func setVisibleArea(visibleArea: [String: Any]) {
        print("🔵 MapViewManager: setVisibleArea called")
        
        self.visibleArea = visibleArea
        
        // Update viewport padding based on visible area
        if let top = visibleArea["top"] as? Double,
           let left = visibleArea["left"] as? Double,
           let bottom = visibleArea["bottom"] as? Double,
           let right = visibleArea["right"] as? Double {
            
            let padding = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
            
            if let mapView = navigationMapView {
                if let navigationViewportDataSource = viewportDataSource as? NavigationViewportDataSource {
                    // navigationViewportDataSource.overviewPadding = padding
                    // navigationViewportDataSource.followingPadding = padding
                    // navigationViewportDataSource.evaluate()
                }
            } else if let navVC = navigationViewController {
                if let navigationMapView = navVC.navigationMapView {
                    if let navigationViewportDataSource = viewportDataSource as? NavigationViewportDataSource {
                        // navigationViewportDataSource.overviewPadding = padding
                        // navigationViewportDataSource.followingPadding = padding
                        // navigationViewportDataSource.evaluate()
                    }
                }
            }
        }
    }
    
    func showRoute(_ route: Route) {
        print("🔵 MapViewManager: showRoute called")
        
        if let mapView = navigationMapView {
            mapView.show([route])
            mapView.navigationCamera.moveToOverview()
        } else if let navVC = navigationViewController {
            if let navigationMapView = navVC.navigationMapView {
                navigationMapView.show([route])
                navigationMapView.navigationCamera.moveToOverview()
            }
        }
    }
    
    func removeRoutes() {
        print("🔵 MapViewManager: removeRoutes called")
        
        navigationMapView?.removeRoutes()
        navigationViewController?.navigationMapView?.removeRoutes()
    }
    
    func moveToOverview() {
        navigationMapView?.navigationCamera.moveToOverview()
        navigationViewController?.navigationMapView?.navigationCamera.moveToOverview()
    }
    
    func follow() {
        navigationMapView?.navigationCamera.follow()
        navigationViewController?.navigationMapView?.navigationCamera.follow()
    }
    
    func setNavigationViewController(_ viewController: NavigationViewController) {
        self.navigationViewController = viewController
    }
}
