# React Native White-label

Skeleton project for creating a white-label application with React Native.

## About

This repo provides a project skeleton and some scripts for generating apps from
a white-label application. The white-label app supports modules composition and
theme configuration, thay can be changed on the fly and applications with custom
configurations can be generated.

## Usage

To start using and customize the white-label app, do the following

1. Install dependencies with `yarn install`;
2. Add/modify modules in `whitelabel/modules` (see [Modules](#modules));
3. Add/modify themes in `whitelabel/theme` (see [Themes](#themes));
4. Configure the application (see [White-label configuration](#white-label-configuration));
5. Run the application.

__N.B.: You must configure the application at least once for it to work!__

## The white-label project

The white-label project is a modular React Native application. It features
modules and themes personalization. The white-label app is contained in the
`white-label` directory.

### Modules

Modules represent a particular section of the application. They are defined in
the `whitelabel/modules` directory. Each module must export an object with the
following attributes

1. `name`: The name of the module. It must be unique (_i.e._, two modules cannot
have the same name).
2. `Component`: A React component that will be displayed.

For instance
```jsx
// modules/Bar.js
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
```

Modules are the automatically exported, depending on the white-label
configuration, by the `whitelabel/modules` directory as a list, and they can be
used anywhere
```jsx
// App.js
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
```

__N.B.: Modules should not be imported individually, but always as a whole.__

### Themes

Themes define the styles for components. By just toggling the theme, the styles
will change, without editing components files.

Themes are defined in the `theme` directory. Each theme has a custom directory,
containing stylesheet files. For instance, a stylesheet file may look like
```jsx
// theme/solarized-dark/App.js
import { StyleSheet } from 'react-native';

export default StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        backgroundColor: '#002b36',
    },
    title: {
        paddingHorizontal: 16,
        color: '#657b83',
        fontSize: 20,
        fontWeight: 'bold',
    },
});
```

Stylesheets are then collected and exported in an `index.js` file
```jsx
// theme/solarized-dark/index.js
import App from './App';
import Module from './Module';

export default {
    App,
    Module,
};
```


__N.B.: Every theme should consist of the same stylesheet files and same style
classes, to provide maximum interoperability between themes.__

## White-label configuration

The white-label configuration script allows to configure the `whitelabel`
project to use a specific combination of modules and a specific theme, without
directly changing the source code. It can be run from the root directory with
```
./wl-configure.sh -a whitelabel -m Foo,Baz -t solarized-dark
```

It supports the following flags
* `a`: The name of the project to configure. `whitelabel` will configure the
`whitelabel` directory. Other names will configure `app-<name>` projects; for
instance, `-a test` will configure project `app-test`.
* `m`: List of comma-separated modules to be used. These modules must be present
in the `modules` directory. The order provided is the order with which modules
will be exported, so `-m Foo,Bar` is different from `-m Bar,Foo`.
* `t`: Theme to use in the app. It must be one present in the `theme` directory.

## White-label generation

The white-label generation allows to generate projects (new directories) based
on `whitelabel`, with a particular configuration, display name and bundle id.
This allows to install on the same device multiple applications originating from
the `whitelabel` one.

The generation can be done with
```
./wl-generate.sh -a test -d "Test" -b com.test -m Baz,Bar,Foo -t solarized-light
```

and will procude a new directory (or override the existing) `app-<name>`. In our
example, it will generate directory `app-test`. The script supports the
following flags
* `a`: Name of the project to generate for `-a name`, the project `app-name`
will be created. It cannot be `whitelabel`.
* `d`: Display name for the application, will be visible under the app icon on
the device.
* `b`: Bundle identifier for the app. It must consist of dot-separated
alpha-numeric characters. It should be unique for every application and it
should not be `com.whitelabel` (the default for the `whitelabel` project), or
two app may clash.
* `m`: List of comma-separated modules to be used. These modules must be present
in the `modules` directory. The order provided is the order with which modules
will be exported, so `-m Foo,Bar` is different from `-m Bar,Foo`.
* `t`: Theme to use in the app. It must be one present in the `theme` directory.

## Comments

This work is not definitive and doesn't provide yet all features of a
white-label application, but it is a starting point.

## License

Everything inside this repository is [Apache 2.0 licensed](./LICENSE).