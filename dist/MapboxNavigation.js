import React from 'react';
import { StyleSheet, View } from 'react-native';
import NativeBridgeComponent from './NativeBridgeComponent';
import MapboxNavigationViewModule from './NativeMapboxNavigationViewModule';
import MapboxNavigationView from './MapboxNavigationViewSpec';
const styles = StyleSheet.create({
    matchParent: {
        height: '100%',
        width: '100%',
    },
});
class MapboxNavigation extends NativeBridgeComponent((React.PureComponent), MapboxNavigationViewModule) {
    constructor() {
        super(...arguments);
        this.state = {
            isReady: null,
            width: 0,
            height: 0,
        };
        this._onReady = () => {
            this.setState({ isReady: true });
        };
        this._onArrive = () => {
            if (this.props.onArrive) {
                this.props.onArrive();
            }
        };
        this._onRouteProgressChange = (event) => {
            if (this.props.onRouteProgressChange) {
                // Convert string to RouteProgress if needed
                const payload = {
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
        this._onCancelNavigation = () => {
            if (this.props.onCancelNavigation) {
                this.props.onCancelNavigation();
            }
        };
        this._onError = (event) => {
            if (this.props.onError) {
                // Convert string to ErrorState if needed
                const payload = {
                    message: event.nativeEvent.message,
                };
                this.props.onError(payload);
            }
        };
        this._onLocationChange = (event) => {
            if (this.props.onLocationChange) {
                const payload = {
                    longitude: event.nativeEvent.longitude,
                    latitude: event.nativeEvent.latitude,
                };
                this.props.onLocationChange(payload);
            }
        };
        this._onLayout = (e) => {
            const { width, height } = e.nativeEvent.layout;
            this.setState({ width, height });
            if (this.props.onLayout) {
                this.props.onLayout(e);
            }
        };
        this._setNativeRef = (instance) => {
            this._nativeRef = instance || undefined;
        };
    }
    _runNative(methodName, args = []) {
        return super._runNativeMethod(methodName, this
            ._nativeRef, args);
    }
    render() {
        const props = Object.assign(Object.assign({}, this.props), { style: styles.matchParent, origin: this.props.origin
                ? [this.props.origin.longitude, this.props.origin.latitude]
                : undefined, destination: this.props.destination
                ? [this.props.destination.longitude, this.props.destination.latitude]
                : undefined });
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
            mapView = (<MapboxNavigationView ref={this._setNativeRef} {...props} {...callbacks}/>);
        }
        return (<View onLayout={this._onLayout} style={this.props.style} testID={mapView ? undefined : this.props.testID}>
        {mapView}
      </View>);
    }
}
export default MapboxNavigation;
