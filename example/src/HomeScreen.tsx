/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {useEffect} from 'react';
import {
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  View,
  Pressable,
  ScrollView,
} from 'react-native';
import {useNavigation} from '@react-navigation/native';
import NativeMapboxNavigationViewModule from 'react-native-mapbox-navigation/src/NativeMapboxNavigationViewModule';
import {NavigationPropType} from './types';

function HomeScreen(): React.JSX.Element {
  const navigation = useNavigation<NavigationPropType>();

  useEffect(() => {
    // Test if the module is accessible
    console.log('Testing MapboxNavigationViewModule...');
    try {
      NativeMapboxNavigationViewModule.testMethod()
        .then(result => {
          console.log('Module test successful:', result);
        })
        .catch(error => {
          console.error('Module test failed:', error);
        });
    } catch (error) {
      console.error('Module not accessible:', error);
    }
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <View style={styles.header}>
        <Text style={styles.title}>Mapbox Navigation Test</Text>
      </View>
      <ScrollView style={styles.scrollContainer}>
        <Pressable
          style={styles.button}
          onPress={() => navigation.navigate('MapScreen')}>
          <Text>View Map</Text>
        </Pressable>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  header: {
    padding: 20,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333333',
  },
  scrollContainer: {
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 20,
  },
  button: {
    padding: 10,
    borderRadius: 5,
    backgroundColor: '#E0E0E0',
    alignItems: 'center',
    width: '100%',
  },
});

export default HomeScreen;
