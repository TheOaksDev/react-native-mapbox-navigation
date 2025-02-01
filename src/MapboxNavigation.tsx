// import React, { useRef, useImperativeHandle, forwardRef } from "react";
// import { requireNativeComponent, StyleSheet } from "react-native";

// const MapboxNavigation = forwardRef((props, ref) => {
//   const nativeRef = useRef();

//   useImperativeHandle(ref, () => ({
//     customMethod: () => {
//       if (nativeRef.current) {
//         nativeRef.current.setNativeProps({ command: "customMethod" });
//       }
//     },
//   }));

//   return (
//     <RNMapboxNavigation ref={nativeRef} style={styles.container} {...props} />
//   );
// });

// const RNMapboxNavigation = requireNativeComponent(
//   "MapboxNavigation",
//   MapboxNavigation
// );

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//   },
// });

import React, { Component } from 'react';
import { NativeMethods, StyleSheet, View } from 'react-native';
import type {
  HostComponent,
  LayoutRectangle,
  NativeSyntheticEvent,
} from 'react-native';
import NativeBridgeComponent from './NativeBridgeComponent';
import MapboxNavigationViewModule from './NativeMapboxNavigationViewModule';
import {
  ErrorState,
  isFunction,
  LocationState,
  NativeArg,
  Props,
  RouteProgress,
} from './utils';
import NativeMapboxNavigationView, {
  type NativeMapboxNavigationViewActual,
} from './MapboxNavigationNativeComponent';

const styles = StyleSheet.create({
  matchParent: {
    height: '100%',
    width: '100%',
  },
});

class MapboxNavigation extends NativeBridgeComponent(
  React.PureComponent<Props>,
  MapboxNavigationViewModule,
) {
  static defaultProps: Props = {
    origin: {
      latitude: 0,
      longitude: 0,
    },
    destination: {
      latitude: 0,
      longitude: 0,
    },
    shouldSimulateRoute: false,
    isCarplayView: false,
    isDarkMode: false,
    freeDrive: false,
  };

  _nativeRef?: NativeMapboxNavigationRefType;

  state: {
    isReady: boolean | null;
    width: number;
    height: number;
  };

  constructor(props: Props) {
    super(props);

    this.state = {
      isReady: null,
      width: 0,
      height: 0,
    };

    this._onReady = this._onReady.bind(this);
    this._onArrive = this._onArrive.bind(this);
    this._onRouteProgressChange = this._onRouteProgressChange.bind(this);
    this._onCancelNavigation = this._onCancelNavigation.bind(this);
    this._onError = this._onError.bind(this);
    this._onLocationChange = this._onLocationChange.bind(this);
    this._onLayout = this._onLayout.bind(this);
  }

  componentDidMount() {
    //this._setHandledMapChangedEvents(this.props);
  }

  componentWillUnmount() {
    // this._onDebouncedRegionWillChange.clear();
    // this._onDebouncedRegionDidChange.clear();
    // this.logger.stop();
  }

  UNSAFE_componentWillReceiveProps(nextProps: Props) {
    //this._setHandledMapChangedEvents(nextProps);
  }

  _setNativeRef(nativeRef: NativeMapboxNavigationRefType | null) {
    if (nativeRef != null) {
      this._nativeRef = nativeRef;
      super._runPendingNativeMethods(nativeRef);
    }
  }

  setNativeProps(props: NativeProps) {
    if (this._nativeRef) {
      this._nativeRef.setNativeProps(props);
    }
  }

  _runNative<ReturnType>(
    methodName: string,
    args: NativeArg[] = [],
  ): Promise<ReturnType> {
    return super._runNativeMethod<typeof RNMapboxNavigationView, ReturnType>(
      methodName,
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore TODO: fix types
      this._nativeRef as HostComponent<NativeProps> | undefined,
      args,
    );
  }

  async startNavigation(): Promise<void> {
    await this._runNative<void>('startNavigation', []);
  }

  async stopNavigation(): Promise<void> {
    await this._runNative<void>('stopNavigation', []);
  }

  async startFreeDrive(): Promise<void> {
    await this._runNative<void>('startFreeDrive', []);
  }

  async stopFreeDrive(): Promise<void> {
    await this._runNative<void>('stopFreeDrive', []);
  }

  _decodePayload<T>(payload: T | string): T {
    if (typeof payload === 'string') {
      return JSON.parse(payload);
    } else {
      return payload;
    }
  }

  _onReady() {
    if (isFunction(this.props.onReady)) {
      this.props.onReady();
    }
  }

  _onCancelNavigation() {
    if (isFunction(this.props.onCancelNavigation)) {
      this.props.onCancelNavigation();
    }
  }

  _onError(
    e: NativeSyntheticEvent<{ type: string; payload: ErrorState | string }>,
  ) {
    if (isFunction(this.props.onError)) {
      this.props.onError(this._decodePayload(e.nativeEvent.payload));
    }
  }

  _onArrive() {
    if (isFunction(this.props.onArrive)) {
      this.props.onArrive();
    }
  }

  _onLocationChange(
    e: NativeSyntheticEvent<{ payload: LocationState | string }>,
  ) {
    if (isFunction(this.props.onLocationChange)) {
      this.props.onLocationChange(this._decodePayload(e.nativeEvent.payload));
    }
  }

  _onRouteProgressChange(
    e: NativeSyntheticEvent<{ payload: RouteProgress | string }>,
  ) {
    if (isFunction(this.props.onRouteProgressChange)) {
      this.props.onRouteProgressChange(
        this._decodePayload(e.nativeEvent.payload),
      );
    }
  }

  _onLayout(e: NativeSyntheticEvent<{ layout: LayoutRectangle }>) {
    this.setState({
      isReady: true,
      width: e.nativeEvent.layout.width,
      height: e.nativeEvent.layout.height,
    });
  }

  render() {
    //return <NativeMapboxNavigationView {...this.props} {...callbacks} />;

    const props = {
      ...this.props,
      style: styles.matchParent,
    };

    const callbacks = {
      ref: (nativeRef: NativeMapboxNavigationRefType | null) =>
        this._setNativeRef(nativeRef),
      onReady: this._onReady,
      onCancelNavigation: this._onCancelNavigation,
      onError: this._onError,
      onArrive: this._onArrive,
      onLocationChange: this._onLocationChange,
    };
    let mapView = null;
    if (this.state.isReady) {
      if (props._nativeImpl) {
        mapView = <props._nativeImpl {...props} {...callbacks} />;
      } else {
        mapView = <NativeMapboxNavigationView {...props} {...callbacks} />;
      }
    }
    return (
      <View
        onLayout={this._onLayout}
        style={this.props.style}
        testID={mapView ? undefined : this.props.testID}
      >
        {mapView}
      </View>
    );
  }
}

type NativeProps = Omit<
  Props,
  'onRouteProgressChange' | 'onError' | 'onLocationChange'
> & {
  onRouteProgressChange?: (
    event: NativeSyntheticEvent<{
      type: string;
      payload: RouteProgress | string;
    }>,
  ) => void;
  onError?: (
    event: NativeSyntheticEvent<{ type: string; payload: ErrorState | string }>,
  ) => void;
  onLocationChange?: (
    event: NativeSyntheticEvent<{
      type: string;
      payload: LocationState | string;
    }>,
  ) => void;
};

type NativeMapboxNavigationRefType = Component<NativeProps> &
  Readonly<NativeMethods>;

const RNMapboxNavigationView =
  NativeMapboxNavigationView as NativeMapboxNavigationViewActual;

export default MapboxNavigation;
