/* eslint-disable @typescript-eslint/ban-types */
import type { TurboModule } from 'react-native/Libraries/TurboModule/RCTExport';
import { Double, Int32 } from 'react-native/Libraries/Types/CodegenTypes';
import { TurboModuleRegistry } from 'react-native';

type Coordinate = {
  latitude: Double;
  longitude: Double;
};

type VisibleArea = {
  top: Double;
  left: Double;
  bottom: Double;
  right: Double;
  width: Double;
  height: Double;
};

export interface Spec extends TurboModule {
  startNavigation: (viewRef: Int32 | null) => void;
  stopNavigation: (viewRef: Int32 | null) => void;
  startFreeDrive: (viewRef: Int32 | null) => void;
  stopFreeDrive: (viewRef: Int32 | null) => void;
  showRoutePreview: (
    viewRef: Int32 | null,
    coordinates: Array<Coordinate>,
  ) => void;
  hideRoutePreview: (viewRef: Int32 | null) => void;
  setCameraZoom: (viewRef: Int32 | null, zoomLevel: Double) => void;
  getCameraZoom: (viewRef: Int32 | null) => Double;
  setVisibleArea: (viewRef: Int32 | null, visibleArea: VisibleArea) => void;
}

export default TurboModuleRegistry.getEnforcing<Spec>(
  'MapboxNavigationViewModule',
);
