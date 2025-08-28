import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import MapboxMaps

// // adapted from https://pspdfkit.com/blog/2017/native-view-controllers-and-react-native/ and https://github.com/mslabenyak/react-native-mapbox-navigation/blob/master/ios/Mapbox/MapboxNavigationView.swift
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

public extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let length = hexSanitized.count
        let r, g, b, a: CGFloat

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF00_0000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF_0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000_FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x0000_00FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

class CustomEmptyView: ContainerViewController {
    override func loadView() {
        super.loadView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0).isActive = true
        view.widthAnchor.constraint(equalToConstant: 0).isActive = true
    }
}

@objc(MapboxNavigationView)
class MapboxNavigationView: UIView, NavigationViewControllerDelegate, NavigationServiceDelegate {
    weak var navViewController: NavigationViewController?
    private var navigationMapView: NavigationMapView?
    var embedded: Bool
    var embedding: Bool
    
    // Navigation state management
    private var isNavigationActive: Bool = false
    private var isFreeDriveActive: Bool = false
    private var currentRouteResponse: RouteResponse?
    private var currentRouteOptions: NavigationRouteOptions?
    private var navigationService: MapboxNavigationService?
    private var passiveLocationManager: PassiveLocationManager?
    private var viewportDataSource: ViewportDataSource?
    
    // Camera and viewport management
    private var currentZoomLevel: Double = 10.0
    private var visibleArea: [String: Any]?

    @objc var origin: NSArray = [] {
        didSet { setNeedsLayout() }
    }

