import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import MapboxMaps

class NavigationServiceManager: NSObject, NavigationServiceDelegate {
    
    // MARK: - Properties
    weak var delegate: NavigationServiceManagerDelegate?
    private var navigationService: MapboxNavigationService?
    private var currentRouteResponse: RouteResponse?
    private var currentRouteOptions: NavigationRouteOptions?
    private var passiveLocationManager: PassiveLocationManager?
    
    // MARK: - Navigation State
    private(set) var isNavigationActive: Bool = false
    private(set) var isFreeDriveActive: Bool = false
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    func startNavigation() {
        print("🔵 NavigationServiceManager: startNavigation called")
        
        if let navigationService = navigationService {
            print("🔵 NavigationServiceManager: Starting route-based navigation")
            isNavigationActive = true
            navigationService.start()
            delegate?.navigationServiceManager(self, didStartNavigation: true)
        } else {
            print("🔵 NavigationServiceManager: No route available, starting free-drive navigation")
            isNavigationActive = true
            isFreeDriveActive = true
            startFreeDrive()
            delegate?.navigationServiceManager(self, didStartNavigation: false)
        }
    }
    
    func stopNavigation() {
        print("🔵 NavigationServiceManager: stopNavigation called")
        
        isNavigationActive = false
        navigationService?.stop()
        stopFreeDrive()
        delegate?.navigationServiceManager(self, didStopNavigation: true)
    }
    
    func startFreeDrive() {
        print("🔵 NavigationServiceManager: startFreeDrive called")
        
        isFreeDriveActive = true
        passiveLocationManager = PassiveLocationManager()
        delegate?.navigationServiceManager(self, didStartFreeDrive: true)
    }
    
    func stopFreeDrive() {
        print("🔵 NavigationServiceManager: stopFreeDrive called")
        
        isFreeDriveActive = false
        passiveLocationManager = nil
        delegate?.navigationServiceManager(self, didStopFreeDrive: true)
    }
    
    func setupNavigationService(with response: RouteResponse, options: NavigationRouteOptions) {
        print("🔵 NavigationServiceManager: setupNavigationService called")
        
        let service = MapboxNavigationService(routeResponse: response, routeIndex: 0, routeOptions: options, simulating: .never)
        service.delegate = self
        
        self.navigationService = service
        self.currentRouteResponse = response
        self.currentRouteOptions = options
        
        delegate?.navigationServiceManager(self, didSetupNavigationService: service)
    }
    
    func clearNavigationService() {
        navigationService = nil
        currentRouteResponse = nil
        currentRouteOptions = nil
    }
    
    // MARK: - NavigationServiceDelegate
    
    func navigationServiceDidChangeAuthorization(_ service: NavigationService, didChangeAuthorizationFor status: CLAuthorizationStatus) {
        print("NavigationServiceManager: navigationServiceDidChangeAuthorization called")
        delegate?.navigationServiceManager(self, didChangeAuthorization: status)
    }
    
    func navigationService(_ service: NavigationService, shouldDiscard location: CLLocation) -> Bool {
        print("NavigationServiceManager: shouldDiscard called")
        return false // Default implementation
    }
    
    func navigationService(_ service: NavigationService, didUpdateAlternatives updatedAlternatives: [Route], removedAlternatives: [Route]) {
        print("NavigationServiceManager: didUpdateAlternatives called")
        delegate?.navigationServiceManager(self, didUpdateAlternatives: updatedAlternatives, removedAlternatives: removedAlternatives)
    }
    
    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        print("NavigationServiceManager: didUpdate called")
        delegate?.navigationServiceManager(self, didUpdateProgress: progress, with: location, rawLocation: rawLocation)
    }
    
    func navigationService(_ service: NavigationService, didPassSpokenInstructionPoint instruction: SpokenInstruction, routeProgress: RouteProgress) {
        print("NavigationServiceManager: didPassSpokenInstructionPoint called")
        delegate?.navigationServiceManager(self, didPassSpokenInstructionPoint: instruction, routeProgress: routeProgress)
    }
    
    func navigationService(_ service: NavigationService, shouldRerouteFrom location: CLLocation) -> Bool {
        print("NavigationServiceManager: shouldRerouteFrom called")
        return true // Default implementation
    }
    
    func navigationService(_ service: NavigationService, willRerouteFrom location: CLLocation?) {
        print("NavigationServiceManager: willRerouteFrom called")
        delegate?.navigationServiceManager(self, willRerouteFrom: location)
    }
    
    func navigationService(_ service: NavigationService, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
        print("NavigationServiceManager: didRerouteAlong called")
        delegate?.navigationServiceManager(self, didRerouteAlong: route, at: location, proactive: proactive)
    }
    
    func navigationService(_ service: NavigationService, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        print("NavigationServiceManager: didPassVisualInstructionPoint called")
        delegate?.navigationServiceManager(self, didPassVisualInstructionPoint: instruction, routeProgress: routeProgress)
    }
}

// MARK: - NavigationServiceManagerDelegate Protocol
protocol NavigationServiceManagerDelegate: AnyObject {
    func navigationServiceManager(_ manager: NavigationServiceManager, didStartNavigation isRouteBased: Bool)
    func navigationServiceManager(_ manager: NavigationServiceManager, didStopNavigation: Bool)
    func navigationServiceManager(_ manager: NavigationServiceManager, didStartFreeDrive: Bool)
    func navigationServiceManager(_ manager: NavigationServiceManager, didStopFreeDrive: Bool)
    func navigationServiceManager(_ manager: NavigationServiceManager, didSetupNavigationService service: MapboxNavigationService)
    func navigationServiceManager(_ manager: NavigationServiceManager, didChangeAuthorization status: CLAuthorizationStatus)
    func navigationServiceManager(_ manager: NavigationServiceManager, didUpdateAlternatives updatedAlternatives: [Route], removedAlternatives: [Route])
    func navigationServiceManager(_ manager: NavigationServiceManager, didUpdateProgress progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation)
    func navigationServiceManager(_ manager: NavigationServiceManager, didPassSpokenInstructionPoint instruction: SpokenInstruction, routeProgress: RouteProgress)
    func navigationServiceManager(_ manager: NavigationServiceManager, willRerouteFrom location: CLLocation?)
    func navigationServiceManager(_ manager: NavigationServiceManager, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool)
    func navigationServiceManager(_ manager: NavigationServiceManager, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress)
}

// MARK: - Optional Protocol Extensions
extension NavigationServiceManagerDelegate {
    func navigationServiceManager(_ manager: NavigationServiceManager, didStartNavigation isRouteBased: Bool) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didStopNavigation: Bool) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didStartFreeDrive: Bool) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didStopFreeDrive: Bool) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didSetupNavigationService service: MapboxNavigationService) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didChangeAuthorization status: CLAuthorizationStatus) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didUpdateAlternatives updatedAlternatives: [Route], removedAlternatives: [Route]) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didUpdateProgress progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didPassSpokenInstructionPoint instruction: SpokenInstruction, routeProgress: RouteProgress) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, willRerouteFrom location: CLLocation?) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {}
    func navigationServiceManager(_ manager: NavigationServiceManager, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {}
}
