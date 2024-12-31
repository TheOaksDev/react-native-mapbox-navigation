import * as React from 'react';
import { requireNativeComponent, StyleSheet } from 'react-native';
const MapboxNavigation = React.forwardRef((props, ref) => {
    return <RNMapboxNavigation ref={ref} style={styles.container} {...props}/>;
});
const RNMapboxNavigation = requireNativeComponent('MapboxNavigation', MapboxNavigation);
const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
});
export default MapboxNavigation;