    @objc var destination: NSArray = [] {
        didSet { setNeedsLayout() }
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

    override init(frame: CGRect) {
        embedded = false
        embedding = false
        super.init(frame: frame)
        
        // Register this view with the native module
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let bridge = RCTBridge.current(),
               let module = bridge.module(forName: "MapboxNavigationViewModule") as? MapboxNavigationViewModule {
                module.registerNavigationView(self.tag, view: self)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if navViewController == nil && navigationMapView == nil && !embedding && !embedded {
            embed()
            applyStyles()
        } else {
            navViewController?.view.frame = bounds
            navigationMapView?.frame = bounds
        }
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        // cleanup and teardown any existing resources
        navViewController?.removeFromParent()
        navigationMapView?.removeFromSuperview()
        
        // Unregister this view from the native module
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let bridge = RCTBridge.current(),
               let module = bridge.module(forName: "MapboxNavigationViewModule") as? MapboxNavigationViewModule {
                module.unregisterNavigationView(self.tag)
            }
        }
    }

    // MARK: - Public Navigation Methods
    
    func startNavigation() {
        print("🔵 MapboxNavigationView: startNavigation called")
        
        // Check if we have a navigation service (route-based navigation)
        if let navigationService = navigationService {
            print("🔵 MapboxNavigationView: Starting route-based navigation")
            isNavigationActive = true
            
            // Start the navigation session
            navigationService.start()
            
            // Set up navigation camera
            if let navVC = navViewController {
                navVC.navigationMapView?.navigationCamera.follow()
                
                // Configure viewport for active navigation
                if let navigationMapView = navVC.navigationMapView {
                    let newViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .active)
                    viewportDataSource = newViewportDataSource
                    navigationMapView.navigationCamera.viewportDataSource = newViewportDataSource
                }
            }
            
            print("🔵 MapboxNavigationView: Route-based navigation started successfully")
        } else {
            print("🔵 MapboxNavigationView: No route available, starting free-drive navigation")
            // If no route is available, we're already in free-drive mode
            isNavigationActive = true
            isFreeDriveActive = true
            
            // Configure viewport for active navigation (following user location)
            if let navigationMapView = navigationMapView {
                let newViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .active)
                viewportDataSource = newViewportDataSource
                navigationMapView.navigationCamera.viewportDataSource = newViewportDataSource
                navigationMapView.navigationCamera.follow()
            } else if let navVC = navViewController {
                if let navMapView = navVC.navigationMapView {
                    let newViewportDataSource = NavigationViewportDataSource(navMapView.mapView, viewportDataSourceType: .active)
                    viewportDataSource = newViewportDataSource
                    navMapView.navigationCamera.viewportDataSource = newViewportDataSource
                    navMapView.navigationCamera.follow()
                }
            }
            
            print("🔵 MapboxNavigationView: Free-drive navigation started successfully")
        }
    }
    
    func stopNavigation() {
        print("🔵 MapboxNavigationView: stopNavigation called")
        
        isNavigationActive = false
        
        // Stop the navigation service
        navigationService?.stop()
        
        // Clear routes
        navViewController?.navigationMapView?.removeRoutes()
        navigationMapView?.removeRoutes()
        
        // Reset to free drive mode
        startFreeDrive()
        
        print("🔵 MapboxNavigationView: Navigation stopped successfully")
    }
    
    func startFreeDrive() {
        print("🔵 MapboxNavigationView: startFreeDrive called")
        
        isFreeDriveActive = true
        
        // Set up passive location manager for free drive
        passiveLocationManager = PassiveLocationManager()
        
        // Configure viewport for passive navigation
        if let mapView = navigationMapView {
            let newViewportDataSource = NavigationViewportDataSource(mapView.mapView, viewportDataSourceType: .passive)
            viewportDataSource = newViewportDataSource
            mapView.navigationCamera.viewportDataSource = newViewportDataSource
            mapView.navigationCamera.follow()
        } else if let navVC = navViewController {
            if let navMapView = navVC.navigationMapView {
                let newViewportDataSource = NavigationViewportDataSource(navMapView.mapView, viewportDataSourceType: .passive)
                viewportDataSource = newViewportDataSource
                navMapView.navigationCamera.viewportDataSource = newViewportDataSource
                navMapView.navigationCamera.follow()
            }
        }
        
        print("🔵 MapboxNavigationView: Free drive started successfully")
    }
    
    func stopFreeDrive() {
        print("🔵 MapboxNavigationView: stopFreeDrive called")
        
        isFreeDriveActive = false
        passiveLocationManager = nil
        
        print("🔵 MapboxNavigationView: Free drive stopped successfully")
    }
    
    func showRoutePreview(coordinates: [[String: Any]]) {
        print("🔵 MapboxNavigationView: showRoutePreview called with \(coordinates.count) coordinates")
        
        guard coordinates.count >= 2 else {
            print("🔴 MapboxNavigationView: At least two coordinates required")
            return
        }
        
        // Convert coordinates to CLLocationCoordinate2D
        let waypoints = coordinates.compactMap { coord -> Waypoint? in
            guard let latitude = coord["latitude"] as? Double,
                  let longitude = coord["longitude"] as? Double else {
                return nil
            }
            return Waypoint(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        
        guard waypoints.count >= 2 else {
            print("🔴 MapboxNavigationView: Invalid coordinates")
            return
        }
        
        // Create route options
        let routeOptions = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: .automobileAvoidingTraffic)
        
        // Calculate route
        Directions.shared.calculate(routeOptions) { [weak self] (_, result) in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("🔴 MapboxNavigationView: Route calculation failed: \(error.localizedDescription)")
                self.onError?(["message": error.localizedDescription])
                
            case .success(let response):
                print("🔵 MapboxNavigationView: Route preview calculated successfully")
                
                // Store the route response for later use
                self.currentRouteResponse = response
                self.currentRouteOptions = routeOptions
                
                // Show the route on the map
                if let mapView = self.navigationMapView {
                    if let route = response.routes?.first {
                        mapView.show([route])
                    }
                    mapView.navigationCamera.moveToOverview()
                } else if let navVC = self.navViewController {
                    if let navigationMapView = navVC.navigationMapView {
                        if let route = response.routes?.first {
                            navigationMapView.show([route])
                        }
                        navigationMapView.navigationCamera.moveToOverview()
                    }
                }
            }
        }
    }
    
    func hideRoutePreview() {
        print("🔵 MapboxNavigationView: hideRoutePreview called")
        
        // Clear the route from the map
        navigationMapView?.removeRoutes()
        navViewController?.navigationMapView?.removeRoutes()
        
        // Clear stored route data
        currentRouteResponse = nil
        currentRouteOptions = nil
        
        // Return to following mode
        navigationMapView?.navigationCamera.follow()
        navViewController?.navigationMapView?.navigationCamera.follow()
        
        print("🔵 MapboxNavigationView: Route preview hidden successfully")
    }
    
    func setCameraZoom(zoomLevel: Double) {
        print("🔵 MapboxNavigationView: setCameraZoom called with zoom: \(zoomLevel)")
        
        currentZoomLevel = zoomLevel
        
        // Set camera zoom
        if let mapView = navigationMapView {
            let cameraOptions = CameraOptions(zoom: zoomLevel)
            mapView.mapView.mapboxMap.setCamera(to: cameraOptions)
        } else if let navVC = navViewController {
            if let navigationMapView = navVC.navigationMapView {
                let cameraOptions = CameraOptions(zoom: zoomLevel)
                navigationMapView.mapView.mapboxMap.setCamera(to: cameraOptions)
            }
        }
        
        print("🔵 MapboxNavigationView: Camera zoom set successfully")
    }
    
    func getCameraZoom() -> Double {
        print("🔵 MapboxNavigationView: getCameraZoom called")
        
        if let mapView = navigationMapView {
            currentZoomLevel = mapView.mapView.mapboxMap.cameraState.zoom
        } else if let navVC = navViewController {
            if let navigationMapView = navVC.navigationMapView {
                currentZoomLevel = navigationMapView.mapView.mapboxMap.cameraState.zoom
            }
        }
        
        print("🔵 MapboxNavigationView: Current zoom level: \(currentZoomLevel)")
        return currentZoomLevel
    }
    
    func setVisibleArea(visibleArea: [String: Any]) {
        print("🔵 MapboxNavigationView: setVisibleArea called")
        
        self.visibleArea = visibleArea
        
        // Update viewport padding based on visible area
        if let top = visibleArea["top"] as? Double,
           let left = visibleArea["left"] as? Double,
           let bottom = visibleArea["bottom"] as? Double,
           let right = visibleArea["right"] as? Double {
            
            let padding = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
            
            if let mapView = navigationMapView {
                if let navigationViewportDataSource = viewportDataSource as? NavigationViewportDataSource {
                    //navigationViewportDataSource.overviewPadding = padding
                    //navigationViewportDataSource.followingPadding = padding
                    //navigationViewportDataSource.evaluate()
                }
            } else if let navVC = navViewController {
                if let navigationMapView = navVC.navigationMapView {
                    if let navigationViewportDataSource = viewportDataSource as? NavigationViewportDataSource {
                        //navigationViewportDataSource.overviewPadding = padding
                        //navigationViewportDataSource.followingPadding = padding
                        //navigationViewportDataSource.evaluate()
                    }
                }
            }
        }
        
        print("🔵 MapboxNavigationView: Visible area set successfully")
    }

    private func embed() {
        print("🔵 MapboxNavigationView: embed() called")
        print("🔵 MapboxNavigationView: origin count: \(origin.count), destination count: \(destination.count)")
        
        embedding = true

        // Check if we have valid coordinates for navigation
        let hasValidCoordinates = origin.count == 2 && destination.count == 2
        
        if hasValidCoordinates {
            print("🔵 MapboxNavigationView: Valid coordinates provided, setting up navigation")
            setupNavigationWithRoute()
        } else {
            print("🔵 MapboxNavigationView: No valid coordinates, setting up free-drive mode")
            setupFreeDriveMode()
        }
    }
    
    private func setupNavigationWithRoute() {
        let originWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: origin[1] as! CLLocationDegrees, longitude: origin[0] as! CLLocationDegrees))
        let destinationWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: destination[1] as! CLLocationDegrees, longitude: destination[0] as! CLLocationDegrees))

        let options = NavigationRouteOptions(waypoints: [originWaypoint, destinationWaypoint], profileIdentifier: .automobileAvoidingTraffic)

        Directions.shared.calculate(options) { [weak self] (_, result) in
            guard let strongSelf = self, let parentVC = strongSelf.parentViewController else {
                return
            }

            switch result {
            case let .failure(error):
                print("🔴 MapboxNavigationView: Route calculation failed: \(error.localizedDescription)")
                strongSelf.onError?(["message": error.localizedDescription])
                // Fall back to free-drive mode if route calculation fails
                strongSelf.setupFreeDriveMode()
                
            case let .success(response):
                print("🔵 MapboxNavigationView: Route calculation successful")
                guard let weakSelf = self else {
                    return
                }

                let navigationService = MapboxNavigationService(routeResponse: response, routeIndex: 0, routeOptions: options, simulating: strongSelf.shouldSimulateRoute ? .always : .never)
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let vc = NavigationViewController(for: response, routeIndex: 0, routeOptions: options, navigationOptions: navigationOptions)

                strongSelf.configureNavigationViewController(vc)
                strongSelf.setupNavigationService(navigationService, response: response, options: options)
                strongSelf.embedViewController(vc, in: parentVC)
            }

            strongSelf.embedding = false
            strongSelf.embedded = true
        }
    }
    
    private func setupFreeDriveMode() {
        print("🔵 MapboxNavigationView: Setting up free-drive mode")
        
        // For free-drive navigation, we'll create a simple NavigationMapView directly
        // This avoids the need for dummy routes entirely
        let mapView = NavigationMapView(frame: bounds)
        self.navigationMapView = mapView
        
        // Set up passive location manager for free drive
        passiveLocationManager = PassiveLocationManager()
        
        // Configure viewport for passive navigation
        let newViewportDataSource = NavigationViewportDataSource(mapView.mapView, viewportDataSourceType: .passive)
        viewportDataSource = newViewportDataSource
        mapView.navigationCamera.viewportDataSource = newViewportDataSource
        mapView.navigationCamera.follow()
        
        // Set initial camera position
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let cameraOptions = CameraOptions(center: defaultCoordinate, zoom: 10.0)
        mapView.mapView.mapboxMap.setCamera(to: cameraOptions)
        
        // Apply map style if specified
        if !mapStyleURL.isEmpty {
            mapView.mapView.mapboxMap.style.styleManager.setStyleURIForUri(mapStyleURL)
        }
        
        // Add the navigation map view directly to our view
        addSubview(mapView)
        mapView.frame = bounds
        
        isFreeDriveActive = true
        embedding = false
        embedded = true
        
        print("🔵 MapboxNavigationView: Free-drive mode setup complete")
    }
    
    private func configureNavigationViewController(_ vc: NavigationViewController) {
        if !mapStyleURL.isEmpty {
            vc.navigationMapView?.mapView.mapboxMap.style.styleManager.setStyleURIForUri(mapStyleURL)
        }

        vc.showsReportFeedback = !hideReportFeedback
        vc.showsEndOfRouteFeedback = showsEndOfRouteFeedback

        if isCarplayView {
            vc.floatingButtonsPosition = .topTrailing
        }
        
        StatusView.appearance().isHidden = isCarplayView
        TopBannerView.appearance().isHidden = isCarplayView
        BottomBannerView.appearance().isHidden = isCarplayView
        InstructionsBannerView.appearance().isHidden = isCarplayView
        NextBannerView.appearance().isHidden = isCarplayView
        StepInstructionsView.appearance().isHidden = isCarplayView
        FloatingButton.appearance().isHidden = isCarplayView
        NavigationSettings.shared.voiceMuted = mute

        vc.delegate = self
    }
    
    private func setupNavigationService(_ navigationService: MapboxNavigationService, response: RouteResponse, options: NavigationRouteOptions) {
        navigationService.delegate = self
        
        // Store references for later use
        self.navigationService = navigationService
        self.currentRouteResponse = response
        self.currentRouteOptions = options
    }
    
    private func embedViewController(_ vc: NavigationViewController, in parentVC: UIViewController) {
        parentVC.addChild(vc)
        addSubview(vc.view)
        vc.view.frame = bounds
        vc.didMove(toParent: parentVC)
        navViewController = vc
        
        print("🔵 MapboxNavigationView: NavigationViewController embedded successfully")
    }

    func navigationViewController(_: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation _: CLLocation) {
        print("Did Update...")
        let routeInfo = extractRouteInfo(from: progress)

        onLocationChange?(["longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude])
        onRouteProgressChange?(["distanceTraveled": progress.distanceTraveled,
                                "durationRemaining": progress.durationRemaining,
                                "fractionTraveled": progress.fractionTraveled,
                                "distanceRemaining": progress.distanceRemaining,
                                "legIndex": progress.legIndex,
                                "currentStepIndex": progress.currentLegProgress.stepIndex,
                                "currentStepProgress": progress.currentLegProgress.currentStepProgress.distanceRemaining,
                                "route": routeInfo])
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

    // MARK: - NavigationServiceDelegate Methods

    func navigationServiceDidChangeAuthorization(_: NavigationService, didChangeAuthorizationFor _: CLAuthorizationStatus) {
        // Default implementation
        print("navigationServiceDidChangeAuthorization called")
    }

    func navigationService(_ service: NavigationService, shouldDiscard location: CLLocation) -> Bool {
        // Default implementation
        print("navigationService:shouldDiscard called")
        let shouldDiscard = navViewController?.navigationService(service, shouldDiscard: location)
        return shouldDiscard!
    }

    func navigationService(_: NavigationService, didUpdateAlternatives _: [Route], removedAlternatives _: [Route]) {
        // Default implementation
        print("navigationService:didUpdateAlternatives called")
        // self.navViewController?.navigationService(service, didUpdateAlternatives: updatedAlternatives, removedAlternatives: removedAlternatives)
    }

    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        // Default implementation
        print("navigationService:didUpdate called")
        navViewController?.navigationService(service, didUpdate: progress, with: location, rawLocation: rawLocation)
    }

    func navigationService(_ service: NavigationService, didPassSpokenInstructionPoint instruction: SpokenInstruction, routeProgress: RouteProgress) {
        // Default implementation
        print("navigationService:didPassSpokenInstructionPoint called")
        navViewController?.navigationService(service, didPassSpokenInstructionPoint: instruction, routeProgress: routeProgress)
    }

    func navigationService(_ service: NavigationService, shouldRerouteFrom location: CLLocation) -> Bool {
        // Default implementation
        print("navigationService:shouldRerouteFrom called")
        let shouldReroute = navViewController?.navigationService(service, shouldRerouteFrom: location)
        return shouldReroute!
    }

    func navigationService(_ service: NavigationService, willRerouteFrom location: CLLocation?) {
        // Default implementation
        print("navigationService:willRerouteFrom called")
        navViewController?.navigationService(service, willRerouteFrom: location!)
    }

    func navigationService(_ service: NavigationService, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
        // Default implementation
        print("navigationService:didRerouteAlong called")
        navViewController?.navigationService(service, didRerouteAlong: route, at: location!, proactive: proactive)
    }
    
    func navigationService(_ service: NavigationService, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        print("MapboxNavigationView didPassVisualInstructionPoint")

        if isCarplayView {
            // skip updating views; this should pass data to RN skope
            // so that Carplay Manager methods can be called to update Carplay UI
        } else {
            navViewController?.navigationService(service, didPassVisualInstructionPoint: instruction, routeProgress: routeProgress)
        }
    }

    private func applyStyles() {
        print("Applying styles...")

        if let styles = viewStyles as? [String: Any] {
            print("Styles dictionary: \(styles)")

            if let banners = styles["banner"] as? [String: String] {
                print("Banners: \(banners)")

                if let topBannerBackgroundColorString = banners["topBannerBackgroundColor"],
                   let topBannerBackgroundColor = UIColor(hex: topBannerBackgroundColorString)
                {
                    print("Setting topBannerBackgroundColor to \(topBannerBackgroundColor)")
                    TopBannerView.appearance(for: traitCollection).backgroundColor = topBannerBackgroundColor
                } else {
                    print("Failed to set topBannerBackgroundColor")
                }

                if let bottomBannerBackgroundColorString = banners["bottomBannerBackgroundColor"],
                   let bottomBannerBackgroundColor = UIColor(hex: bottomBannerBackgroundColorString)
                {
                    print("Setting bottomBannerBackgroundColor to \(bottomBannerBackgroundColor)")
                    BottomBannerView.appearance(for: traitCollection).backgroundColor = bottomBannerBackgroundColor
                } else {
                    print("Failed to set bottomBannerBackgroundColor")
                }

                if let instructionBannerBackgroundColorString = banners["instructionBannerBackgroundColor"],
                   let instructionBannerBackgroundColor = UIColor(hex: instructionBannerBackgroundColorString)
                {
                    print("Setting instructionBannerBackgroundColor to \(instructionBannerBackgroundColor)")
                    InstructionsBannerView.appearance(for: traitCollection).backgroundColor = instructionBannerBackgroundColor
                } else {
                    print("Failed to set instructionBannerBackgroundColor")
                }

                if let nextBannerBackgroundColorString = banners["nextBannerBackgroundColor"],
                   let nextBannerBackgroundColor = UIColor(hex: nextBannerBackgroundColorString)
                {
                    print("Setting nextBannerBackgroundColor to \(nextBannerBackgroundColor)")
                    NextBannerView.appearance(for: traitCollection).backgroundColor = nextBannerBackgroundColor
                } else {
                    print("Failed to set nextBannerBackgroundColor")
                }

                if let stepInstructionsBackgroundColorString = banners["stepInstructionsBackgroundColor"],
                   let stepInstructionsBackgroundColor = UIColor(hex: stepInstructionsBackgroundColorString)
                {
                    print("Setting stepInstructionsBackgroundColor to \(stepInstructionsBackgroundColor)")
                    StepInstructionsView.appearance(for: traitCollection).backgroundColor = stepInstructionsBackgroundColor
                } else {
                    print("Failed to set stepInstructionsBackgroundColor")
                }
            }

            if let maneuver = styles["maneuver"] as? [String: String] {
                if let primaryColorString = maneuver["primaryColor"],
                   let primaryColor = UIColor(hex: primaryColorString)
                {
                    print("Setting maneuver primaryColor to \(primaryColor)")
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColor = primaryColor
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [StepInstructionsView.self]).primaryColor = primaryColor
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).primaryColor = primaryColor
                } else {
                    print("Failed to set set maneuver instruction primary color")
                }

                if let secondaryColorString = maneuver["secondaryColor"],
                   let secondaryColor = UIColor(hex: secondaryColorString)
                {
                    print("Setting maneuver secondaryColor to \(secondaryColor)")
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColor = secondaryColor
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [StepInstructionsView.self]).secondaryColor = secondaryColor
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).secondaryColor = secondaryColor
                }

                if let primaryColorHighlightedString = maneuver["primaryColorHighlighted"],
                   let primaryColorHighlighted = UIColor(hex: primaryColorHighlightedString)
                {
                    print("Setting maneuver primaryColorHighlighted to \(primaryColorHighlighted)")
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColorHighlighted = primaryColorHighlighted
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [StepInstructionsView.self]).primaryColorHighlighted = primaryColorHighlighted
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).primaryColorHighlighted = primaryColorHighlighted
                }

                if let secondaryColorHighlightedString = maneuver["secondaryColorHighlighted"],
                   let secondaryColorHighlighted = UIColor(hex: secondaryColorHighlightedString)
                {
                    print("Setting maneuver secondaryColorHighlighted to \(secondaryColorHighlighted)")
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColorHighlighted = secondaryColorHighlighted
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [StepInstructionsView.self]).secondaryColorHighlighted = secondaryColorHighlighted
                    ManeuverView.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).secondaryColorHighlighted = secondaryColorHighlighted
                }
            }

            if let primary = styles["primary"] as? [String: String] {
                if let normalTextColorString = primary["normalTextColor"],
                   let normalTextColor = UIColor(hex: normalTextColorString)
                {
                    print("Setting primary normalTextColor to \(normalTextColor)")
                    PrimaryLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = normalTextColor
                    PrimaryLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = normalTextColor
                    NextInstructionLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [NextBannerView.self]).normalTextColor = normalTextColor
                }
            }

            if let secondary = styles["secondary"] as? [String: String] {
                if let normalTextColorString = secondary["normalTextColor"],
                   let normalTextColor = UIColor(hex: normalTextColorString)
                {
                    print("Setting secondary normalTextColor to \(normalTextColor)")
                    SecondaryLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = normalTextColor
                    SecondaryLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = normalTextColor
                }
            }

            if let distance = styles["distance"] as? [String: String] {
                if let unitTextColorString = distance["unitTextColor"],
                   let unitTextColor = UIColor(hex: unitTextColorString)
                {
                    print("Setting distance unitTextColor to \(unitTextColor)")
                    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).unitTextColor = unitTextColor
                    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [StepInstructionsView.self]).unitTextColor = unitTextColor
                }

                if let valueTextColorString = distance["valueTextColor"],
                   let valueTextColor = UIColor(hex: valueTextColorString)
                {
                    print("Setting distance valueTextColor to \(valueTextColor)")
                    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).valueTextColor = valueTextColor
                    DistanceLabel.appearance(for: traitCollection, whenContainedInInstancesOf: [StepInstructionsView.self]).valueTextColor = valueTextColor
                }
            }

            if let footer = styles["footer"] as? [String: String] {
                if let totalDistanceTextColorString = footer["totalDistanceTextColor"],
                   let totalDistanceTextColor = UIColor(hex: totalDistanceTextColorString)
                {
                    print("Setting totalDistanceTextColor to \(totalDistanceTextColor)")
                    DistanceRemainingLabel.appearance(for: traitCollection).normalTextColor = totalDistanceTextColor
                }

                if let arrivalTimeTextColorString = footer["arrivalTimeTextColor"],
                   let arrivalTimeTextColor = UIColor(hex: arrivalTimeTextColorString)
                {
                    print("Setting arrivalTimeTextColor to \(arrivalTimeTextColor)")
                    ArrivalTimeLabel.appearance(for: traitCollection).normalTextColor = arrivalTimeTextColor
                }
            }

            if let timeRemaining = styles["timeRemaining"] as? [String: String] {
                if let trafficUnknownColorString = timeRemaining["trafficUnknownColor"],
                   let trafficUnknownColor = UIColor(hex: trafficUnknownColorString)
                {
                    print("Setting trafficUnknownColor to \(trafficUnknownColor)")
                    TimeRemainingLabel.appearance(for: traitCollection).trafficUnknownColor = trafficUnknownColor
                }

                if let trafficLowColorString = timeRemaining["trafficLowColor"],
                   let trafficLowColor = UIColor(hex: trafficLowColorString)
                {
                    print("Setting trafficLowColor to \(trafficLowColor)")
                    TimeRemainingLabel.appearance(for: traitCollection).trafficLowColor = trafficLowColor
                }

                if let trafficModerateColorString = timeRemaining["trafficModerateColor"],
                   let trafficModerateColor = UIColor(hex: trafficModerateColorString)
                {
                    print("Setting trafficModerateColor to \(trafficModerateColor)")
                    TimeRemainingLabel.appearance(for: traitCollection).trafficModerateColor = trafficModerateColor
                }

                if let trafficHeavyColorString = timeRemaining["trafficHeavyColor"],
                   let trafficHeavyColor = UIColor(hex: trafficHeavyColorString)
                {
                    print("Setting trafficHeavyColor to \(trafficHeavyColor)")
                    TimeRemainingLabel.appearance(for: traitCollection).trafficHeavyColor = trafficHeavyColor
                }

                if let trafficSevereColorString = timeRemaining["trafficSevereColor"],
                   let trafficSevereColor = UIColor(hex: trafficSevereColorString)
                {
                    print("Setting trafficSevereColor to \(trafficSevereColor)")
                    TimeRemainingLabel.appearance(for: traitCollection).trafficSevereColor = trafficSevereColor
                }
            }

            if let floatingButtons = styles["floatingButtons"] as? [String: String] {
                if let tintColorString = floatingButtons["tintColor"],
                   let tintColor = UIColor(hex: tintColorString)
                {
                    print("Setting floatingButtons tintColor to \(tintColor)")
                    FloatingButton.appearance(for: traitCollection, whenContainedInInstancesOf: [NavigationView.self]).tintColor = tintColor
                }

                if let backgroundColorString = floatingButtons["backgroundColor"],
                   let backgroundColor = UIColor(hex: backgroundColorString)
                {
                    print("Setting floatingButtons backgroundColor to \(backgroundColor)")
                    FloatingButton.appearance(for: traitCollection, whenContainedInInstancesOf: [NavigationView.self]).backgroundColor = backgroundColor
                }

                if let borderColorString = floatingButtons["borderColor"],
                   let borderColor = UIColor(hex: borderColorString)
                {
                    print("Setting floatingButtons borderColor to \(borderColor)")
                    FloatingButton.appearance(for: traitCollection, whenContainedInInstancesOf: [NavigationView.self]).borderColor = borderColor
                }
            }

            if let statusView = styles["statusView"] as? [String: String] {
                if let statusViewBackgroundColorString = statusView["backgroundColor"],
                   let statusViewBackgroundColor = UIColor(hex: statusViewBackgroundColorString)
                {
                    print("Setting statusViewBackgroundColor to \(statusViewBackgroundColor)")
                    StatusView.appearance(for: traitCollection).backgroundColor = statusViewBackgroundColor
                } else {
                    print("Failed to set statusViewBackgroundColor")
                }

                if let statusViewTextColorString = statusView["textColor"],
                   let statusViewTextColor = UIColor(hex: statusViewTextColorString)
                {
                    print("Setting statusViewTextColor to \(statusViewTextColor)")
                    StatusView.appearance(for: traitCollection).tintColor = statusViewTextColor
                } else {
                    print("Failed to set statusViewTextColor")
                }
            }

            if let dismissButton = styles["dismissButton"] as? [String: String] {
                if let dismissButtonBackgroundColorString = dismissButton["backgroundColor"],
                   let dismissButtonBackgroundColor = UIColor(hex: dismissButtonBackgroundColorString)
                {
                    print("Setting dismissButtonBackgroundColor to \(dismissButtonBackgroundColor)")
                    DismissButton.appearance(for: traitCollection).backgroundColor = dismissButtonBackgroundColor
                } else {
                    print("Failed to set dismissButtonBackgroundColor")
                }

                if let dismissButtonTextColorString = dismissButton["textColor"],
                   let dismissButtonTextColor = UIColor(hex: dismissButtonTextColorString)
                {
                    print("Setting dismissButtonTextColor to \(dismissButtonTextColor)")
                    DismissButton.appearance(for: traitCollection).textColor = dismissButtonTextColor
                } else {
                    print("Failed to set dismissButtonTextColor")
                }
            }

            if let cancelButton = styles["cancelButton"] as? [String: String] {
                if let cancelButtonTextColorString = cancelButton["textColor"],
                   let cancelButtonTextColor = UIColor(hex: cancelButtonTextColorString)
                {
                    print("Setting cancelButtonColor to \(cancelButtonTextColor)")
                    CancelButton.appearance(for: traitCollection).tintColor = cancelButtonTextColor
                } else {
                    print("Failed to set cancelButtonTextColor")
                }
            }

            if let separatorView = styles["separatorView"] as? [String: String] {
                if let separatorViewBackgroundColorString = separatorView["backgroundColor"],
                   let separatorViewBackgroundColor = UIColor(hex: separatorViewBackgroundColorString)
                {
                    print("Setting separatorViewBackgroundColor to \(separatorViewBackgroundColor)")
                    SeparatorView.appearance(for: traitCollection).backgroundColor = separatorViewBackgroundColor
                } else {
                    print("Failed to set separatorViewBackgroundColor")
                }
            }
        } else {
            print("Styles dictionary is not in the expected format.")
        }
    }

    private func extractRouteInfo(from progress: RouteProgress?) -> [String: Any] {
        guard let progress = progress else { return [:] }

        let route = progress.route
        let legs = route.legs.map { leg -> [String: Any] in
            let steps = leg.steps.map { step -> [String: Any] in

                var visualInstructions: [[String: Any]] = []

                if let instructions = step.instructionsDisplayedAlongStep {
                    visualInstructions = instructions.map { instruction -> [String: Any] in
                        var instructionInfo: [String: Any] = [:]

                        if let primaryInstruction = instruction.primaryInstruction.text {
                            instructionInfo["primaryText"] = primaryInstruction
                        }

                        if let secondaryInstruction = instruction.secondaryInstruction?.text {
                            instructionInfo["secondaryText"] = secondaryInstruction
                        }

                        if let maneuverType = instruction.primaryInstruction.maneuverType {
                            instructionInfo["maneuverType"] = maneuverType.rawValue
                        }

                        if let maneuverDirection = instruction.primaryInstruction.maneuverDirection {
                            instructionInfo["maneuverDirection"] = maneuverDirection.rawValue
                        }

                        for component in instruction.primaryInstruction.components {
                            if case let .image(imageRepresentation, _) = component {
                                if let url = imageRepresentation.imageURL(scale: nil, format: .png) {
                                    instructionInfo["imageURL"] = url.absoluteString
                                }
                            }
                        }

                        return instructionInfo
                    }
                }
                return [
                    "distance": step.distance,
                    "expectedTravelTime": step.expectedTravelTime,
                    "instructions": step.instructions,
                    "maneuverType": step.maneuverType.rawValue,
                    "maneuverDirection": step.maneuverDirection?.rawValue ?? "",
                    "visualInstruction": visualInstructions,
                ]
            }

            return [
                "distance": leg.distance,
                "expectedTravelTime": leg.expectedTravelTime,
                "steps": steps,
            ]
        }

        return [
            "distance": route.distance,
            "expectedTravelTime": route.expectedTravelTime,
            "legs": legs,
        ]
    }
}
