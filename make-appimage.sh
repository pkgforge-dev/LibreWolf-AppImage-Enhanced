#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q librewolf-bin | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/192x192/apps/librewolf.png
export DESKTOP=/usr/share/applications/librewolf.desktop

# Deploy dependencies
LD_LIBRARY_PATH=$PWD/AppDir/bin quick-sharun \
	./AppDir/bin/*          \
	/usr/lib/libavcodec.so* \
	/usr/lib/libcanberra.so*

echo 'MOZ_LEGACY_PROFILES=1'        >> ./AppDir/.env
echo 'MOZ_APP_LAUNCHER=${APPIMAGE}' >> ./AppDir/.env

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
