/* eslint-disable @typescript-eslint/ban-types */
import type { TurboModule } from 'react-native/Libraries/TurboModule/RCTExport';
import { Int32 } from 'react-native/Libraries/Types/CodegenTypes';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  startNavigation: (viewRef: Int32 | null) => void;
  stopNavigation: (viewRef: Int32 | null) => void;
  startFreeDrive: (viewRef: Int32 | null) => void;
  stopFreeDrive: (viewRef: Int32 | null) => void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('MapboxNavigationViewModule');
