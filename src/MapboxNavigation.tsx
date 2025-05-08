import React, { Component } from 'react';
import { StyleSheet, View } from 'react-native';
import type {
  LayoutRectangle,
  NativeMethods,
  NativeSyntheticEvent,
} from 'react-native';
import NativeBridgeComponent from './NativeBridgeComponent';
import MapboxNavigationViewModule from './NativeMapboxNavigationViewModule';
import {
  ErrorState,
  LocationState,
  NativeArg,
  Props,
  RouteProgress,
} from './utils';
import MapboxNavigationView, {
  MapboxNavigationViewProps,
} from './MapboxNavigationViewSpec';
import { NativeComponentType } from 'react-native/Libraries/Utilities/codegenNativeComponent';

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
  private _nativeRef?: Component<MapboxNavigationViewProps> &
    Readonly<NativeMethods>;

  state = {
    isReady: null as boolean | null,
    width: 0,
    height: 0,
  };

  _onReady = () => {
    this.setState({ isReady: true });
  };

  _onArrive = () => {
    if (this.props.onArrive) {
      this.props.onArrive();
    }
  };

  _onRouteProgressChange = (event: {
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
  }) => {
    if (this.props.onRouteProgressChange) {
      // Convert string to RouteProgress if needed
      const payload: RouteProgress = {
        distanceTraveled: event.nativeEvent.distanceTraveled,
        durationRemaining: event.nativeEvent.durationRemaining,
        fractionTraveled: event.nativeEvent.fractionTraveled,
        distanceRemaining: event.nativeEvent.distanceRemaining,
        legIndex: event.nativeEvent.legIndex,
        currentStepIndex: event.nativeEvent.currentStepIndex,
        currentStepProgress: event.nativeEvent.currentStepProgress,
        route: event.nativeEvent.route,
      };
      this.props.onRouteProgressChange(payload);
    }
  };

  _onCancelNavigation = () => {
    if (this.props.onCancelNavigation) {
      this.props.onCancelNavigation();
    }
  };

  _onError = (event: { nativeEvent: { message: string } }) => {
    if (this.props.onError) {
      // Convert string to ErrorState if needed
      const payload: ErrorState = {
        message: event.nativeEvent.message,
      };
      this.props.onError(payload);
    }
  };

  _onLocationChange = (event: {
    nativeEvent: { longitude: number; latitude: number };
  }) => {
    if (this.props.onLocationChange) {
      const payload: LocationState = {
        longitude: event.nativeEvent.longitude,
        latitude: event.nativeEvent.latitude,
      };
      this.props.onLocationChange(payload);
    }
  };

  _onLayout = (e: NativeSyntheticEvent<{ layout: LayoutRectangle }>) => {
    const { width, height } = e.nativeEvent.layout;
    this.setState({ width, height });
    if (this.props.onLayout) {
      this.props.onLayout(e);
    }
  };

  _setNativeRef = (
    instance:
      | (Component<MapboxNavigationViewProps> & Readonly<NativeMethods>)
      | null,
  ) => {
    this._nativeRef = instance || undefined;
  };

  _runNative<ReturnType>(
    methodName: string,
    args: NativeArg[] = [],
  ): Promise<ReturnType> {
    return super._runNativeMethod<typeof MapboxNavigationView, ReturnType>(
      methodName,
      this
        ._nativeRef as unknown as NativeComponentType<MapboxNavigationViewProps>,
      args,
    );
  }

  render() {
    const props = {
      ...this.props,
      style: styles.matchParent,
      origin: this.props.origin
        ? [this.props.origin.longitude, this.props.origin.latitude]
        : undefined,
      destination: this.props.destination
        ? [this.props.destination.longitude, this.props.destination.latitude]
        : undefined,
    };

    const callbacks = {
      onReady: this._onReady,
      onCancelNavigation: this._onCancelNavigation,
      onError: this._onError,
      onArrive: this._onArrive,
      onLocationChange: this._onLocationChange,
      onLayout: this._onLayout,
      onRouteProgressChange: this._onRouteProgressChange,
    };

    let mapView = null;
    if (this.state.isReady) {
      mapView = (
        <MapboxNavigationView
          ref={this._setNativeRef}
          {...props}
          {...callbacks}
        />
      );
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

export default MapboxNavigation;
