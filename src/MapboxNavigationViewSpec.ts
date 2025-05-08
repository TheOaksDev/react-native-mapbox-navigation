import type { ViewProps } from 'react-native';
import type { Double } from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';

export interface MapboxNavigationViewProps extends ViewProps {
  origin?: ReadonlyArray<Double>;
  destination?: ReadonlyArray<Double>;
  mapStyleURL?: string;
  viewStyles?: Readonly<Record<string, any>>;
  isCarplayView?: boolean;
  shouldSimulateRoute?: boolean;
  showsEndOfRouteFeedback?: boolean;
  hideReportFeedback?: boolean;
  mute?: boolean;
  onLocationChange?: (event: {
    nativeEvent: {
      longitude: Double;
      latitude: Double;
    };
  }) => void;
  onRouteProgressChange?: (event: {
    nativeEvent: {
      distanceTraveled: Double;
      durationRemaining: Double;
      fractionTraveled: Double;
      distanceRemaining: Double;
      legIndex: number;
      currentStepIndex: number;
      currentStepProgress: Double;
      route: Record<string, any>;
    };
  }) => void;
  onError?: (event: {
    nativeEvent: {
      message: string;
    };
  }) => void;
  onCancelNavigation?: (event: {
    nativeEvent: {
      message: string;
    };
  }) => void;
  onArrive?: (event: {
    nativeEvent: {
      message: string;
    };
  }) => void;
}

export default codegenNativeComponent<MapboxNavigationViewProps>(
  'MapboxNavigationView',
);
