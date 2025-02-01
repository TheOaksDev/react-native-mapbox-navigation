// import React, { useRef, useImperativeHandle, forwardRef } from "react";
// import { requireNativeComponent, StyleSheet } from "react-native";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
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
import React from 'react';
import { StyleSheet, View } from 'react-native';
import NativeBridgeComponent from './NativeBridgeComponent';
import MapboxNavigationViewModule from './NativeMapboxNavigationViewModule';
import { isFunction, } from './utils';
import NativeMapboxNavigationView from './MapboxNavigationNativeComponent';
const styles = StyleSheet.create({
    matchParent: {
        height: '100%',
        width: '100%',
    },
});
class MapboxNavigation extends NativeBridgeComponent((React.PureComponent), MapboxNavigationViewModule) {
    constructor(props) {
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
    UNSAFE_componentWillReceiveProps(nextProps) {
        //this._setHandledMapChangedEvents(nextProps);
    }
    _setNativeRef(nativeRef) {
        if (nativeRef != null) {
            this._nativeRef = nativeRef;
            super._runPendingNativeMethods(nativeRef);
        }
    }
    setNativeProps(props) {
        if (this._nativeRef) {
            this._nativeRef.setNativeProps(props);
        }
    }
    _runNative(methodName, args = []) {
        return super._runNativeMethod(methodName, 
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore TODO: fix types
        this._nativeRef, args);
    }
    startNavigation() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._runNative('startNavigation', []);
        });
    }
    stopNavigation() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._runNative('stopNavigation', []);
        });
    }
    startFreeDrive() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._runNative('startFreeDrive', []);
        });
    }
    stopFreeDrive() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._runNative('stopFreeDrive', []);
        });
    }
    _decodePayload(payload) {
        if (typeof payload === 'string') {
            return JSON.parse(payload);
        }
        else {
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
    _onError(e) {
        if (isFunction(this.props.onError)) {
            this.props.onError(this._decodePayload(e.nativeEvent.payload));
        }
    }
    _onArrive() {
        if (isFunction(this.props.onArrive)) {
            this.props.onArrive();
        }
    }
    _onLocationChange(e) {
        if (isFunction(this.props.onLocationChange)) {
            this.props.onLocationChange(this._decodePayload(e.nativeEvent.payload));
        }
    }
    _onRouteProgressChange(e) {
        if (isFunction(this.props.onRouteProgressChange)) {
            this.props.onRouteProgressChange(this._decodePayload(e.nativeEvent.payload));
        }
    }
    _onLayout(e) {
        this.setState({
            isReady: true,
            width: e.nativeEvent.layout.width,
            height: e.nativeEvent.layout.height,
        });
    }
    render() {
        //return <NativeMapboxNavigationView {...this.props} {...callbacks} />;
        const props = Object.assign(Object.assign({}, this.props), { style: styles.matchParent });
        const callbacks = {
            ref: (nativeRef) => this._setNativeRef(nativeRef),
            onReady: this._onReady,
            onCancelNavigation: this._onCancelNavigation,
            onError: this._onError,
            onArrive: this._onArrive,
            onLocationChange: this._onLocationChange,
        };
        let mapView = null;
        if (this.state.isReady) {
            if (props._nativeImpl) {
                mapView = <props._nativeImpl {...props} {...callbacks}/>;
            }
            else {
                mapView = <NativeMapboxNavigationView {...props} {...callbacks}/>;
            }
        }
        return (<View onLayout={this._onLayout} style={this.props.style} testID={mapView ? undefined : this.props.testID}>
        {mapView}
      </View>);
    }
}
MapboxNavigation.defaultProps = {
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
const RNMapboxNavigationView = NativeMapboxNavigationView;
export default MapboxNavigation;
