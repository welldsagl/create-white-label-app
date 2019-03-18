#!/bin/bash


# ------------------------------------------------------------------------------
# VARIABLES
# ------------------------------------------------------------------------------

unset WL_APP_NAME
unset WL_BUNDLE_ID
unset WL_DISPLAY_NAME
unset WL_MODULES
unset WL_THEME
unset WL_DIR_NAME


# ------------------------------------------------------------------------------
# PRINT HELP
# ------------------------------------------------------------------------------

help() {
	echo "
Usage: ./wl-generate.sh [flags]

Example: ./wl-generate.sh -a test -b com.test -d Test -m Foo,Bar -t solarized-dark

Description:

This utility generates a configured project \"app-<app-name>\" from \"whitelabel\".
The new project features custom bundle id and display name.

Flags:

    -h
        Print help.

    -a [app-name]
        Name of the target application to generate. Has to be different from
        'whitelabel'. The directory \"app-<app-name>\" will be generated.

    -b [bundle-id]
        Bundle identifier for the app.

    -d [display-name]
        Display name of the app, appearing under the app icon on devices.

    -m [module1,module2,...,moduleN]
        List of modules to be used in the app, separated by commas (','). At
        least one must be provided.

    -t [theme]
        Name of the theme to be used in the app.
"
}


# ------------------------------------------------------------------------------
# UTILS
# ------------------------------------------------------------------------------

replace_string_in_files() {
	local STR_SRC=$1
	local STR_DEST=$2
	local FILES="${@:3}"
	for file in $FILES; do
		sed -i '' -e "s/${STR_SRC}/${STR_DEST}/g" $file
	done
}


# ------------------------------------------------------------------------------
# PARSE ARGUMENTS
# ------------------------------------------------------------------------------

# If help (-h) found, print help and interrupt script
while getopts ':ha:b:d:m:t:' arg; do
	case $arg in
		h) help && exit 0          ;;
		a) WL_APP_NAME=$OPTARG     ;;
		b) WL_BUNDLE_ID=$OPTARG    ;;
		d) WL_DISPLAY_NAME=$OPTARG ;;
		m) WL_MODULES=$OPTARG      ;;
		t) WL_THEME=$OPTARG        ;;
	esac
done

WL_DIR_NAME="app-${WL_APP_NAME}"


# ------------------------------------------------------------------------------
# WRONG ARGUMENT ERRORS
# ------------------------------------------------------------------------------

# Check app name is not 'whitelabel'
if [ "$WL_APP_NAME" == "whitelabel" ]; then
	echo "ERROR: Provided invalid app name 'whitelabel'"
	exit 0
fi

# Missing mandatory parameters
if [ -z "$WL_APP_NAME" ];     then echo ERROR: No app name provided;     exit 0; fi
if [ -z "$WL_BUNDLE_ID" ];    then echo ERROR: No bundle id provided;    exit 0; fi
if [ -z "$WL_DISPLAY_NAME" ]; then echo ERROR: No display anme provided; exit 0; fi
if [ -z "$WL_MODULES" ];      then echo ERROR: No modules provided;      exit 0; fi
if [ -z "$WL_THEME" ];        then echo ERROR: No theme provided;        exit 0; fi


# ------------------------------------------------------------------------------
# 1. COPY WHITELABEL DIRECTORY
# ------------------------------------------------------------------------------

echo "> Copy 'whitelabel' directory to '${WL_APP_NAME}'"

# Remove previous app directory
if [ -d "./${WL_DIR_NAME}" ]; then
	rm -rf "./${WL_DIR_NAME}"
fi

# Copy content of whitelabel into new application directory (files excluded from
# .gitignore will not be copied).
rsync                                      \
	-r                                     \
	--exclude-from=./whitelabel/.gitignore \
	./whitelabel/                          \
	./${WL_DIR_NAME}


# ------------------------------------------------------------------------------
# 2. CONFIGURE APPLICATION
# ------------------------------------------------------------------------------

./wl-configure.sh   \
	-a $WL_APP_NAME \
	-m $WL_MODULES  \
	-t $WL_THEME


# ------------------------------------------------------------------------------
# 3. CONFIGURE DISPLAY NAME
# ------------------------------------------------------------------------------

echo "> Set display name '${WL_DISPLAY_NAME}'"

# Replace 'whitelabel' with given display name
replace_string_in_files whitelabel "$WL_DISPLAY_NAME"                  \
	"./${WL_DIR_NAME}/android/app/src/main/res/values/strings.xml" \
	"./${WL_DIR_NAME}/ios/whitelabel/Info.plist"


# ------------------------------------------------------------------------------
# 4. CONFIGURE BUNDLE ID
# ------------------------------------------------------------------------------

echo "> Set bundle id '${WL_BUNDLE_ID}'"

# Replace 'com.whitelabel' with given bundle id
replace_string_in_files "com.whitelabel" "$WL_BUNDLE_ID"                               \
	"${WL_DIR_NAME}/android/app/BUCK"                                              \
	"${WL_DIR_NAME}/android/app/build.gradle"                                      \
	"${WL_DIR_NAME}/android/app/src/main/AndroidManifest.xml"                      \
	"${WL_DIR_NAME}/android/app/src/main/java/com/whitelabel/MainActivity.java"    \
	"${WL_DIR_NAME}/android/app/src/main/java/com/whitelabel/MainApplication.java" \
	"${WL_DIR_NAME}/ios/whitelabel.xcodeproj/project.pbxproj"

# Replace '.' with '/' to get bundle  path
# E.g., 'com.whitelabel' -> 'com/whitelabel'
WL_BUNDLE_PATH="${WL_BUNDLE_ID//.//}"

# Create directories for Android java files following new bundle id structure
mkdir -p "./${WL_DIR_NAME}/android/app/src/main/java/${WL_BUNDLE_PATH}/"

# Copy MainApplication and MainActivity to new directories
mv "./${WL_DIR_NAME}/android/app/src/main/java/com/whitelabel/MainActivity.java"       \
   "./${WL_DIR_NAME}/android/app/src/main/java/${WL_BUNDLE_PATH}/MainActivity.java"
mv "./${WL_DIR_NAME}/android/app/src/main/java/com/whitelabel/MainApplication.java"    \
   "./${WL_DIR_NAME}/android/app/src/main/java/${WL_BUNDLE_PATH}/MainApplication.java"

# Remove old directory com/whitelabel
rm -d "./${WL_DIR_NAME}/android/app/src/main/java/com/whitelabel/"


# ------------------------------------------------------------------------------
# 5. INSTALL DEPENDENCIES
# ------------------------------------------------------------------------------

echo "> Install dependencies"

pushd "./${WL_DIR_NAME}" > /dev/null

yarn install --silent > /dev/null 2> /dev/null

popd > /dev/null
