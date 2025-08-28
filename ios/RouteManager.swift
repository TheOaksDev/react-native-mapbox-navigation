import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import MapboxMaps

class RouteManager {
    
    // MARK: - Properties
    weak var delegate: RouteManagerDelegate?
    private var currentRouteResponse: RouteResponse?
    private var currentRouteOptions: NavigationRouteOptions?
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Public Methods
    
    func calculateRoute(from origin: [Double], to destination: [Double], completion: @escaping (Result<RouteResponse, Error>) -> Void) {
        print("🔵 RouteManager: calculateRoute called")
        
        guard origin.count == 2, destination.count == 2 else {
            let error = NSError(domain: "RouteManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid coordinates"])
            completion(.failure(error))
            return
        }
        
        let originWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: origin[1], longitude: origin[0]))
        let destinationWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: destination[1], longitude: destination[0]))
        
        let options = NavigationRouteOptions(waypoints: [originWaypoint, destinationWaypoint], profileIdentifier: .automobileAvoidingTraffic)
        
        Directions.shared.calculate(options) { [weak self] (_, result) in
            switch result {
            case .failure(let error):
                print("🔴 RouteManager: Route calculation failed: \(error.localizedDescription)")
                completion(.failure(error))
                
            case .success(let response):
                print("🔵 RouteManager: Route calculation successful")
                self?.currentRouteResponse = response
                self?.currentRouteOptions = options
                completion(.success(response))
            }
        }
    }
    
    func calculateRoutePreview(coordinates: [[String: Any]], completion: @escaping (Result<RouteResponse, Error>) -> Void) {
        print("🔵 RouteManager: calculateRoutePreview called with \(coordinates.count) coordinates")
        
        guard coordinates.count >= 2 else {
            let error = NSError(domain: "RouteManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "At least two coordinates required"])
            completion(.failure(error))
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
            let error = NSError(domain: "RouteManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid coordinates"])
            completion(.failure(error))
            return
        }
        
        // Create route options
        let routeOptions = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: .automobileAvoidingTraffic)
        
        // Calculate route
        Directions.shared.calculate(routeOptions) { [weak self] (_, result) in
            switch result {
            case .failure(let error):
                print("🔴 RouteManager: Route preview calculation failed: \(error.localizedDescription)")
                completion(.failure(error))
                
            case .success(let response):
                print("🔵 RouteManager: Route preview calculated successfully")
                self?.currentRouteResponse = response
                self?.currentRouteOptions = routeOptions
                completion(.success(response))
            }
        }
    }
    
    func clearRoutes() {
        print("🔵 RouteManager: clearRoutes called")
        currentRouteResponse = nil
        currentRouteOptions = nil
    }
    
    func getCurrentRouteResponse() -> RouteResponse? {
        return currentRouteResponse
    }
    
    func getCurrentRouteOptions() -> NavigationRouteOptions? {
        return currentRouteOptions
    }
    
    func extractRouteInfo(from progress: RouteProgress?) -> [String: Any] {
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

// MARK: - RouteManagerDelegate Protocol
protocol RouteManagerDelegate: AnyObject {
    func routeManager(_ manager: RouteManager, didCalculateRoute response: RouteResponse)
    func routeManager(_ manager: RouteManager, didFailWithError error: Error)
}

// MARK: - Optional Protocol Extensions
extension RouteManagerDelegate {
    func routeManager(_ manager: RouteManager, didCalculateRoute response: RouteResponse) {}
    func routeManager(_ manager: RouteManager, didFailWithError error: Error) {}
}