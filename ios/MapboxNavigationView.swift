import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

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

extension UIColor {
  public convenience init?(hex: String) {
    let r, g, b, a: CGFloat

    if hex.hasPrefix("#") {
      let start = hex.index(hex.startIndex, offsetBy: 1)
      let hexColor = String(hex[start...])

      if hexColor.count == 8 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
          g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
          b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
          a = CGFloat(hexNumber & 0x000000ff) / 255

          self.init(red: r, green: g, blue: b, alpha: a)
          return
        }
      }
    }

    return nil
  }
}

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

  @objc var viewStyles: NSDictionary = [:]
  
  @objc var shouldSimulateRoute: Bool = false
  @objc var showsEndOfRouteFeedback: Bool = false
  @objc var hideStatusView: Bool = false
  @objc var mute: Bool = false
  @objc var showsReportFeedback: Bool = false
  
  @objc var onLocationChange: RCTDirectEventBlock?
  @objc var onRouteProgressChange: RCTDirectEventBlock?
  @objc var onError: RCTDirectEventBlock?
  @objc var onCancelNavigation: RCTDirectEventBlock?
  @objc var onArrive: RCTDirectEventBlock?
  
  override init(frame: CGRect) {
    self.embedded = false
    self.embedding = false
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if (navViewController == nil && !embedding && !embedded) {
      embed()
      applyStyles()
    } else {
      navViewController?.view.frame = bounds
    }
  }
  
  override func removeFromSuperview() {
    super.removeFromSuperview()
    // cleanup and teardown any existing resources
    self.navViewController?.removeFromParent()
  }
  
  private func embed() {
    guard origin.count == 2 && destination.count == 2 else { return }
    
    embedding = true

    let originWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: origin[1] as! CLLocationDegrees, longitude: origin[0] as! CLLocationDegrees))
    let destinationWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: destination[1] as! CLLocationDegrees, longitude: destination[0] as! CLLocationDegrees))

    // let options = NavigationRouteOptions(waypoints: [originWaypoint, destinationWaypoint])
    let options = NavigationRouteOptions(waypoints: [originWaypoint, destinationWaypoint], profileIdentifier: .automobileAvoidingTraffic)

    Directions.shared.calculate(options) { [weak self] (_, result) in
      guard let strongSelf = self, let parentVC = strongSelf.parentViewController else {
        return
      }
      
      switch result {
        case .failure(let error):
          strongSelf.onError!(["message": error.localizedDescription])
        case .success(let response):
          guard let weakSelf = self else {
            return
          }
          
          let navigationService = MapboxNavigationService(routeResponse: response, routeIndex: 0, routeOptions: options, simulating: strongSelf.shouldSimulateRoute ? .always : .never)
          
          let navigationOptions = NavigationOptions(navigationService: navigationService)
          let vc = NavigationViewController(for: response, routeIndex: 0, routeOptions: options, navigationOptions: navigationOptions)
          
          vc.showsReportFeedback = strongSelf.showsReportFeedback
          vc.showsEndOfRouteFeedback = strongSelf.showsEndOfRouteFeedback
          StatusView.appearance().isHidden = strongSelf.hideStatusView

          NavigationSettings.shared.voiceMuted = strongSelf.mute;
          
          vc.delegate = strongSelf
        
          parentVC.addChild(vc)
          strongSelf.addSubview(vc.view)
          vc.view.frame = strongSelf.bounds
          vc.didMove(toParent: parentVC)
          strongSelf.navViewController = vc
      }
      
      strongSelf.embedding = false
      strongSelf.embedded = true
    }
  }
  
  func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
    onLocationChange?(["longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude])
    onRouteProgressChange?(["distanceTraveled": progress.distanceTraveled,
                            "durationRemaining": progress.durationRemaining,
                            "fractionTraveled": progress.fractionTraveled,
                            "distanceRemaining": progress.distanceRemaining])
  }
  
  func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
    if (!canceled) {
      return;
    }
    onCancelNavigation?(["message": ""]);
  }
  
  func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
    onArrive?(["message": ""]);
    return true;
  }
    
  private func applyStyles() {
    print("Applying styles...")

    if let styles = viewStyles as? [String: Any] {
      print("Styles dictionary: \(styles)")

      let test = styles["topBannerBackgroundColor"]
      print("Top Banner Test: \(styles["topBannerBackgroundColor"])")

      if let banners = styles["banner"] as? [String: String] {
        if let topBannerBackgroundColorString = banners["topBannerBackgroundColor"] as? String,
          let topBannerBackgroundColor = UIColor(hex: topBannerBackgroundColorString) {
          print("Setting topBannerBackgroundColor to \(topBannerBackgroundColor)")
          TopBannerView.appearance(for: self.traitCollection).backgroundColor = topBannerBackgroundColor
        } else {
          print("Failed to set topBannerBackgroundColor")
        }

        if let bottomBannerBackgroundColorString = banners["bottomBannerBackgroundColor"] as? String,
          let bottomBannerBackgroundColor = UIColor(hex: bottomBannerBackgroundColorString) {
          print("Setting bottomBannerBackgroundColor to \(bottomBannerBackgroundColor)")
          BottomBannerView.appearance(for: self.traitCollection).backgroundColor = bottomBannerBackgroundColor
        } else {
          print("Failed to set bottomBannerBackgroundColor")
        }

        if let instructionBannerBackgroundColorString = banners["instructionBannerBackgroundColor"] as? String,
          let instructionBannerBackgroundColor = UIColor(hex: instructionBannerBackgroundColorString) {
          print("Setting instructionBannerBackgroundColor to \(instructionBannerBackgroundColor)")
          InstructionsBannerView.appearance(for: self.traitCollection).backgroundColor = instructionBannerBackgroundColor
        } else {
          print("Failed to set instructionBannerBackgroundColor")
        }

        if let stepInstructionsBackgroundColorString = banners["stepInstructionsBackgroundColor"] as? String,
          let stepInstructionsBackgroundColor = UIColor(hex: stepInstructionsBackgroundColorString) {
          print("Setting stepInstructionsBackgroundColor to \(stepInstructionsBackgroundColor)")
          StepInstructionsView.appearance(for: self.traitCollection).backgroundColor = stepInstructionsBackgroundColor
        } else {
          print("Failed to set stepInstructionsBackgroundColor")
        }
      }

      if let maneuver = styles["maneuver"] as? [String: String] {
        if let primaryColorString = maneuver["primaryColor"],
          let primaryColor = UIColor(hex: primaryColorString) {
          print("Setting maneuver primaryColor to \(primaryColor)")
           ManeuverView.appearance(for: self.traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColor = primaryColor
        }
        
        if let secondaryColorString = maneuver["secondaryColor"],
          let secondaryColor = UIColor(hex: secondaryColorString) {
          print("Setting maneuver secondaryColor to \(secondaryColor)")
           ManeuverView.appearance(for: self.traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColor = secondaryColor
        }

        if let primaryColorHighlightedString = maneuver["primaryColorHighlighted"],
          let primaryColorHighlighted = UIColor(hex: primaryColorHighlightedString) {
          print("Setting maneuver primaryColorHighlighted to \(primaryColorHighlighted)")
          ManeuverView.appearance(for: self.traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColorHighlighted = primaryColorHighlighted
        }
        
        if let secondaryColorHighlightedString = maneuver["secondaryColorHighlighted"],
          let secondaryColorHighlighted = UIColor(hex: secondaryColorHighlightedString) {
          print("Setting maneuver secondaryColorHighlighted to \(secondaryColorHighlighted)")
          ManeuverView.appearance(for: self.traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColorHighlighted = secondaryColorHighlighted
        }
      }

      if let primary = styles["primary"] as? [String: String] {
        if let normalTextColorString = primary["normalTextColor"],
          let normalTextColor = UIColor(hex: normalTextColorString) {
          print("Setting primary normalTextColor to \(normalTextColor)")
          PrimaryLabel.appearance(for: self.traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = normalTextColor
        }
      }
          
      if let secondary = styles["secondary"] as? [String: String] {
        if let normalTextColorString = secondary["normalTextColor"],
          let normalTextColor = UIColor(hex: normalTextColorString) {
          print("Setting secondary normalTextColor to \(normalTextColor)")
          SecondaryLabel.appearance(for: self.traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = normalTextColor
        }
      }
          
      if let distance = styles["distance"] as? [String: String] {
        if let unitTextColorString = distance["unitTextColor"],
          let unitTextColor = UIColor(hex: unitTextColorString) {
          print("Setting distance unitTextColor to \(unitTextColor)")
          DistanceLabel.appearance(for: self.traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).unitTextColor = unitTextColor
        }
            
        if let valueTextColorString = distance["valueTextColor"],
          let valueTextColor = UIColor(hex: valueTextColorString) {
          print("Setting distance valueTextColor to \(valueTextColor)")
          DistanceLabel.appearance(for: self.traitCollection, whenContainedInInstancesOf: [InstructionsBannerView.self]).valueTextColor = valueTextColor
        }
      }
      
      if let floatingButtons = styles["floatingButtons"] as? [String: String] {
        if let tintColorString = floatingButtons["tintColor"],
          let tintColor = UIColor(hex: tintColorString) {
          print("Setting floatingButtons tintColor to \(tintColor)")
          FloatingButton.appearance(for: self.traitCollection, whenContainedInInstancesOf: [NavigationView.self]).tintColor = tintColor
        }
            
        if let backgroundColorString = floatingButtons["backgroundColor"],
          let backgroundColor = UIColor(hex: backgroundColorString) {
          print("Setting floatingButtons backgroundColor to \(backgroundColor)")
          FloatingButton.appearance(for: self.traitCollection, whenContainedInInstancesOf: [NavigationView.self]).backgroundColor = backgroundColor
        }
        
        
        if let borderColorString = floatingButtons["borderColor"],
          let borderColor = UIColor(hex: borderColorString) {
          print("Setting floatingButtons borderColor to \(borderColor)")
          FloatingButton.appearance(for: self.traitCollection, whenContainedInInstancesOf: [NavigationView.self]).borderColor = borderColor
        }
      }
    } else {
      print("Styles dictionary is not in the expected format.")
    }
  }
}
