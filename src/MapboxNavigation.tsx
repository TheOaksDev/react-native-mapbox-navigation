import React, {
  useEffect,
  useImperativeHandle,
  forwardRef,
  useRef,
  useState,
} from 'react';
import {
  View,
  requireNativeComponent,
  type ViewProps,
  type ViewStyle,
  type NativeSyntheticEvent,
  findNodeHandle,
} from 'react-native';
import NativeMapboxNavigationViewModule, {
  type Spec,
} from './NativeMapboxNavigationViewModule';

export interface MapboxNavigationProps extends ViewProps {
  testID?: string;
  style?: ViewStyle;
  origin: {
    latitude: number;
    longitude: number;
  };
  destination: {
    latitude: number;
    longitude: number;
  };
  shouldSimulateRoute?: boolean;
  isDarkMode?: boolean;
  freeDrive?: boolean;
  mute?: boolean;
  defaultCameraOptions?: {
    center: {
      latitude: number;
      longitude: number;
    };
    zoom: number;
  };
  viewStyles?: {
    banner?: {
      topBannerBackgroundColor?: string;
      bottomBannerBackgroundColor?: string;
      instructionBannerBackgroundColor?: string;
      stepInstructionsBackgroundColor?: string;
      nextBannerBackgroundColor?: string;
    };
    maneuver?: {
      primaryColor?: string;
      secondaryColor?: string;
      primaryColorHighlighted?: string;
      secondaryColorHighlighted?: string;
      textColor?: string;
    };
    primary?: {
      normalTextColor?: string;
    };
    secondary?: {
      normalTextColor?: string;
    };
    distance?: {
      unitTextColor?: string;
      valueTextColor?: string;
    };
    floatingButtons?: {
      tintColor?: string;
      backgroundColor?: string;
      borderColor?: string;
    };
    timeRemaining?: {
      trafficUnknownColor?: string;
      trafficLowColor?: string;
      trafficModerateColor?: string;
      trafficHeavyColor?: string;
      trafficSevereColor?: string;
    };
    cancelButton?: {
      textColor?: string;
    };
    dismissButton?: {
      backgroundColor?: string;
      textColor?: string;
    };
    statusView?: {
      backgroundColor?: string;
      textColor?: string;
    };
    separatorView?: {
      backgroundColor?: string;
    };
    footer?: {
      totalDistanceTextColor?: string;
      totalDurationTextColor?: string;
      arrivalTimeTextColor?: string;
    };
  };
  onReady?: () => void;
  onCancelNavigation?: () => void;
  onError?: (event: NativeSyntheticEvent<{ message: string }>) => void;
  onArrive?: () => void;
  onLocationChange?: (
    event: NativeSyntheticEvent<{ latitude: number; longitude: number }>,
  ) => void;
  onRouteProgressChange?: (
    event: NativeSyntheticEvent<{
      distanceTraveled: number;
      durationRemaining: number;
      fractionTraveled: number;
      distanceRemaining: number;
      legIndex: number;
      currentStepIndex: number;
      currentStepProgress: number;
    }>,
  ) => void;
  onLayout?: (
    event: NativeSyntheticEvent<{ layout: { width: number; height: number } }>,
  ) => void;
}

export interface MapboxNavigationRef {
  startNavigation: () => Promise<void>;
  stopNavigation: () => Promise<void>;
  startFreeDrive: () => Promise<void>;
  stopFreeDrive: () => Promise<void>;
  showRoutePreview: (
    coordinates: Array<{ latitude: number; longitude: number }>,
  ) => Promise<void>;
  hideRoutePreview: () => Promise<void>;
  setCameraZoom: (zoomLevel: number) => Promise<void>;
  setVisibleArea: (visibleArea: {
    top: number;
    left: number;
    bottom: number;
    right: number;
    width: number;
    height: number;
  }) => Promise<void>;
  getCameraZoom: () => Promise<number>;
}

// Use the Spec interface directly
type RNMapboxNavigationModule = Spec;

// Require the native component
const RNMapboxNavigationView = requireNativeComponent<MapboxNavigationProps>(
  'MapboxNavigationView',
);

