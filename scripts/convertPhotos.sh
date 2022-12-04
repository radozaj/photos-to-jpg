#!/bin/bash
# cp Smaller-photos.scm ~/.config/GIMP/2.10/scripts

# usage
USAGE='USAGE: ./convertPhotos.sh source_folder target_folder'
if [ $# -ne 2 ]; then
	echo $USAGE
	exit
fi

# source folder must to be readable
if [ ! -d "$1" ] || [ ! -r "$1" ]; then
	echo 'ERROR: source_folder is not readable folder'
	echo $USAGE
	exit
fi
SOURCE_DIR=`echo "$1" | sed -e "s/\/*$//"`

# target folder must to be writeable
if [ ! -d "$2" ] || [ ! -w "$2" ]; then
	echo 'ERROR: target_folder is not writeble folder'
	echo $USAGE
	exit
fi
TARGET_DIR=`echo "$2" | sed -e "s/\/*$//"`

gimp -i -b "(Smaller-photos \"${SOURCE_DIR}\" 1 \"${TARGET_DIR}\" 1 3648)" -b '(gimp-quit 0)'
