type Coordinate = {
    latitude: number;
    longitude: number;
};
type VisibleArea = {
    top: number;
    left: number;
    bottom: number;
    right: number;
    width: number;
    height: number;
};
export interface Spec {
    startNavigation: (viewRef: number | null) => Promise<any>;
    stopNavigation: (viewRef: number | null) => Promise<any>;
    startFreeDrive: (viewRef: number | null) => Promise<any>;
    stopFreeDrive: (viewRef: number | null) => Promise<any>;
    showRoutePreview: (viewRef: number | null, coordinates: Array<Coordinate>) => Promise<any>;
    hideRoutePreview: (viewRef: number | null) => Promise<any>;
    setCameraZoom: (viewRef: number | null, zoomLevel: number) => Promise<any>;
    getCameraZoom: (viewRef: number | null) => Promise<any>;
    setVisibleArea: (viewRef: number | null, visibleArea: VisibleArea) => Promise<any>;
    testMethod: () => Promise<any>;
}
declare const _default: Spec;
export default _default;
