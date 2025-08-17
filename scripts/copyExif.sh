#!/bin/bash
# sudo apt install exiftool

# usage
USAGE='USAGE: ./copyExif.sh source_folder target_folder'
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
SOURCE_DIR="$1"

# target folder must to be writeable
if [ ! -d "$2" ] || [ ! -w "$2" ]; then
	echo 'ERROR: target_folder is not writeble folder'
	echo $USAGE
	exit
fi
TARGET_DIR="$2"


ls -1 "$SOURCE_DIR" | while read FILE; do
	EXT=`echo "${FILE##*.}" | tr '[:upper:]' '[:lower:]'`
	if [[ "$EXT" =~ "heic" ]] || [[ "$EXT" =~ "jpg" ]] || [[ "$EXT" =~ "jpeg" ]]; then
		NAME=`echo $FILE | sed -e 's/^\(.*\)\..*$/\1/g'`
		echo ">> copy exif to: ${NAME}.jpg"
		# from HEIC or JPEG copy EXIF
		exiftool -wm cg -tagsfromfile "${SOURCE_DIR}/${FILE}" -all:all "${TARGET_DIR}/${NAME}.jpg"
		rm -f "${TARGET_DIR}/${NAME}.jpg_original"
	fi
done
