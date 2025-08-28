// create navigation prop
import {NavigationProp} from '@react-navigation/native';

export type RootStackParamList = {
  HomeScreen: undefined;
  MapScreen: undefined;
};

export type NavigationPropType = NavigationProp<RootStackParamList>;
