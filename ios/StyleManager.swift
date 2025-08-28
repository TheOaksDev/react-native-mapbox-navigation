import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import MapboxMaps

class StyleManager {
    
    // MARK: - Properties
    private var viewStyles: [String: Any] = [:]
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Public Methods
    
    func setStyles(_ styles: [String: Any]) {
        print("🔵 StyleManager: setStyles called")
        self.viewStyles = styles
        applyStyles()
    }
    
    func applyStyles() {
        print("🔵 StyleManager: applyStyles called")

        if let styles = viewStyles as? [String: Any] {
            print("🔵 StyleManager: Styles dictionary: \(styles)")

            applyBannerStyles(styles["banner"] as? [String: String])
            applyManeuverStyles(styles["maneuver"] as? [String: String])
            applyPrimaryStyles(styles["primary"] as? [String: String])
            applySecondaryStyles(styles["secondary"] as? [String: String])
            applyDistanceStyles(styles["distance"] as? [String: String])
            applyFooterStyles(styles["footer"] as? [String: String])
            applyTimeRemainingStyles(styles["timeRemaining"] as? [String: String])
            applyFloatingButtonStyles(styles["floatingButtons"] as? [String: String])
            applyStatusViewStyles(styles["statusView"] as? [String: String])
            applyDismissButtonStyles(styles["dismissButton"] as? [String: String])
            applyCancelButtonStyles(styles["cancelButton"] as? [String: String])
            applySeparatorViewStyles(styles["separatorView"] as? [String: String])
        } else {
            print("🔴 StyleManager: Styles dictionary is not in the expected format.")
        }
    }
    
    // MARK: - Private Methods
    
    private func applyBannerStyles(_ banners: [String: String]?) {
        guard let banners = banners else { return }
        
        print("🔵 StyleManager: Applying banner styles: \(banners)")

        if let topBannerBackgroundColorString = banners["topBannerBackgroundColor"],
           let topBannerBackgroundColor = UIColor(hex: topBannerBackgroundColorString) {
            print("🔵 StyleManager: Setting topBannerBackgroundColor to \(topBannerBackgroundColor)")
            TopBannerView.appearance().backgroundColor = topBannerBackgroundColor
        }

        if let bottomBannerBackgroundColorString = banners["bottomBannerBackgroundColor"],
           let bottomBannerBackgroundColor = UIColor(hex: bottomBannerBackgroundColorString) {
            print("🔵 StyleManager: Setting bottomBannerBackgroundColor to \(bottomBannerBackgroundColor)")
            BottomBannerView.appearance().backgroundColor = bottomBannerBackgroundColor
        }

        if let instructionBannerBackgroundColorString = banners["instructionBannerBackgroundColor"],
           let instructionBannerBackgroundColor = UIColor(hex: instructionBannerBackgroundColorString) {
            print("🔵 StyleManager: Setting instructionBannerBackgroundColor to \(instructionBannerBackgroundColor)")
            InstructionsBannerView.appearance().backgroundColor = instructionBannerBackgroundColor
        }

        if let nextBannerBackgroundColorString = banners["nextBannerBackgroundColor"],
           let nextBannerBackgroundColor = UIColor(hex: nextBannerBackgroundColorString) {
            print("🔵 StyleManager: Setting nextBannerBackgroundColor to \(nextBannerBackgroundColor)")
            NextBannerView.appearance().backgroundColor = nextBannerBackgroundColor
        }

        if let stepInstructionsBackgroundColorString = banners["stepInstructionsBackgroundColor"],
           let stepInstructionsBackgroundColor = UIColor(hex: stepInstructionsBackgroundColorString) {
            print("🔵 StyleManager: Setting stepInstructionsBackgroundColor to \(stepInstructionsBackgroundColor)")
            StepInstructionsView.appearance().backgroundColor = stepInstructionsBackgroundColor
        }
    }
    
