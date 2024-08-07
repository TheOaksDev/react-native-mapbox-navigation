/** @type {[number, number]}
 * Provide an array with longitude and latitude [$longitude, $latitude]
 */
type Coordinate = [number, number];

type OnLocationChangeEvent = {
  nativeEvent?: {
    latitude: number;
    longitude: number;
  };
};

type OnRouteProgressChangeEvent = {
  nativeEvent?: {
    distanceTraveled: number;
    durationRemaining: number;
    fractionTraveled: number;
    distanceRemaining: number;
    route: object;
  };
};

type OnErrorEvent = {
  nativeEvent?: {
    message?: string;
  };
};

type ComponentStyle = {
  banner: {
    topBannerBackgroundColor?: string;
    bottomBannerBackgroundColor?: string;
    instructionBannerBackgroundColor?: string;
    stepInstructionsBackgroundColor?: string;
  };
  maneuver: {
    primaryColor?: string;
    secondaryColor?: string;
    primaryColorHighlighted?: string;
    secondaryColorHighlighted?: string;
  };
  primary: {
    normalTextColor?: string;
  };
  secondary: {
    normalTextColor?: string;
  };
  distance: {
    unitTextColor?: string;
    valueTextColor?: string;
  };
  floatingButtons: {
    tintColor?: string;
    backgroundColor?: string;
    borderColor?: string;
  };
  timeRemaining: {
    trafficUnknownColor?: string;
    trafficLowColor?: string;
    trafficModerateColor?: string;
    trafficHeavyColor?: string;
    trafficSevereColor?: string;
  };
  footer: {
    totalDistanceTextColor?: string;
    arrivalTimeTextColor?: string;
  };
};

export interface IMapboxNavigationProps {
  origin: Coordinate;
  destination: Coordinate;
  shouldSimulateRoute?: boolean;
  onLocationChange?: (event: OnLocationChangeEvent) => void;
  onRouteProgressChange?: (event: OnRouteProgressChangeEvent) => void;
  onError?: (event: OnErrorEvent) => void;
  onCancelNavigation?: () => void;
  onArrive?: () => void;
  showsEndOfRouteFeedback?: boolean;
  hideStatusView?: boolean;
  hideTopBannerView?: boolean;
  hideBottomBannerView?: boolean;
  hideReportFeedback?: boolean;
  mute?: boolean;
  viewStyles?: ComponentStyle;
  mapStyleURL?: string;
}
