import type { HostComponent, ViewProps } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import {
  type RouteProgress,
  type LocationState,
  type ErrorState,
} from './utils';
import { DirectEventHandler } from 'react-native/Libraries/Types/CodegenTypes';

// see https://github.com/rnmapbox/maps/wiki/FabricOptionalProp
export type UnsafeMixed<T> = T;
export type OptionalProp<T> = UnsafeMixed<T>;

type OnRouteProgressChangeEventType = {
  type: string;
  payload: string;
};

type OnErrorEventType = {
  type: string;
  payload: string;
};

type OnLocationChangeEventType = {
  type: string;
  payload: string;
};

export interface NativeProps extends ViewProps {
  origin?: OptionalProp<LocationState>;
  destination?: OptionalProp<LocationState>;
  isCarplayView?: OptionalProp<boolean>;
  freeDriveEnabled?: OptionalProp<boolean>;
  viewStyles?: OptionalProp<object>;
  shouldSimulateRoute?: OptionalProp<boolean>;
  isDarkMode?: OptionalProp<boolean>;
  onReady?: () => void;
  onCancelNavigation?: () => void;
  onRouteProgressChange?: DirectEventHandler<OnRouteProgressChangeEventType>;
  onError?: DirectEventHandler<OnErrorEventType>;
  onArrive?: () => void;
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

export type NativeMapboxNavigationViewActual = HostComponent<
  Omit<
    NativeProps,
    'onRouteProgressChange' | 'onError' | 'onLocationChange'
  > & {
    onRouteProgressChange?: DirectEventHandler<OnRouteProgressChangeEventTypeActual>;
    onError?: DirectEventHandler<OnErrorEventTypeActual>;
    onLocationChange?: DirectEventHandler<OnLocationChangeEventTypeActual>;
  }
>;
