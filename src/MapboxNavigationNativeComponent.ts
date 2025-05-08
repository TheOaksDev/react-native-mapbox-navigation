import type { HostComponent, ViewProps } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import {
  type RouteProgress,
  type LocationState,
  type ErrorState,
  type CameraOptions,
} from './utils';
import {
  DirectEventHandler,
  Double,
} from 'react-native/Libraries/Types/CodegenTypes';

type OnRouteProgressChangeEventType = {
  type: string;
  payload: {
    distanceTraveled: Double;
    durationRemaining: Double;
    fractionTraveled: Double;
    distanceRemaining: Double;
    legIndex: Double;
    currentStepIndex: Double;
    currentStepProgress: Double;
  };
};

type OnErrorEventType = {
  type: string;
  payload: {
    message: string;
  };
};

type OnLocationChangeEventType = {
  type: string;
  payload: {
    latitude: Double;
    longitude: Double;
  };
};

type OnLayoutEventType = {
  type: string;
  payload: {
    layout: {
      x: Double;
      y: Double;
      width: Double;
      height: Double;
    };
  };
};

type OnReadyEventType = {
  type: string;
  payload: boolean;
};

type OnCancelNavigationEventType = {
  type: string;
  payload: boolean;
};

type OnArriveEventType = {
  type: string;
  payload: boolean;
};

export interface NativeProps extends ViewProps {
  defaultMapOptions?: {
    center: {
      latitude: Double;
      longitude: Double;
    };
    zoom: Double;
  };
  origin?: {
    latitude: Double;
    longitude: Double;
  };
  destination?: {
    latitude: Double;
    longitude: Double;
  };
  freeDriveEnabled?: boolean;
  viewStyles?: {
    banner?: {
      topBannerBackgroundColor?: string;
      bottomBannerBackgroundColor?: string;
      instructionBannerBackgroundColor?: string;
      stepInstructionsBackgroundColor?: string;
      nextBannerBackgroundColor?: string;
    };
    maneuver?: {
      primaryColor?: string;
      secondaryColor?: string;
      primaryColorHighlighted?: string;
      secondaryColorHighlighted?: string;
      textColor?: string;
    };
    primary?: {
      normalTextColor?: string;
    };
    secondary?: {
      normalTextColor?: string;
    };
    distance?: {
      unitTextColor?: string;
      valueTextColor?: string;
    };
    floatingButtons?: {
      tintColor?: string;
      backgroundColor?: string;
      borderColor?: string;
    };
    timeRemaining?: {
      trafficUnknownColor?: string;
      trafficLowColor?: string;
      trafficModerateColor?: string;
      trafficHeavyColor?: string;
      trafficSevereColor?: string;
    };
    cancelButton?: {
      textColor?: string;
    };
    dismissButton?: {
      backgroundColor?: string;
      textColor?: string;
    };
    statusView?: {
      backgroundColor?: string;
      textColor?: string;
    };
    separatorView?: {
      backgroundColor?: string;
    };
    footer?: {
      totalDistanceTextColor?: string;
      totalDurationTextColor?: string;
      arrivalTimeTextColor?: string;
    };
  };
  shouldSimulateRoute?: boolean;
  isDarkMode?: boolean;
  onReady?: DirectEventHandler<OnReadyEventType>;
  onCancelNavigation?: DirectEventHandler<OnCancelNavigationEventType>;
  onLayout?: DirectEventHandler<OnLayoutEventType>;
  onRouteProgressChange?: DirectEventHandler<OnRouteProgressChangeEventType>;
  onError?: DirectEventHandler<OnErrorEventType>;
  onArrive?: DirectEventHandler<OnArriveEventType>;
  onLocationChange?: DirectEventHandler<OnLocationChangeEventType>;
}

export default codegenNativeComponent<NativeProps>(
  'MapboxNavigationView',
) as HostComponent<NativeProps>;

type OnRouteProgressChangeEventTypeActual = {
  type: string;
  payload: RouteProgress | string;
};

type OnErrorEventTypeActual = {
  type: string;
  payload: ErrorState | string;
};

type OnLocationChangeEventTypeActual = {
  type: string;
  payload: LocationState | string;
};

type OnLayoutEventTypeActual = {
  type: string;
  payload: {
    layout: {
      x: Double;
      y: Double;
      width: Double;
      height: Double;
    };
  };
};

export type NativeMapboxNavigationViewActual = HostComponent<
  Omit<
    NativeProps,
    'onLayout' | 'onRouteProgressChange' | 'onError' | 'onLocationChange'
  > & {
    onLayout?: DirectEventHandler<OnLayoutEventTypeActual>;
    onRouteProgressChange?: DirectEventHandler<OnRouteProgressChangeEventTypeActual>;
    onError?: DirectEventHandler<OnErrorEventTypeActual>;
    onLocationChange?: DirectEventHandler<OnLocationChangeEventTypeActual>;
  }
>;
