#!/bin/bash

echo "Generating UI resources for embedding"

LANTERN_UI="src/github.com/getlantern/lantern-ui"
APP="$LANTERN_UI/app"
DIST="$LANTERN_UI/dist"

if [ ! -d $DIST ] || [ $APP -nt $DIST ]; then
    # Install gulp (requires nodejs)
    echo "Installing gulp tool if necessary (requires nodejs)"
    which gulp || npm install -g gulp
    
    echo "Updating dist folder"
    cd $LANTERN_UI
    npm install
    rm -Rf dist
    gulp build
    cd -
else
    echo "Dist folder is up to date"
fi

echo "Generating resources.go"
go install github.com/getlantern/tarfs/tarfs
dest="src/github.com/getlantern/flashlight/ui/resources.go"
echo "// +build prod" > $dest
echo " " >> $dest
tarfs -pkg ui src/github.com/getlantern/lantern-ui/dist >> $dest 

echo "Now embedding lantern.ico to windows executable"
go install github.com/akavel/rsrc
rsrc -ico lantern.ico -o src/github.com/getlantern/flashlight/lantern.syso
