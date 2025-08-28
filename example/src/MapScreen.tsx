/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {useRef, useState} from 'react';
import {View, StyleSheet, Button, Alert} from 'react-native';
import MapboxNavigation, {
  MapboxNavigationRef,
} from 'react-native-mapbox-navigation';

const MapScreen: React.FC = () => {
  const navigationRef = useRef<MapboxNavigationRef>(null);
  const [isNavigationActive, setIsNavigationActive] = useState(false);
  const [isFreeDriveActive, setIsFreeDriveActive] = useState(false);

  const origin = [-122.43199, 37.77766]; // San Francisco
  const destination = [-122.43494, 37.77536]; // San Francisco

  const handleStartNavigation = async () => {
    try {
      await navigationRef.current?.startNavigation();
      setIsNavigationActive(true);
      Alert.alert('Success', 'Navigation started!');
    } catch (error) {
      Alert.alert('Error', `Failed to start navigation: ${error}`);
    }
  };

  const handleStopNavigation = async () => {
    try {
      await navigationRef.current?.stopNavigation();
      setIsNavigationActive(false);
      Alert.alert('Success', 'Navigation stopped!');
    } catch (error) {
      Alert.alert('Error', `Failed to stop navigation: ${error}`);
    }
  };

  const handleStartFreeDrive = async () => {
    try {
      await navigationRef.current?.startFreeDrive();
      setIsFreeDriveActive(true);
      Alert.alert('Success', 'Free drive started!');
    } catch (error) {
      Alert.alert('Error', `Failed to start free drive: ${error}`);
    }
  };

  const handleStopFreeDrive = async () => {
    try {
      await navigationRef.current?.stopFreeDrive();
      setIsFreeDriveActive(false);
      Alert.alert('Success', 'Free drive stopped!');
    } catch (error) {
      Alert.alert('Error', `Failed to stop free drive: ${error}`);
    }
  };

  const handleShowRoutePreview = async () => {
    try {
      const coordinates = [
        {latitude: 37.77766, longitude: -122.43199},
        {latitude: 37.77536, longitude: -122.43494},
        {latitude: 37.77336, longitude: -122.43694},
      ];
      await navigationRef.current?.showRoutePreview(coordinates);
      Alert.alert('Success', 'Route preview shown!');
    } catch (error) {
      Alert.alert('Error', `Failed to show route preview: ${error}`);
    }
  };

  const handleHideRoutePreview = async () => {
    try {
      await navigationRef.current?.hideRoutePreview();
      Alert.alert('Success', 'Route preview hidden!');
    } catch (error) {
      Alert.alert('Error', `Failed to hide route preview: ${error}`);
    }
  };

  const handleSetCameraZoom = async () => {
    try {
      await navigationRef.current?.setCameraZoom(15);
      Alert.alert('Success', 'Camera zoom set to 15!');
    } catch (error) {
      Alert.alert('Error', `Failed to set camera zoom: ${error}`);
    }
  };

  const handleGetCameraZoom = async () => {
    try {
      const zoom = await navigationRef.current?.getCameraZoom();
      Alert.alert('Camera Zoom', `Current zoom level: ${zoom}`);
    } catch (error) {
      Alert.alert('Error', `Failed to get camera zoom: ${error}`);
    }
  };

  const handleSetVisibleArea = async () => {
    try {
      await navigationRef.current?.setVisibleArea({
        top: 50,
        left: 20,
        bottom: 100,
        right: 20,
        width: 400,
        height: 300,
      });
      Alert.alert('Success', 'Visible area set!');
    } catch (error) {
      Alert.alert('Error', `Failed to set visible area: ${error}`);
    }
  };

  return (
    <View style={styles.container}>
      <MapboxNavigation
        ref={navigationRef}
        style={styles.map}
        origin={origin}
        destination={destination}
        shouldSimulateRoute={true}
        isCarplayView={false}
        mute={false}
        onLocationChange={event =>
          console.log('Location changed:', event.nativeEvent)
        }
        onRouteProgressChange={event =>
          console.log('Route progress:', event.nativeEvent)
        }
        onError={event => console.log('Error:', event.nativeEvent)}
        onCancelNavigation={event =>
          console.log('Navigation canceled:', event.nativeEvent)
        }
        onArrive={event => console.log('Arrived:', event.nativeEvent)}
      />

      <View style={styles.buttonContainer}>
        <Button
          title={isNavigationActive ? 'Stop Navigation' : 'Start Navigation'}
          onPress={
            isNavigationActive ? handleStopNavigation : handleStartNavigation
          }
        />

        <Button
          title={isFreeDriveActive ? 'Stop Free Drive' : 'Start Free Drive'}
          onPress={
            isFreeDriveActive ? handleStopFreeDrive : handleStartFreeDrive
          }
        />

        <Button title="Show Route Preview" onPress={handleShowRoutePreview} />
        <Button title="Hide Route Preview" onPress={handleHideRoutePreview} />

        <Button title="Set Camera Zoom (15)" onPress={handleSetCameraZoom} />
        <Button title="Get Camera Zoom" onPress={handleGetCameraZoom} />

        <Button title="Set Visible Area" onPress={handleSetVisibleArea} />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 20,
    left: 20,
    right: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    padding: 10,
    borderRadius: 10,
  },
});

export default MapScreen;
