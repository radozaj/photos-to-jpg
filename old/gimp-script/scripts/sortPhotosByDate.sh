#!/bin/sh

# usage
USAGE='USAGE: ./sortPhotosByDate.sh source_fld target_fld [ prefix delay_sec ] [ ... ]'
if [ $# -lt 2 ]; then
	echo $USAGE
	exit
fi

# test readable source folder
if [ ! -d "$1" ] || [ ! -r "$1" ]; then
	echo 'ERROR: Source folder is not readable folder'
	echo $USAGE
	exit
fi
SOURCE="$1"

# test writable target folder
if [ ! -d "$2" ] || [ ! -w "$2" ]; then
	echo 'ERROR: Target folder is not writeable folder'
	echo $USAGE
	exit
fi
TARGET="$2"

# test number delay in seconds
i=0
for ARG in "$@"; do
	i=`expr $i + 1`
	if [ `expr $i % 2` -eq 0 ] && [ $i -ne 2 ]; then
		if [ $ARG -eq $ARG 2> /dev/null ]; then
			a=$a # foo
		else
			echo "ERROR: \"$ARG\" delay_sec is not valid number"
			echo $USAGE
			exit
		fi
	fi
done

# temp file contain list of photos for ordering
LIST=`mktemp /tmp/list.XXXXXXXX`

# list of unordered photos
echo 'Detecting date taken...'
ls -1 "$SOURCE" | grep --ignore-case .JPG | while read PHOTO; do

	# zisti cas vytvorenia fotky
	DATE=`identify -verbose "$SOURCE/$PHOTO" | grep exif:DateTimeOriginal`
	DATE=`echo $DATE | sed -e 's/.*\([0-9]\{4\}\):\([0-9]\{2\}\):\([0-9]\{2\}\) \([0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\)$/\1-\2-\3 \4/'`
	DATE=`date -d "$DATE" +%s`

	# upravy cas podla prefixov
	i=0
	for ARG in "$@"; do
		i=`expr $i + 1`
		if [ $i -gt 2 ]; then
			if [ `expr $i % 2` -eq 0 ]; then
				if [ ! -n "`echo $PHOTO | grep "^$PREFIX"`" ]; then
					DATE=`expr $DATE + $ARG`
				fi
			else
			    PREFIX=$ARG
			fi
		fi
	done

	# ulozi do suboru
	echo $DATE $SOURCE/$PHOTO >> $LIST
	echo "	$PHOTO"
done

sort $LIST | sed -e 's/^[0-9]*//' > ${LIST}.new
echo 'Ordering photos...'
SEQ='1'
while read -r LINE; do
	SEQ=`printf "%03d" $SEQ`
	cp "$LINE" "$TARGET/$SEQ.jpg"
	SEQ=`expr $SEQ + 1`
done < ${LIST}.new

rm $LIST ${LIST}.new
