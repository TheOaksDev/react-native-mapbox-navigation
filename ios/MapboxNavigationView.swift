import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import MapboxMaps

@objc(MapboxNavigationView)
class MapboxNavigationView: UIView, NavigationViewControllerDelegate, NavigationServiceManagerDelegate, RouteManagerDelegate {
    
    // MARK: - Properties
    weak var navViewController: NavigationViewController?
    private var navigationMapView: NavigationMapView?
    var embedded: Bool
    var embedding: Bool
    
    // MARK: - Managers
    private let navigationServiceManager = NavigationServiceManager()
    private let mapViewManager = MapViewManager()
    private let routeManager = RouteManager()
    private let styleManager = StyleManager()
    
    // MARK: - React Native Properties
    @objc var origin: NSDictionary = [:] {
        didSet { 
            print("🔵 MapboxNavigationView: origin set to: \(origin)")
            setNeedsLayout() 
        }
    }

    @objc var destination: NSDictionary = [:] {
        didSet { 
            print("🔵 MapboxNavigationView: destination set to: \(destination)")
            setNeedsLayout() 
        }
    }

    @objc var mapStyleURL: String = ""
    @objc var viewStyles: NSDictionary = [:]

    @objc var isCarplayView: Bool = true
    @objc var shouldSimulateRoute: Bool = false
    @objc var showsEndOfRouteFeedback: Bool = false

    @objc var hideReportFeedback: Bool = false
    @objc var mute: Bool = false

    @objc var onLocationChange: RCTDirectEventBlock?
    @objc var onRouteProgressChange: RCTDirectEventBlock?
    @objc var onError: RCTDirectEventBlock?
    @objc var onCancelNavigation: RCTDirectEventBlock?
    @objc var onArrive: RCTDirectEventBlock?

    // MARK: - Initialization
    override init(frame: CGRect) {
        embedded = false
        embedding = false
        super.init(frame: frame)
        
        setupManagers()
        
        print("🔵 MapboxNavigationView: Initialized with tag: \(self.tag)")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupManagers() {
        navigationServiceManager.delegate = self
        routeManager.delegate = self
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        if navViewController == nil && navigationMapView == nil && !embedding && !embedded {
            // Register this view with the native module using the React Native tag
            registerWithNativeModule()
            
            embed()
            applyStyles()
        } else {
            navViewController?.view.frame = bounds
            navigationMapView?.frame = bounds
        }
    }
    
    private func registerWithNativeModule() {
        // Use the React Native tag instead of the view's tag
        guard let reactTag = self.reactTag else {
            print("🔴 MapboxNavigationView: reactTag is nil, cannot register")
            return
        }
        print("🔵 MapboxNavigationView: Registering with native module, reactTag: \(reactTag)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let bridge = RCTBridge.current(),
               let module = bridge.module(forName: "MapboxNavigationViewModule") as? MapboxNavigationViewModule {
                module.registerNavigationView(reactTag.intValue, view: self)
            }
        }
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        // Cleanup and teardown any existing resources
        navViewController?.removeFromParent()
        navigationMapView?.removeFromSuperview()
        
        // Unregister this view from the native module
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let bridge = RCTBridge.current(),
               let module = bridge.module(forName: "MapboxNavigationViewModule") as? MapboxNavigationViewModule {
                if let reactTag = self.reactTag {
                    module.unregisterNavigationView(reactTag.intValue)
                }
            }
        }
    }

    // MARK: - Public Navigation Methods
    
    func registerWithReference(_ reference: Int) {
        print("🔵 MapboxNavigationView: registerWithReference called with: \(reference)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let bridge = RCTBridge.current(),
               let module = bridge.module(forName: "MapboxNavigationViewModule") as? MapboxNavigationViewModule {
                module.registerNavigationView(reference, view: self)
            }
        }
    }
    
    func startNavigation() {
        print("🔵 MapboxNavigationView: startNavigation called")
        
        // Check if we have valid coordinates from props
        let hasValidCoordinates = (origin["latitude"] as? CLLocationDegrees) != nil &&
                                 (origin["longitude"] as? CLLocationDegrees) != nil &&
                                 (destination["latitude"] as? CLLocationDegrees) != nil &&
                                 (destination["longitude"] as? CLLocationDegrees) != nil
        
        if hasValidCoordinates {
            print("🔵 MapboxNavigationView: Valid coordinates provided, starting navigation")
            setupNavigationWithRoute()
        } else {
            print("🔵 MapboxNavigationView: No valid coordinates, starting free-drive mode")
            // Ensure navigation service is started for free-drive
            if !navigationServiceManager.isNavigationActive && !navigationServiceManager.isFreeDriveActive {
                navigationServiceManager.startFreeDrive()
            }
            onError?(["message": "Invalid coordinate format"])
        }
    }
    
