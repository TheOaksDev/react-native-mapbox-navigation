/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {useRef} from 'react';
import {SafeAreaView, StyleSheet, useColorScheme} from 'react-native';
import {Colors} from 'react-native/Libraries/NewAppScreen';
import {MapboxNavigation} from 'react-native-mapbox-navigation';

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const ref = useRef(null);

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <MapboxNavigation
        ref={ref}
        // origin={[parseFloat(origin.longitude), parseFloat(origin.latitude)]}
        // destination={[parseFloat(dest.longitude), parseFloat(dest.latitude)]}
        shouldSimulateRoute={false}
        isCarplayView={false}
        isDarkMode={isDarkMode}
        freeDrive={false}
        viewStyles={
          {
            /** STYLES HERE */
          }
        }
        onReady={() => {
          console.log('[MAP NAV LOG] onReady');
        }}
        onLayout={event => {
          console.log('[MAP NAV LOG] onLayout', event);
        }}
        onCancelNavigation={() => {
          console.log('[MAP NAV LOG] onCancelNavigation');
        }}
        onLocationChange={event => {
          console.log('[MAP NAV LOG] onLocationChange', event);
        }}
        onRouteProgressChange={event => {
          console.log('[MAP NAV LOG] onRouteProgressChange', event);
        }}
        onError={event => {
          console.log('[MAP NAV LOG] onError', event);
        }}
        onArrive={() => {
          console.log('[MAP NAV LOG] onArrive');
        }}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
});

export default App;
