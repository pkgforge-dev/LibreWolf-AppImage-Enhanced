#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm libcanberra

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini ffmpeg-mini

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
echo "Downloading LibreWolf..."
echo "---------------------------------------------------------------"
case "$ARCH" in
	x86_64)  farch=$ARCH;;
	aarch64) farch=arm64;;
esac

TARBALL_LINK=$(wget https://codeberg.org/api/v1/repos/librewolf/bsys6/releases/latest -O - \
	| sed 's/[()",{} ]/\n/g' | grep -o "https.*/librewolf.*linux-$farch-package.tar.xz$"
)

wget --retry-connrefused --tries=30 "$TARBALL_LINK" -O ./"${TARBALL_LINK##*/}"

mkdir -p ./AppDir/bin
tar -xvf ./"${TARBALL_LINK##*/}"
mv -v ./librewolf/* ./AppDir/bin

echo "$TARBALL_LINK" | awk -F'/' '{print $(NF-1); exit}' > ~/version