    func stopNavigation() {
        print("🔵 MapboxNavigationView: stopNavigation called")
        navigationServiceManager.stopNavigation()
    }
    
    func startFreeDrive() {
        print("🔵 MapboxNavigationView: startFreeDrive called")
        navigationServiceManager.startFreeDrive()
    }
    
    func stopFreeDrive() {
        print("🔵 MapboxNavigationView: stopFreeDrive called")
        navigationServiceManager.stopFreeDrive()
    }
    
    func showRoutePreview(coordinates: [[String: Any]]) {
        print("🔵 MapboxNavigationView: showRoutePreview called with \(coordinates.count) coordinates")
        
        routeManager.calculateRoutePreview(coordinates: coordinates) { [weak self] result in
            switch result {
            case .success(let response):
                if let route = response.routes?.first {
                    self?.mapViewManager.showRoute(route)
                }
            case .failure(let error):
                print("🔴 MapboxNavigationView: Route preview failed: \(error.localizedDescription)")
                self?.onError?(["message": error.localizedDescription])
            }
        }
    }
    
    func hideRoutePreview() {
        print("🔵 MapboxNavigationView: hideRoutePreview called")
        mapViewManager.removeRoutes()
        routeManager.clearRoutes()
        mapViewManager.follow()
    }
    
    func setCameraZoom(zoomLevel: Double) {
        print("🔵 MapboxNavigationView: setCameraZoom called with zoom: \(zoomLevel)")
        mapViewManager.setCameraZoom(zoomLevel: zoomLevel)
    }
    
    func getCameraZoom() -> Double {
        print("🔵 MapboxNavigationView: getCameraZoom called")
        return mapViewManager.getCameraZoom()
    }
    
    func setVisibleArea(visibleArea: [String: Any]) {
        print("🔵 MapboxNavigationView: setVisibleArea called")
        mapViewManager.setVisibleArea(visibleArea: visibleArea)
    }

    // MARK: - Private Methods

    private func embed() {
        print("🔵 MapboxNavigationView: embed() called")
        print("🔵 MapboxNavigationView: origin: \(origin), destination: \(destination)")
        
        embedding = true

        let originCoords = self.origin as? [String: Any]
        let destinationCoords = self.destination as? [String: Any]

        // Check if we have valid coordinates
        let hasValidCoordinates = (originCoords?["latitude"] as? CLLocationDegrees) != nil &&
                                 (originCoords?["longitude"] as? CLLocationDegrees) != nil &&
                                 (destinationCoords?["latitude"] as? CLLocationDegrees) != nil &&
                                 (destinationCoords?["longitude"] as? CLLocationDegrees) != nil
        
        if hasValidCoordinates {
            print("🔵 MapboxNavigationView: Valid coordinates provided, starting navigation")
            setupNavigationWithRoute()
        } else {
            print("🔵 MapboxNavigationView: No valid coordinates, starting free-drive mode")
            setupFreeDriveMode()
        }
    }
    
