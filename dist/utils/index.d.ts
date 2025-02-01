import { TurboModule, ViewProps } from "react-native";
import { NativeMapboxNavigationViewActual } from "../MapboxNavigationNativeComponent";
export type NativeArg = string | number | boolean | null | {
    [k: string]: NativeArg;
} | NativeArg[];
export declare function runNativeMethod<ReturnType = NativeArg>(turboModule: TurboModule, name: string, nativeRef: any, args: NativeArg[]): Promise<ReturnType>;
export declare function isFunction(fn: unknown): fn is boolean;
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
export type ErrorState = {
    message: string;
};
export type Props = ViewProps & {
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
   * @private Experimental support for custom MapView instances
   */
    _nativeImpl?: NativeMapboxNavigationViewActual;
};
