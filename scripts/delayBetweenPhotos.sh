#!/bin/sh
#install imagemagick!

# usage
USAGE='USAGE: ./delayBetweenPhotos.sh photo1 photo2'
if [ $# -ne 2 ]; then
	echo $USAGE
	exit
fi

# the first photo must to be readable photo
if [ ! -f "$1" ] || [ ! -r "$1" ]; then
	echo 'ERROR: photo1 is not readable photo'
	echo $USAGE
	exit
fi
PHOTO1="$1"

# the second photo must to be readable photo
if [ ! -f "$2" ] || [ ! -r "$2" ]; then
	echo 'ERROR: photo2 is not readable photo'
	echo $USAGE
	exit
fi
PHOTO2="$2"

# calculate different between photos in seconds
DATE1=`identify -verbose "$PHOTO1" | grep exif:DateTimeOriginal`
DATE1=`echo "$DATE1" | sed -e 's/.*\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\) \([0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\)$/\1-\2-\3 \4/'`
DATE1=`date -d "$DATE1" +%s`
DATE2=`identify -verbose "$PHOTO2" | grep exif:DateTimeOriginal`
DATE2=`echo "$DATE2" | sed -e 's/.*\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\) \([0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\)$/\1-\2-\3 \4/'`
DATE2=`date -d "$DATE2" +%s`
echo $PHOTO1 `expr $DATE1 - $DATE2`
