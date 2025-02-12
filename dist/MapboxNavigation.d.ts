import React, { Component } from 'react';
import { NativeMethods } from 'react-native';
import type { LayoutRectangle, NativeSyntheticEvent } from 'react-native';
import { ErrorState, LocationState, NativeArg, Props, RouteProgress, VisibleArea } from './utils';
declare const MapboxNavigation_base: {
    new (...args: any[]): {
        _turboModule: import("react-native").TurboModule;
        _preRefMapMethodQueue: {
            method: {
                name: string;
                args: NativeArg[];
            };
            resolver: (value: NativeArg) => void;
        }[];
        _runPendingNativeMethods<RefType>(nativeRef: RefType): Promise<void>;
        _runNativeMethod<RefType_1, ReturnType_1 = NativeArg>(methodName: string, nativeRef: RefType_1 | undefined, args?: NativeArg[]): Promise<ReturnType_1>;
        context: unknown;
        setState<K extends never>(state: {} | ((prevState: Readonly<{}>, props: object) => {} | Pick<{}, K> | null) | Pick<{}, K> | null, callback?: (() => void) | undefined): void;
        forceUpdate(callback?: (() => void) | undefined): void;
        render(): React.ReactNode;
        readonly props: object;
        state: Readonly<{}>;
        refs: {
            [key: string]: React.ReactInstance;
        };
        componentDidMount?(): void;
        shouldComponentUpdate?(nextProps: object, nextState: Readonly<{}>, nextContext: any): boolean;
        componentWillUnmount?(): void;
        componentDidCatch?(error: Error, errorInfo: React.ErrorInfo): void;
        getSnapshotBeforeUpdate?(prevProps: object, prevState: Readonly<{}>): any;
        componentDidUpdate?(prevProps: object, prevState: Readonly<{}>, snapshot?: any): void;
        componentWillMount?(): void;
        UNSAFE_componentWillMount?(): void;
        componentWillReceiveProps?(nextProps: object, nextContext: any): void;
        UNSAFE_componentWillReceiveProps?(nextProps: object, nextContext: any): void;
        componentWillUpdate?(nextProps: object, nextState: Readonly<{}>, nextContext: any): void;
        UNSAFE_componentWillUpdate?(nextProps: object, nextState: Readonly<{}>, nextContext: any): void;
    };
} & {
    new (props: Props | Readonly<Props>): React.PureComponent<Props, {}, any>;
    new (props: Props, context: any): React.PureComponent<Props, {}, any>;
    contextType?: React.Context<any> | undefined;
};
declare class MapboxNavigation extends MapboxNavigation_base {
    static defaultProps: Props;
    _nativeRef?: NativeMapboxNavigationRefType;
    state: {
        isReady: boolean | null;
        width: number;
        height: number;
    };
    constructor(props: Props);
    componentDidMount(): void;
    componentWillUnmount(): void;
    UNSAFE_componentWillReceiveProps(nextProps: Props): void;
    _setNativeRef(nativeRef: NativeMapboxNavigationRefType | null): void;
    setNativeProps(props: NativeProps): void;
    _runNative<ReturnType>(methodName: string, args?: NativeArg[]): Promise<ReturnType>;
    startNavigation(): Promise<void>;
    stopNavigation(): Promise<void>;
    startFreeDrive(): Promise<void>;
    stopFreeDrive(): Promise<void>;
    showRoutePreview(coordinates: LocationState[]): Promise<void>;
    hideRoutePreview(): Promise<void>;
    setCameraZoom(zoomLevel: number): Promise<void>;
    setVisibleArea(visibleArea: VisibleArea): Promise<void>;
    getCameraZoom(): Promise<number>;
    _decodePayload<T>(payload: T | string): T;
    _onReady(): void;
    _onCancelNavigation(): void;
    _onError(e: NativeSyntheticEvent<{
        type: string;
        payload: ErrorState | string;
    }>): void;
    _onArrive(): void;
    _onLocationChange(e: NativeSyntheticEvent<{
        payload: LocationState | string;
    }>): void;
    _onRouteProgressChange(e: NativeSyntheticEvent<{
        payload: RouteProgress | string;
    }>): void;
    _onLayout(e: NativeSyntheticEvent<{
        layout: LayoutRectangle;
    }>): void;
    render(): JSX.Element;
}
type NativeProps = Omit<Props, 'onLayout' | 'onRouteProgressChange' | 'onError' | 'onLocationChange'> & {
    onLayout?: (event: NativeSyntheticEvent<{
        layout: LayoutRectangle;
    }>) => void;
    onRouteProgressChange?: (event: NativeSyntheticEvent<{
        type: string;
        payload: RouteProgress | string;
    }>) => void;
    onError?: (event: NativeSyntheticEvent<{
        type: string;
        payload: ErrorState | string;
    }>) => void;
    onLocationChange?: (event: NativeSyntheticEvent<{
        type: string;
        payload: LocationState | string;
    }>) => void;
};
type NativeMapboxNavigationRefType = Component<NativeProps> & Readonly<NativeMethods>;
export default MapboxNavigation;
