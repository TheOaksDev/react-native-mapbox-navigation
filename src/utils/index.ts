import { findNodeHandle, LayoutRectangle, TurboModule, ViewProps } from "react-native";
import { NativeMapboxNavigationViewActual } from "../MapboxNavigationNativeComponent";

export type NativeArg =
  | string
  | number
  | boolean
  | null
  | { [k: string]: NativeArg }
  | NativeArg[];

export function runNativeMethod<ReturnType = NativeArg>(
  turboModule: TurboModule,
  name: string,
  nativeRef: any,
  args: NativeArg[]
): Promise<ReturnType> {
  const handle = findNodeHandle(nativeRef);
  if (!handle) {
    throw new Error(`Could not find handle for native ref ${module}.${name}`);
  }

  // @ts-expect-error TS says that string cannot be used to index Turbomodules.
  // It can, it's just not pretty.
  return turboModule[name](handle, ...args);
}

export function isFunction(fn: unknown): fn is boolean {
  return typeof fn === 'function';
}

export type RouteProgress = {
  distanceTraveled: number;
  durationRemaining: number;
  fractionTraveled: number;
  distanceRemaining: number;
  legIndex?: number;
  currentStepIndex?: number;
  currentStepProgress?: number;
  route: object;
};

export type LocationState = {
  latitude: number;
  longitude: number;
};

export type VisibleArea = {
  top: number;
  left: number;
  bottom: number;
  right: number;
  width: number;
  height: number;
};

export type Point = [number, number];

export type ErrorState = {
  message: string;
}

export type CameraOptions = {
  center: LocationState;
  zoom: number;
};

export type Props = ViewProps & {
  /**
   * The default map options to use for the MapView component.
   */
  defaultCameraOptions?: CameraOptions;

  /**
   * The origin of the route.
   */
  origin?: LocationState;

  /**
   * The destination of the route.
   */
  destination?: LocationState;

  /**
   * Whether the route should be simulated.
   */
  shouldSimulateRoute?: boolean;

  /**
   * Whether the MapboxNavigation component is in CarPlay mode.
   */
  isCarplayView?: boolean;

  /**
   * Whether the MapboxNavigation component is in dark mode.
   */
  isDarkMode?: boolean;
  
  /**
   * Whether free drive is enabled.
   */
  freeDrive?: boolean;
  
  /**
   * The styles to apply to the MapboxNavigation component.
   */
  viewStyles?: object;
  
  /**
   * This event is triggered when the MapboxNavigation component is ready.
   */
  onReady?: () => void;
  
  /**
   * This event is triggered when the user cancels navigation.
   */
  onCancelNavigation?: () => void;
  
  /**
   * This event is triggered when an error occurs.
   */
  onError?: (error: ErrorState) => void;
  
  /**
   * This event is triggered when the user's route progress has changed.
   */
  onRouteProgressChange?: (routeProgress: RouteProgress) => void;

  /**
   * This event is triggered when the user has arrived at their destination.
   */
  onArrive?: () => void;

  /**
   * This event is triggered when the user's location has changed.
   */
  onLocationChange?: (location: LocationState) => void;

  /**
   * This event is triggered when the MapboxNavigation component is laid out.
   */
  onLayout?: (layout: LayoutRectangle) => void;

  /**
   * @private Experimental support for custom MapView instances
   */
  _nativeImpl?: NativeMapboxNavigationViewActual;
};