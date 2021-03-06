#!/usr/bin/bash

# This script will download flatpak image logos and create assets sized for the
# Steam Deck.
#
# Simply, go to flathub.org or beta.flathub.org. Look up the app, then note the
# url.
#
# It will be something like:
#
#     https://beta.flathub.org/apps/details/com.test.App
#
# Copy the com.test.App part for your app, and paste it as shown below.
#
# Alternatively run with no parameters to fetch assets for all installed apps
# from Discover.
#
# Usage:
# 
#     mksdasset.sh [APP]


APP_DIR="/home/deck/.var/app"
ASSET_DIR="/home/deck/Pictures/AppAssets"
# Maybe use a custom color in the future
COLOR="black"

# Doubles the size of the original image and centers it in rectangle.
# $1 = Width of rectangle
# $2 = Height of rectangle
# $3 = App name
mkasset() {
    local w=$1
    local h=$2
    local name=$3
    local location="$ASSET_DIR/$name"
    local ow=($w/2)-128
    local oh=($h/2)-128
    
    ffmpeg -y -i "$location/$name.jpg" -qscale:v 0 -vf "scale=256:256,pad=$w:$h:$ow:$oh:color=$COLOR" "$location/${w}x${h}-$name.jpg" 
}

# Downloads icon and generates assets of a given app.
# Icons are converted to jpg to remove transparency.
# $1 = App name
fetch_asset() {
    local name=$1
    local location="$ASSET_DIR/$name"
    
    mkdir -p $location
    curl "https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/$name.png" > "$location/$name.png"
    ffmpeg -y -i "$location/$name.png" -qscale:v 2 "$location/$name.jpg"
    mkasset 600 900 $name
    mkasset 3840 1240 $name
    mkasset 1280 720 $name
    mkasset 2108 460 $name
    rm "$location/$name.png"
}

###### #
# MAIN #
########
if [ $# -eq 0 ]
then
    mkdir -p "$ASSET_DIR"

    for app in $APP_DIR/*
    do
        app_name=`basename "$app"`
        fetch_asset $app_name
    done
else
    for app_name in "$@"
    do
        fetch_asset $app_name
    done
fi

exit