const MapboxNavigation = forwardRef<MapboxNavigationRef, MapboxNavigationProps>(
  (
    {
      style,
      testID = 'MapboxNavigationView',
      origin,
      destination,
      shouldSimulateRoute = false,
      isDarkMode = false,
      freeDrive = false,
      mute = false,
      defaultCameraOptions = {
        center: {
          latitude: 39.8283,
          longitude: -98.5795,
        },
        zoom: 5,
      },
      viewStyles,
      onReady,
      onCancelNavigation,
      onError,
      onArrive,
      onLocationChange,
      onRouteProgressChange,
      onLayout,
    }: MapboxNavigationProps,
    ref: React.Ref<MapboxNavigationRef>,
  ) => {
    const viewRef = useRef(null);
    const nativeModule = useRef<RNMapboxNavigationModule | null>(null);
    const [size, setSize] = useState({ height: 0, width: 0 });

    useImperativeHandle(
      ref,
      () => ({
        startNavigation: async () => {
          if (!nativeModule.current || !viewRef.current) {
            throw new Error('View or native module not found');
          }
          const node = findNodeHandle(viewRef.current);
          if (!node) {
            throw new Error('View node not found');
          }
            console.log('🔵 React Native: Calling startNavigation with node:', node);
            return nativeModule.current.startNavigation(node);
          },
        stopNavigation: async () => {
          if (!nativeModule.current || !viewRef.current) {
            throw new Error('View or native module not found');
          }
          const node = findNodeHandle(viewRef.current);
          if (!node) {
            throw new Error('View node not found');
          }
          console.log('🔵 React Native: Calling stopNavigation with node:', node);
          return nativeModule.current.stopNavigation(node);
        },
        startFreeDrive: async () => {
          if (!nativeModule.current || !viewRef.current) {
            throw new Error('View or native module not found');
          }
          const node = findNodeHandle(viewRef.current);
          if (!node) {
            throw new Error('View node not found');
          }
          console.log('🔵 React Native: Calling startFreeDrive with node:', node);
          return nativeModule.current.startFreeDrive(node);
        },
        stopFreeDrive: async () => {
          if (!nativeModule.current || !viewRef.current) {
            throw new Error('View or native module not found');
          }
          const node = findNodeHandle(viewRef.current);
          if (!node) {
            throw new Error('View node not found');
          }
          console.log('🔵 React Native: Calling stopFreeDrive with node:', node);
          return nativeModule.current.stopFreeDrive(node);
        },
        showRoutePreview: async (coordinates) => {
          if (!nativeModule.current || !viewRef.current) {
            throw new Error('View or native module not found');
          }
          const node = findNodeHandle(viewRef.current);
          if (!node) {
            throw new Error('View node not found');
          }
          console.log('🔵 React Native: Calling showRoutePreview with node:', node);
          return nativeModule.current.showRoutePreview(node, coordinates);
        },
        hideRoutePreview: async () => {
          if (!nativeModule.current || !viewRef.current) {
            throw new Error('View or native module not found');
          }
          const node = findNodeHandle(viewRef.current);
          if (!node) {
            throw new Error('View node not found');
          }
          console.log('🔵 React Native: Calling hideRoutePreview with node:', node);
          return nativeModule.current.hideRoutePreview(node);
        },
        setCameraZoom: async (zoomLevel) => {
          if (!nativeModule.current || !viewRef.current) {
            throw new Error('View or native module not found');
          }
          const node = findNodeHandle(viewRef.current);
          if (!node) {
            throw new Error('View node not found');
          }
          console.log('🔵 React Native: Calling setCameraZoom with node:', node);
          return nativeModule.current.setCameraZoom(node, zoomLevel);
        },
        setVisibleArea: async (visibleArea) => {
          if (!nativeModule.current || !viewRef.current) {
            throw new Error('View or native module not found');
          }
          const node = findNodeHandle(viewRef.current);
          if (!node) {
            throw new Error('View node not found');
          }
          console.log('🔵 React Native: Calling setVisibleArea with node:', node);
          return nativeModule.current.setVisibleArea(node, visibleArea);
        },
        getCameraZoom: async () => {
          if (!nativeModule.current || !viewRef.current) {
            throw new Error('View or native module not found');
          }
          const node = findNodeHandle(viewRef.current);
          if (!node) {
            throw new Error('View node not found');
          }
          console.log('🔵 React Native: Calling getCameraZoom with node:', node);
          return nativeModule.current.getCameraZoom(node);
        },
      }),
      [],
    );

    useEffect(() => {
      // Initialize the native module reference
      nativeModule.current = NativeMapboxNavigationViewModule;
    }, []);

    return (
      <View
        style={style}
        onLayout={({
          nativeEvent,
        }: {
          nativeEvent: { layout: { height: number; width: number } };
        }) => {
          setSize({
            height: nativeEvent.layout.height,
            width: nativeEvent.layout.width,
          });
        }}
      >
        <RNMapboxNavigationView
          testID={testID}
          ref={viewRef}
          style={{
            height: size.height,
            width: size.width,
          }}
          origin={origin}
          destination={destination}
          shouldSimulateRoute={shouldSimulateRoute}
          isDarkMode={isDarkMode}
          freeDrive={freeDrive}
          mute={mute}
          defaultCameraOptions={defaultCameraOptions}
          viewStyles={viewStyles}
          onReady={onReady}
          onCancelNavigation={onCancelNavigation}
          onError={onError}
          onArrive={onArrive}
          onLocationChange={onLocationChange}
          onRouteProgressChange={onRouteProgressChange}
          onLayout={onLayout}
        />
      </View>
    );
  },
);

export default MapboxNavigation;
