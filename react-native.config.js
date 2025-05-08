module.exports = {
  project: {
    ios: {
      sourceDir: './ios',
    },
  },
  dependencies: {
    '@homee/react-native-mapbox-navigation': {
      platforms: {
        ios: null,
      },
    },
  },
  codegen: {
    name: 'MapboxNavigationView',
    type: 'component',
    jsSpecs: ['src/MapboxNavigationViewSpec.ts'],
    ios: {
      name: 'MapboxNavigationView',
      type: 'component',
      jsSpecs: ['src/MapboxNavigationViewSpec.ts'],
    },
  },
};
