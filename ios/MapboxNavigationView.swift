import MapboxDirections
import MapboxNavigationCore
import MapboxNavigationUIKit
import React

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
class MapboxNavigationView: UIView, NavigationViewControllerDelegate {
    weak var navViewController: NavigationViewController?
    var embedded: Bool
    var embedding: Bool

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
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if navViewController == nil && !embedding && !embedded {
            embed()
            applyStyles()
        } else {
            navViewController?.view.frame = bounds
        }
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        // cleanup and teardown any existing resources
        navViewController?.removeFromParent()
    }

    private func embed() {
        guard origin.count == 2 && destination.count == 2 else { return }

        embedding = true

        let originWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: origin[1] as! CLLocationDegrees, longitude: origin[0] as! CLLocationDegrees))
        let destinationWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: destination[1] as! CLLocationDegrees, longitude: destination[0] as! CLLocationDegrees))

        let options = NavigationRouteOptions(waypoints: [originWaypoint, destinationWaypoint], profileIdentifier: .automobileAvoidingTraffic)

        // Create navigation provider
        let navigationProvider = MapboxNavigationProvider(coreConfig: CoreConfig())
        
        Task {
            do {
                let routesResponse = try await navigationProvider.routingProvider().calculateRoutes(options: options).value
                
                guard let parentVC = self.parentViewController else { return }
                
                // Create navigation options
                let navigationOptions = NavigationOptions(
                    mapboxNavigation: navigationProvider.mapboxNavigation,
                    voiceController: navigationProvider.routeVoiceController,
                    eventsManager: navigationProvider.eventsManager(),
                    styles: [NightStyle()],
                    predictiveCacheManager: navigationProvider.predictiveCacheManager
                )
                
                // Create navigation view controller
                let vc = NavigationViewController(
                    navigationRoutes: routesResponse,
                    navigationOptions: navigationOptions
                )

//                if !self.mapStyleURL.isEmpty {
//                    vc.navigationMapView?.mapView.mapboxMap.style.styleManager.setStyleURIForUri(self.mapStyleURL)
//                }

                vc.showsReportFeedback = !self.hideReportFeedback
                vc.showsEndOfRouteFeedback = self.showsEndOfRouteFeedback

                if self.isCarplayView {
                    vc.floatingButtonsPosition = .topTrailing
                }
                
                // Hide UI elements for CarPlay
                StatusView.appearance().isHidden = self.isCarplayView
                TopBannerView.appearance().isHidden = self.isCarplayView
                BottomBannerView.appearance().isHidden = self.isCarplayView
                InstructionsBannerView.appearance().isHidden = self.isCarplayView
                NextBannerView.appearance().isHidden = self.isCarplayView
                StepInstructionsView.appearance().isHidden = self.isCarplayView
                FloatingButton.appearance().isHidden = self.isCarplayView
                
                //NavigationSettings.shared.voiceMuted = self.mute

                vc.delegate = self

                parentVC.addChild(vc)
                self.addSubview(vc.view)
                vc.view.frame = self.bounds
                vc.didMove(toParent: parentVC)
                self.navViewController = vc
                
                self.embedding = false
                self.embedded = true
                
            } catch {
                self.onError?(["message": error.localizedDescription])
                self.embedding = false
            }
        }
    }

    // MARK: - NavigationViewControllerDelegate
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        let routeInfo = extractRouteInfo(from: progress)

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

    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        if canceled {
            onCancelNavigation?(["message": ""])
        }
    }

    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        onArrive?(["message": ""])
        return true
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
//                                if let url = imageRepresentation.imageURL(scale: nil, format: .png) {
//                                    instructionInfo["imageURL"] = url.absoluteString
//                                }
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
