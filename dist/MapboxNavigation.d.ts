import React, { Component } from 'react';
import type { LayoutRectangle, NativeMethods, NativeSyntheticEvent } from 'react-native';
import { NativeArg, Props } from './utils';
import { MapboxNavigationViewProps } from './MapboxNavigationViewSpec';
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
    new (props: Props): React.PureComponent<Props, {}, any>;
    new (props: Props, context: any): React.PureComponent<Props, {}, any>;
    contextType?: React.Context<any> | undefined;
};
declare class MapboxNavigation extends MapboxNavigation_base {
    private _nativeRef?;
    state: {
        isReady: boolean | null;
        width: number;
        height: number;
    };
    _onReady: () => void;
    _onArrive: () => void;
    _onRouteProgressChange: (event: {
        nativeEvent: {
            distanceTraveled: number;
            durationRemaining: number;
            fractionTraveled: number;
            distanceRemaining: number;
            legIndex: number;
            currentStepIndex: number;
            currentStepProgress: number;
            route: Record<string, any>;
        };
    }) => void;
    _onCancelNavigation: () => void;
    _onError: (event: {
        nativeEvent: {
            message: string;
        };
    }) => void;
    _onLocationChange: (event: {
        nativeEvent: {
            longitude: number;
            latitude: number;
        };
    }) => void;
    _onLayout: (e: NativeSyntheticEvent<{
        layout: LayoutRectangle;
    }>) => void;
    _setNativeRef: (instance: (Component<MapboxNavigationViewProps> & Readonly<NativeMethods>) | null) => void;
    _runNative<ReturnType>(methodName: string, args?: NativeArg[]): Promise<ReturnType>;
    render(): React.JSX.Element;
}
export default MapboxNavigation;