    private func setupNavigationWithRoute() {
        // Safely extract coordinates with proper error handling
        guard let originLat = origin["latitude"] as? CLLocationDegrees,
              let originLon = origin["longitude"] as? CLLocationDegrees,
              let destLat = destination["latitude"] as? CLLocationDegrees,
              let destLon = destination["longitude"] as? CLLocationDegrees else {
            print("🔴 MapboxNavigationView: Invalid coordinate format")
            print("🔴 MapboxNavigationView: Origin: \(origin)")
            print("🔴 MapboxNavigationView: Destination: \(destination)")
            onError?(["message": "Invalid coordinate format"])
            setupFreeDriveMode()
            return
        }
        
        let originCoords = [originLon, originLat] // [longitude, latitude] format
        let destinationCoords = [destLon, destLat] // [longitude, latitude] format
        
        print("🔵 MapboxNavigationView: Origin coordinates: \(originCoords)")
        print("🔵 MapboxNavigationView: Destination coordinates: \(destinationCoords)")
        
        routeManager.calculateRoute(from: originCoords, to: destinationCoords) { [weak self] result in
            guard let self = self, let parentVC = self.parentViewController else { return }

            switch result {
            case .failure(let error):
                print("🔴 MapboxNavigationView: Route calculation failed: \(error.localizedDescription)")
                self.onError?(["message": error.localizedDescription])
                // Fall back to free-drive mode if route calculation fails
                self.setupFreeDriveMode()
                
            case .success(let response):
                print("🔵 MapboxNavigationView: Route calculation successful")

                let navigationService = MapboxNavigationService(
                    routeResponse: response,
                    routeIndex: 0,
                    routeOptions: self.routeManager.getCurrentRouteOptions()!,
                    simulating: self.shouldSimulateRoute ? .always : .never
                )
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let vc = NavigationViewController(
                    for: response,
                    routeIndex: 0,
                    routeOptions: self.routeManager.getCurrentRouteOptions()!,
                    navigationOptions: navigationOptions
                )

                self.configureNavigationViewController(vc)
                self.navigationServiceManager.setupNavigationService(with: response, options: self.routeManager.getCurrentRouteOptions()!)
                self.embedViewController(vc, in: parentVC)
                
                // Ensure navigation service is started
                if !self.navigationServiceManager.isNavigationActive {
                    self.navigationServiceManager.startNavigation()
                }
            }

            self.embedding = false
            self.embedded = true
        }
    }
    
    private func setupFreeDriveMode() {
        print("🔵 MapboxNavigationView: Setting up free-drive mode")
        
        // Create navigation map view using MapViewManager
        let mapView = mapViewManager.setupNavigationMapView(frame: bounds, mapStyleURL: mapStyleURL.isEmpty ? nil : mapStyleURL)
        self.navigationMapView = mapView
        
        // Set up viewport for passive navigation
        mapViewManager.setupViewportDataSource(for: mapView, type: .passive)
        
        // Add the navigation map view directly to our view
        addSubview(mapView)
        mapView.frame = bounds
        
        // Start free drive
        navigationServiceManager.startFreeDrive()
        
        embedding = false
        embedded = true
        
        print("🔵 MapboxNavigationView: Free-drive mode setup complete")
    }
    
    private func configureNavigationViewController(_ vc: NavigationViewController) {
        // Apply map style if provided
        if !mapStyleURL.isEmpty {
            vc.navigationMapView?.mapView.mapboxMap.style.styleManager.setStyleURIForUri(mapStyleURL)
        }

        // Configure navigation view controller appearance
        vc.showsReportFeedback = !hideReportFeedback
        vc.showsEndOfRouteFeedback = showsEndOfRouteFeedback

        if isCarplayView {
            vc.floatingButtonsPosition = .topTrailing
        }
        
        // Hide UI elements for CarPlay view
        StatusView.appearance().isHidden = isCarplayView
        TopBannerView.appearance().isHidden = isCarplayView
        BottomBannerView.appearance().isHidden = isCarplayView
        InstructionsBannerView.appearance().isHidden = isCarplayView
        NextBannerView.appearance().isHidden = isCarplayView
        StepInstructionsView.appearance().isHidden = isCarplayView
        FloatingButton.appearance().isHidden = isCarplayView
        NavigationSettings.shared.voiceMuted = mute

        vc.delegate = self
        
        // Set up map view manager with navigation view controller
        mapViewManager.setNavigationViewController(vc)
    }
    
    private func embedViewController(_ vc: NavigationViewController, in parentVC: UIViewController) {
        parentVC.addChild(vc)
        addSubview(vc.view)
        vc.view.frame = bounds
        vc.didMove(toParent: parentVC)
        navViewController = vc
        
        print("🔵 MapboxNavigationView: NavigationViewController embedded successfully")
    }

    private func applyStyles() {
        print("🔵 MapboxNavigationView: applyStyles called")
        if let styles = viewStyles as? [String: Any] {
            styleManager.setStyles(styles)
        }
    }

    // MARK: - NavigationViewControllerDelegate

