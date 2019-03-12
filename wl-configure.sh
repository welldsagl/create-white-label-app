#!/bin/bash


# ------------------------------------------------------------------------------
# VARIABLES
# ------------------------------------------------------------------------------

WL_APP_NAME=whitelabel
WL_DIR_NAME=whitelabel
unset WL_MODULES
unset WL_THEME


# ------------------------------------------------------------------------------
# PRINT HELP
# ------------------------------------------------------------------------------

help() {
	echo "
Usage: ./wl-generate.sh [flags]

Examples: ./wl-generate -m Foo,Bar,Baz -t solarized-dark
          ./wl-generate -a whitelabel -m Foo,Baz -t solarized-dark
          ./wl-generate -a test -m Baz,Bar -t solarized-light

Description:

This utility configures the project \"whitelabel\" or a project \"app-<app-name>\",
composing modules and setting the theme.

Flags:

    -h
        Print help.

    -a [app-name] (optional, default = whitelabel)
        Name of the target application to configure. If given, the directory
        'app-<app-name>' will be configured, otherwise 'whitelabel' will be
        used as default.

    -m [module1,module2,...,moduleN]
        List of modules to be used in the app, separated by commas (','). At
        least one must be provided.

    -t [theme]
        Name of the theme to be used in the app.
"
}


# ------------------------------------------------------------------------------
# PARSE ARGUMENTS
# ------------------------------------------------------------------------------

# If help (-h) found, print help and interrupt script
while getopts ':ha:m:t:' arg; do
	case $arg in
		h) help && exit 0      ;;
		a) WL_APP_NAME=$OPTARG ;;
		m) WL_MODULES=$OPTARG  ;;
		t) WL_THEME=$OPTARG    ;;
	esac
done

if [ "${WL_APP_NAME}" != "whitelabel" ]; then
	WL_DIR_NAME="app-${WL_APP_NAME}"
fi


# ------------------------------------------------------------------------------
# WRONG ARGUMENT ERRORS
# ------------------------------------------------------------------------------

# Missing mandatory parameters
if [ -z "$WL_MODULES" ]; then echo ERROR: No modules provided; exit 0; fi
if [ -z "$WL_THEME" ];   then echo ERROR: No theme provided;   exit 0; fi

if [ ! -d "${WL_DIR_NAME}" ]; then
	echo "Directory ${WL_DIR_NAME} doesn't exists"
	exit 0
fi

# ------------------------------------------------------------------------------
# 1. GENERATE modules/index.js
# ------------------------------------------------------------------------------

# // modules/index.js
# import Module1 from './Module1';
# import Module2 from './Module2';
# ...
# import ModuleN from './ModuleN';
#
# export default [Module1, Module2, ..., ModuleN];
#

WL_MODULES_FILE="./${WL_DIR_NAME}/modules/index.js"
WL_MODULES_LIST=("${WL_MODULES//,/ }")

echo "> Generate ${WL_MODULES_FILE}"

> $WL_MODULES_FILE
for module in $WL_MODULES_LIST; do
	echo "import ${module} from './${module}';" >> $WL_MODULES_FILE;
done
echo "" >> $WL_MODULES_FILE
echo "export default [${WL_MODULES}];" >> $WL_MODULES_FILE


# ------------------------------------------------------------------------------
# 2. GENERATE theme/index.js
# ------------------------------------------------------------------------------

# const styles = require('./theme').default;
#
# module.exports = fileName => styles[fileName] || {};
#

WL_THEME_FILE="./${WL_DIR_NAME}/theme/index.js"

echo "> Generate ${WL_THEME_FILE}"

echo "const styles = require('./${WL_THEME}').default;"> $WL_THEME_FILE
echo "" >> $WL_THEME_FILE
echo "module.exports = fileName => styles[fileName] || {};" >> $WL_THEME_FILE
