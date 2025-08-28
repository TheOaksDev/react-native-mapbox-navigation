var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import React, { useEffect, useImperativeHandle, forwardRef, useRef, useState, } from 'react';
import { View, requireNativeComponent, findNodeHandle, } from 'react-native';
import NativeMapboxNavigationViewModule from './NativeMapboxNavigationViewModule';
// Require the native component
const RNMapboxNavigationView = requireNativeComponent('MapboxNavigationView');
const MapboxNavigation = forwardRef(({ style, testID = 'MapboxNavigationView', origin, destination, shouldSimulateRoute = false, isDarkMode = false, freeDrive = false, mute = false, defaultCameraOptions = {
    center: {
        latitude: 39.8283,
        longitude: -98.5795,
    },
    zoom: 5,
}, viewStyles, onReady, onCancelNavigation, onError, onArrive, onLocationChange, onRouteProgressChange, onLayout, }, ref) => {
    const viewRef = useRef(null);
    const nativeModule = useRef(null);
    const [size, setSize] = useState({ height: 0, width: 0 });
    useImperativeHandle(ref, () => ({
        startNavigation: () => __awaiter(void 0, void 0, void 0, function* () {
            if (!nativeModule.current || !viewRef.current) {
                throw new Error('View or native module not found');
            }
            const node = findNodeHandle(viewRef.current);
            if (!node) {
                throw new Error('View node not found');
            }
            return nativeModule.current.startNavigation(node);
        }),
        stopNavigation: () => __awaiter(void 0, void 0, void 0, function* () {
            if (!nativeModule.current || !viewRef.current) {
                throw new Error('View or native module not found');
            }
            const node = findNodeHandle(viewRef.current);
            if (!node) {
                throw new Error('View node not found');
            }
            return nativeModule.current.stopNavigation(node);
        }),
        startFreeDrive: () => __awaiter(void 0, void 0, void 0, function* () {
            if (!nativeModule.current || !viewRef.current) {
                throw new Error('View or native module not found');
            }
            const node = findNodeHandle(viewRef.current);
            if (!node) {
                throw new Error('View node not found');
            }
            return nativeModule.current.startFreeDrive(node);
        }),
        stopFreeDrive: () => __awaiter(void 0, void 0, void 0, function* () {
            if (!nativeModule.current || !viewRef.current) {
                throw new Error('View or native module not found');
            }
            const node = findNodeHandle(viewRef.current);
            if (!node) {
                throw new Error('View node not found');
            }
            return nativeModule.current.stopFreeDrive(node);
        }),
        showRoutePreview: (coordinates) => __awaiter(void 0, void 0, void 0, function* () {
            if (!nativeModule.current || !viewRef.current) {
                throw new Error('View or native module not found');
            }
            const node = findNodeHandle(viewRef.current);
            if (!node) {
                throw new Error('View node not found');
            }
            return nativeModule.current.showRoutePreview(node, coordinates);
        }),
        hideRoutePreview: () => __awaiter(void 0, void 0, void 0, function* () {
            if (!nativeModule.current || !viewRef.current) {
                throw new Error('View or native module not found');
            }
            const node = findNodeHandle(viewRef.current);
            if (!node) {
                throw new Error('View node not found');
            }
            return nativeModule.current.hideRoutePreview(node);
        }),
        setCameraZoom: (zoomLevel) => __awaiter(void 0, void 0, void 0, function* () {
            if (!nativeModule.current || !viewRef.current) {
                throw new Error('View or native module not found');
            }
            const node = findNodeHandle(viewRef.current);
            if (!node) {
                throw new Error('View node not found');
            }
            return nativeModule.current.setCameraZoom(node, zoomLevel);
        }),
        setVisibleArea: (visibleArea) => __awaiter(void 0, void 0, void 0, function* () {
            if (!nativeModule.current || !viewRef.current) {
                throw new Error('View or native module not found');
            }
            const node = findNodeHandle(viewRef.current);
            if (!node) {
                throw new Error('View node not found');
            }
            return nativeModule.current.setVisibleArea(node, visibleArea);
        }),
        getCameraZoom: () => __awaiter(void 0, void 0, void 0, function* () {
            if (!nativeModule.current || !viewRef.current) {
                throw new Error('View or native module not found');
            }
            const node = findNodeHandle(viewRef.current);
            if (!node) {
                throw new Error('View node not found');
            }
            return nativeModule.current.getCameraZoom(node);
        }),
    }), []);
    useEffect(() => {
        // Initialize the native module reference
        nativeModule.current = NativeMapboxNavigationViewModule;
    }, []);
    return (<View style={style} onLayout={({ nativeEvent, }) => {
            setSize({
                height: nativeEvent.layout.height,
                width: nativeEvent.layout.width,
            });
        }}>
        <RNMapboxNavigationView testID={testID} ref={viewRef} style={{
            height: size.height,
            width: size.width,
        }} origin={origin} destination={destination} shouldSimulateRoute={shouldSimulateRoute} isDarkMode={isDarkMode} freeDrive={freeDrive} mute={mute} defaultCameraOptions={defaultCameraOptions} viewStyles={viewStyles} onReady={onReady} onCancelNavigation={onCancelNavigation} onError={onError} onArrive={onArrive} onLocationChange={onLocationChange} onRouteProgressChange={onRouteProgressChange} onLayout={onLayout}/>
      </View>);
});
export default MapboxNavigation;
