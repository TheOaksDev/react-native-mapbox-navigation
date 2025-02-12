import type { TurboModule } from 'react-native/Libraries/TurboModule/RCTExport';
import { Int32 } from 'react-native/Libraries/Types/CodegenTypes';
export interface Spec extends TurboModule {
    startNavigation: (viewRef: Int32 | null) => void;
    stopNavigation: (viewRef: Int32 | null) => void;
    startFreeDrive: (viewRef: Int32 | null) => void;
    stopFreeDrive: (viewRef: Int32 | null) => void;
    showRoutePreview: (viewRef: Int32 | null, coordinates: ReadonlyArray<ReadonlyMap<string, number>>) => void;
    hideRoutePreview: (viewRef: Int32 | null) => void;
    setCameraZoom: (viewRef: Int32 | null, zoomLevel: number) => void;
    getCameraZoom: (viewRef: Int32 | null) => number;
    setVisibleArea: (viewRef: Int32 | null, visibleArea: ReadonlyMap<string, number>) => void;
}
declare const _default: Spec;
export default _default;
