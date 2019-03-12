import React from 'react';
import { Text, View } from 'react-native';

const styles = require('../theme')('Module');

const BarComponent = () => (
    <View style={styles.container}>
      <Text style={styles.text}>
        Module <Text style={styles.accent}>Bar</Text>
      </Text>
    </View>
);

export default {
    name: 'Bar',
    Component: BarComponent,
};
