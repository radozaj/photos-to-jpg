#!/bin/bash
# sudo apt install exiftool

# usage
USAGE='USAGE: ./renameByDate.sh source_folder target_folder'
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
	EXT="${FILE##*.}"
	DATE=`exiftool "${SOURCE_DIR}/${FILE}" | grep 'Date/Time Original'`
	DATE=`expr substr "$DATE" 35 19`
	DATE=`echo $DATE | sed -e 's/^\([0-9]*\):\([0-9]*\):\(.*\)$/\1-\2-\3/g'`
	if [ -z "${DATE}" ]; then
		echo "I can not read date from metadata of $FILE"
		continue
	fi
	DATE=`date '+%Y-%m-%d_%H-%M-%S' -d "$DATE"`
	I=0
	TARGET="${TARGET_DIR}/${DATE}.${EXT}"
	while [ -f "$TARGET" ]; do
		I=`expr $I + 1`
		TARGET="${TARGET_DIR}/${DATE}_${I}.${EXT}"
	done
	cp "${SOURCE_DIR}/${FILE}" "${TARGET}"
done
