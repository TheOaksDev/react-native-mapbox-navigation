import React from 'react';
import { type ViewProps, type ViewStyle, type NativeSyntheticEvent } from 'react-native';
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
    onError?: (event: NativeSyntheticEvent<{
        message: string;
    }>) => void;
    onArrive?: () => void;
    onLocationChange?: (event: NativeSyntheticEvent<{
        latitude: number;
        longitude: number;
    }>) => void;
    onRouteProgressChange?: (event: NativeSyntheticEvent<{
        distanceTraveled: number;
        durationRemaining: number;
        fractionTraveled: number;
        distanceRemaining: number;
        legIndex: number;
        currentStepIndex: number;
        currentStepProgress: number;
    }>) => void;
    onLayout?: (event: NativeSyntheticEvent<{
        layout: {
            width: number;
            height: number;
        };
    }>) => void;
}
export interface MapboxNavigationRef {
    startNavigation: () => Promise<void>;
    stopNavigation: () => Promise<void>;
    startFreeDrive: () => Promise<void>;
    stopFreeDrive: () => Promise<void>;
    showRoutePreview: (coordinates: Array<{
        latitude: number;
        longitude: number;
    }>) => Promise<void>;
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
declare const MapboxNavigation: React.ForwardRefExoticComponent<MapboxNavigationProps & React.RefAttributes<MapboxNavigationRef>>;
export default MapboxNavigation;
