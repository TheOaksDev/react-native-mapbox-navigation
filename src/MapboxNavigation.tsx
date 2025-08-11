import React, {
  useEffect,
  useImperativeHandle,
  forwardRef,
  useRef,
} from 'react';
import {
  View,
  requireNativeComponent,
  type ViewProps,
  type ViewStyle,
  type NativeSyntheticEvent,
  findNodeHandle,
} from 'react-native';

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
  }) => Promise<void>;
  getCameraZoom: () => Promise<number>;
}

// Define the native module interface
interface RNMapboxNavigationModule {
  startNavigation: (node: number) => Promise<void>;
  stopNavigation: (node: number) => Promise<void>;
  startFreeDrive: (node: number) => Promise<void>;
  stopFreeDrive: (node: number) => Promise<void>;
  showRoutePreview: (
    node: number,
    coordinates: Array<{ latitude: number; longitude: number }>,
  ) => Promise<void>;
  hideRoutePreview: (node: number) => Promise<void>;
  setCameraZoom: (node: number, zoomLevel: number) => Promise<void>;
  setVisibleArea: (
    node: number,
    visibleArea: { top: number; left: number; bottom: number; right: number },
  ) => Promise<void>;
  getCameraZoom: (node: number) => Promise<number>;
}

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
          return nativeModule.current.getCameraZoom(node);
        },
      }),
      [],
    );

    useEffect(() => {
      // Initialize the native module reference
      // You'll need to create the corresponding native module
      // nativeModule.current = NativeModules.RNMapboxNavigationModule as RNMapboxNavigationModule;
    }, []);

    return (
      <View style={style}>
        <RNMapboxNavigationView
          testID={testID}
          ref={viewRef}
          style={style}
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