    private func applyManeuverStyles(_ maneuver: [String: String]?) {
        guard let maneuver = maneuver else { return }
        
        if let primaryColorString = maneuver["primaryColor"],
           let primaryColor = UIColor(hex: primaryColorString) {
            print("🔵 StyleManager: Setting maneuver primaryColor to \(primaryColor)")
            ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColor = primaryColor
            ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).primaryColor = primaryColor
            ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).primaryColor = primaryColor
        }

        if let secondaryColorString = maneuver["secondaryColor"],
           let secondaryColor = UIColor(hex: secondaryColorString) {
            print("🔵 StyleManager: Setting maneuver secondaryColor to \(secondaryColor)")
            ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColor = secondaryColor
            ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).secondaryColor = secondaryColor
            ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).secondaryColor = secondaryColor
        }

        if let primaryColorHighlightedString = maneuver["primaryColorHighlighted"],
           let primaryColorHighlighted = UIColor(hex: primaryColorHighlightedString) {
            print("🔵 StyleManager: Setting maneuver primaryColorHighlighted to \(primaryColorHighlighted)")
            ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColorHighlighted = primaryColorHighlighted
            ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).primaryColorHighlighted = primaryColorHighlighted
            ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).primaryColorHighlighted = primaryColorHighlighted
        }

        if let secondaryColorHighlightedString = maneuver["secondaryColorHighlighted"],
           let secondaryColorHighlighted = UIColor(hex: secondaryColorHighlightedString) {
            print("🔵 StyleManager: Setting maneuver secondaryColorHighlighted to \(secondaryColorHighlighted)")
            ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColorHighlighted = secondaryColorHighlighted
            ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).secondaryColorHighlighted = secondaryColorHighlighted
            ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).secondaryColorHighlighted = secondaryColorHighlighted
        }
    }
    
    private func applyPrimaryStyles(_ primary: [String: String]?) {
        guard let primary = primary else { return }
        
        if let normalTextColorString = primary["normalTextColor"],
           let normalTextColor = UIColor(hex: normalTextColorString) {
            print("🔵 StyleManager: Setting primary normalTextColor to \(normalTextColor)")
            PrimaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = normalTextColor
            PrimaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = normalTextColor
            NextInstructionLabel.appearance(whenContainedInInstancesOf: [NextBannerView.self]).normalTextColor = normalTextColor
        }
    }
    
    private func applySecondaryStyles(_ secondary: [String: String]?) {
        guard let secondary = secondary else { return }
        
        if let normalTextColorString = secondary["normalTextColor"],
           let normalTextColor = UIColor(hex: normalTextColorString) {
            print("🔵 StyleManager: Setting secondary normalTextColor to \(normalTextColor)")
            SecondaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = normalTextColor
            SecondaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = normalTextColor
        }
    }
    
    private func applyDistanceStyles(_ distance: [String: String]?) {
        guard let distance = distance else { return }
        
        if let unitTextColorString = distance["unitTextColor"],
           let unitTextColor = UIColor(hex: unitTextColorString) {
            print("🔵 StyleManager: Setting distance unitTextColor to \(unitTextColor)")
            DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).unitTextColor = unitTextColor
            DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).unitTextColor = unitTextColor
        }

        if let valueTextColorString = distance["valueTextColor"],
           let valueTextColor = UIColor(hex: valueTextColorString) {
            print("🔵 StyleManager: Setting distance valueTextColor to \(valueTextColor)")
            DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).valueTextColor = valueTextColor
            DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).valueTextColor = valueTextColor
        }
    }
    
    private func applyFooterStyles(_ footer: [String: String]?) {
        guard let footer = footer else { return }
        
        if let totalDistanceTextColorString = footer["totalDistanceTextColor"],
           let totalDistanceTextColor = UIColor(hex: totalDistanceTextColorString) {
            print("🔵 StyleManager: Setting totalDistanceTextColor to \(totalDistanceTextColor)")
            DistanceRemainingLabel.appearance().normalTextColor = totalDistanceTextColor
        }

        if let arrivalTimeTextColorString = footer["arrivalTimeTextColor"],
           let arrivalTimeTextColor = UIColor(hex: arrivalTimeTextColorString) {
            print("🔵 StyleManager: Setting arrivalTimeTextColor to \(arrivalTimeTextColor)")
            ArrivalTimeLabel.appearance().normalTextColor = arrivalTimeTextColor
        }
    }
    
    private func applyTimeRemainingStyles(_ timeRemaining: [String: String]?) {
        guard let timeRemaining = timeRemaining else { return }
        
        if let trafficUnknownColorString = timeRemaining["trafficUnknownColor"],
           let trafficUnknownColor = UIColor(hex: trafficUnknownColorString) {
            print("🔵 StyleManager: Setting trafficUnknownColor to \(trafficUnknownColor)")
            TimeRemainingLabel.appearance().trafficUnknownColor = trafficUnknownColor
        }

        if let trafficLowColorString = timeRemaining["trafficLowColor"],
           let trafficLowColor = UIColor(hex: trafficLowColorString) {
            print("🔵 StyleManager: Setting trafficLowColor to \(trafficLowColor)")
            TimeRemainingLabel.appearance().trafficLowColor = trafficLowColor
        }

        if let trafficModerateColorString = timeRemaining["trafficModerateColor"],
           let trafficModerateColor = UIColor(hex: trafficModerateColorString) {
            print("🔵 StyleManager: Setting trafficModerateColor to \(trafficModerateColor)")
            TimeRemainingLabel.appearance().trafficModerateColor = trafficModerateColor
        }

        if let trafficHeavyColorString = timeRemaining["trafficHeavyColor"],
           let trafficHeavyColor = UIColor(hex: trafficHeavyColorString) {
            print("🔵 StyleManager: Setting trafficHeavyColor to \(trafficHeavyColor)")
            TimeRemainingLabel.appearance().trafficHeavyColor = trafficHeavyColor
        }

        if let trafficSevereColorString = timeRemaining["trafficSevereColor"],
           let trafficSevereColor = UIColor(hex: trafficSevereColorString) {
            print("🔵 StyleManager: Setting trafficSevereColor to \(trafficSevereColor)")
            TimeRemainingLabel.appearance().trafficSevereColor = trafficSevereColor
        }
    }
    
    private func applyFloatingButtonStyles(_ floatingButtons: [String: String]?) {
        guard let floatingButtons = floatingButtons else { return }
        
        if let tintColorString = floatingButtons["tintColor"],
           let tintColor = UIColor(hex: tintColorString) {
            print("🔵 StyleManager: Setting floatingButtons tintColor to \(tintColor)")
            FloatingButton.appearance(whenContainedInInstancesOf: [NavigationView.self]).tintColor = tintColor
        }

        if let backgroundColorString = floatingButtons["backgroundColor"],
           let backgroundColor = UIColor(hex: backgroundColorString) {
            print("🔵 StyleManager: Setting floatingButtons backgroundColor to \(backgroundColor)")
            FloatingButton.appearance(whenContainedInInstancesOf: [NavigationView.self]).backgroundColor = backgroundColor
        }

        if let borderColorString = floatingButtons["borderColor"],
           let borderColor = UIColor(hex: borderColorString) {
            print("🔵 StyleManager: Setting floatingButtons borderColor to \(borderColor)")
            FloatingButton.appearance(whenContainedInInstancesOf: [NavigationView.self]).borderColor = borderColor
        }
    }
    
    private func applyStatusViewStyles(_ statusView: [String: String]?) {
        guard let statusView = statusView else { return }
        
        if let statusViewBackgroundColorString = statusView["backgroundColor"],
           let statusViewBackgroundColor = UIColor(hex: statusViewBackgroundColorString) {
            print("🔵 StyleManager: Setting statusViewBackgroundColor to \(statusViewBackgroundColor)")
            StatusView.appearance().backgroundColor = statusViewBackgroundColor
        }

        if let statusViewTextColorString = statusView["textColor"],
           let statusViewTextColor = UIColor(hex: statusViewTextColorString) {
            print("🔵 StyleManager: Setting statusViewTextColor to \(statusViewTextColor)")
            StatusView.appearance().tintColor = statusViewTextColor
        }
    }
    
    private func applyDismissButtonStyles(_ dismissButton: [String: String]?) {
        guard let dismissButton = dismissButton else { return }
        
        if let dismissButtonBackgroundColorString = dismissButton["backgroundColor"],
           let dismissButtonBackgroundColor = UIColor(hex: dismissButtonBackgroundColorString) {
            print("🔵 StyleManager: Setting dismissButtonBackgroundColor to \(dismissButtonBackgroundColor)")
            DismissButton.appearance().backgroundColor = dismissButtonBackgroundColor
        }

        if let dismissButtonTextColorString = dismissButton["textColor"],
           let dismissButtonTextColor = UIColor(hex: dismissButtonTextColorString) {
            print("🔵 StyleManager: Setting dismissButtonTextColor to \(dismissButtonTextColor)")
            DismissButton.appearance().textColor = dismissButtonTextColor
        }
    }
    
    private func applyCancelButtonStyles(_ cancelButton: [String: String]?) {
        guard let cancelButton = cancelButton else { return }
        
        if let cancelButtonTextColorString = cancelButton["textColor"],
           let cancelButtonTextColor = UIColor(hex: cancelButtonTextColorString) {
            print("🔵 StyleManager: Setting cancelButtonColor to \(cancelButtonTextColor)")
            CancelButton.appearance().tintColor = cancelButtonTextColor
        }
    }
    
    private func applySeparatorViewStyles(_ separatorView: [String: String]?) {
        guard let separatorView = separatorView else { return }
        
        if let separatorViewBackgroundColorString = separatorView["backgroundColor"],
           let separatorViewBackgroundColor = UIColor(hex: separatorViewBackgroundColorString) {
            print("🔵 StyleManager: Setting separatorViewBackgroundColor to \(separatorViewBackgroundColor)")
            SeparatorView.appearance().backgroundColor = separatorViewBackgroundColor
        }
    }
}