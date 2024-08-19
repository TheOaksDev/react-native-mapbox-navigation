import * as React from 'react';
import { requireNativeComponent, StyleSheet } from 'react-native';

import { IMapboxNavigationProps } from './typings';

const MapboxNavigation = (props: IMapboxNavigationProps) => {
  return <RNMapboxNavigation style={styles.container} {...props} />;
};

const MapboxCarplayNavigation = (props: IMapboxNavigationProps) => {
  return <RNMapboxCarplayNavigation style={styles.container} {...props} />;
};

const RNMapboxNavigation = requireNativeComponent(
  'MapboxNavigation',
  MapboxNavigation
);

const RNMapboxCarplayNavigation = requireNativeComponent(
  'MapboxCarplayNavigation',
  MapboxCarplayNavigation
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default MapboxNavigation;
export {MapboxCarplayNavigation}
