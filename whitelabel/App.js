import React from 'react';
import { Text, SafeAreaView, View } from 'react-native';
import modules from './modules';

const styles = require('./theme')('App');

export default () => (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>
        White-Label App
      </Text>
      <View>
        {modules.map(({ name, Component }) =>
            <Component key={name} />
        )}
      </View>
    </SafeAreaView>
);