    func navigationViewController(_: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation _: CLLocation) {
        print("🔵 MapboxNavigationView: navigationViewController didUpdate called")
        let routeInfo = routeManager.extractRouteInfo(from: progress)

        onLocationChange?(["longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude])
        onRouteProgressChange?([
            "distanceTraveled": progress.distanceTraveled,
            "durationRemaining": progress.durationRemaining,
            "fractionTraveled": progress.fractionTraveled,
            "distanceRemaining": progress.distanceRemaining,
            "legIndex": progress.legIndex,
            "currentStepIndex": progress.currentLegProgress.stepIndex,
            "currentStepProgress": progress.currentLegProgress.currentStepProgress.distanceRemaining,
            "route": routeInfo
        ])
    }

    func navigationViewControllerDidDismiss(_: NavigationViewController, byCanceling canceled: Bool) {
        if !canceled {
            return
        }
        onCancelNavigation?(["message": ""])
    }

    func navigationViewController(_: NavigationViewController, didArriveAt _: Waypoint) -> Bool {
        onArrive?(["message": ""])
        return true
    }

    // MARK: - NavigationServiceManagerDelegate
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didStartNavigation isRouteBased: Bool) {
        print("🔵 MapboxNavigationView: Navigation started - Route based: \(isRouteBased)")
        
        if isRouteBased {
            // Set up viewport for active navigation
            if let navVC = navViewController {
                mapViewManager.setupViewportDataSource(for: navVC.navigationMapView!, type: .active)
            }
        } else {
            // Set up viewport for active free drive
            if let mapView = navigationMapView {
                mapViewManager.setupViewportDataSource(for: mapView, type: .active)
            }
        }
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didStopNavigation: Bool) {
        print("🔵 MapboxNavigationView: Navigation stopped")
        mapViewManager.removeRoutes()
        navigationServiceManager.startFreeDrive()
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didStartFreeDrive: Bool) {
        print("🔵 MapboxNavigationView: Free drive started")
        if let mapView = navigationMapView {
            mapViewManager.setupViewportDataSource(for: mapView, type: .passive)
        }
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didStopFreeDrive: Bool) {
        print("🔵 MapboxNavigationView: Free drive stopped")
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didSetupNavigationService service: MapboxNavigationService) {
        print("🔵 MapboxNavigationView: Navigation service setup complete")
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔵 MapboxNavigationView: Authorization status changed: \(status.rawValue)")
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didUpdateAlternatives updatedAlternatives: [Route], removedAlternatives: [Route]) {
        print("🔵 MapboxNavigationView: Route alternatives updated - Added: \(updatedAlternatives.count), Removed: \(removedAlternatives.count)")
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didUpdateProgress progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        print("🔵 MapboxNavigationView: Navigation service did update progress")
        let routeInfo = routeManager.extractRouteInfo(from: progress)

        onLocationChange?(["longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude])
        onRouteProgressChange?([
            "distanceTraveled": progress.distanceTraveled,
            "durationRemaining": progress.durationRemaining,
            "fractionTraveled": progress.fractionTraveled,
            "distanceRemaining": progress.distanceRemaining,
            "legIndex": progress.legIndex,
            "currentStepIndex": progress.currentLegProgress.stepIndex,
            "currentStepProgress": progress.currentLegProgress.currentStepProgress.distanceRemaining,
            "route": routeInfo
        ])
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didPassSpokenInstructionPoint instruction: SpokenInstruction, routeProgress: RouteProgress) {
        print("🔵 MapboxNavigationView: Spoken instruction point passed")
        // Handle spoken instructions if needed
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, willRerouteFrom location: CLLocation?) {
        print("🔵 MapboxNavigationView: Will reroute from location")
        // Handle pre-reroute logic if needed
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
        print("🔵 MapboxNavigationView: Did reroute along new route - Proactive: \(proactive)")
        // Handle post-reroute logic if needed
    }
    
    func navigationServiceManager(_ manager: NavigationServiceManager, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        print("🔵 MapboxNavigationView: didPassVisualInstructionPoint")

        if isCarplayView {
            // skip updating views; this should pass data to RN scope
            // so that Carplay Manager methods can be called to update Carplay UI
        } else {
            // For non-CarPlay views, the NavigationViewController will handle visual instructions automatically
            // No additional action needed here as the NavigationViewController manages its own UI updates
        }
    }

    // MARK: - RouteManagerDelegate
    
    func routeManager(_ manager: RouteManager, didCalculateRoute response: RouteResponse) {
        print("🔵 MapboxNavigationView: Route calculated successfully")
    }
    
    func routeManager(_ manager: RouteManager, didFailWithError error: Error) {
        print("🔴 MapboxNavigationView: Route calculation failed: \(error.localizedDescription)")
        onError?(["message": error.localizedDescription])
    }
}
