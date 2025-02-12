import type { HostComponent, LayoutRectangle, ViewProps } from 'react-native';
import { type RouteProgress, type LocationState, type ErrorState, type CameraOptions } from './utils';
import { DirectEventHandler } from 'react-native/Libraries/Types/CodegenTypes';
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
type OnLayoutEventType = {
    layout: LayoutRectangle;
};
export interface NativeProps extends ViewProps {
    defaultMapOptions?: OptionalProp<CameraOptions>;
    origin?: OptionalProp<LocationState>;
    destination?: OptionalProp<LocationState>;
    isCarplayView?: OptionalProp<boolean>;
    freeDriveEnabled?: OptionalProp<boolean>;
    viewStyles?: OptionalProp<object>;
    shouldSimulateRoute?: OptionalProp<boolean>;
    isDarkMode?: OptionalProp<boolean>;
    onReady?: () => void;
    onCancelNavigation?: () => void;
    onLayout?: DirectEventHandler<OnLayoutEventType>;
    onRouteProgressChange?: DirectEventHandler<OnRouteProgressChangeEventType>;
    onError?: DirectEventHandler<OnErrorEventType>;
    onArrive?: () => void;
    onLocationChange?: DirectEventHandler<OnLocationChangeEventType>;
}
declare const _default: HostComponent<NativeProps>;
export default _default;
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
    layout: LayoutRectangle;
};
export type NativeMapboxNavigationViewActual = HostComponent<Omit<NativeProps, 'onLayout' | 'onRouteProgressChange' | 'onError' | 'onLocationChange'> & {
    onLayout?: DirectEventHandler<OnLayoutEventTypeActual>;
    onRouteProgressChange?: DirectEventHandler<OnRouteProgressChangeEventTypeActual>;
    onError?: DirectEventHandler<OnErrorEventTypeActual>;
    onLocationChange?: DirectEventHandler<OnLocationChangeEventTypeActual>;
}>;
