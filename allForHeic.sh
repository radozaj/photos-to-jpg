#!/bin/bash

# usage
USAGE='USAGE: ./allForHeic.sh source_folder target_folder'
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

SCRIPT_DIR=`dirname $0`/scripts

DIR_CONVERTED="${TARGET_DIR}/1converted"
mkdir "${DIR_CONVERTED}"
${SCRIPT_DIR}/convertPhotos.sh "${SOURCE_DIR}" "${DIR_CONVERTED}"

DIR_COPIEDEXIF="${TARGET_DIR}/2copiedexif"
cp -R "${DIR_CONVERTED}" "${DIR_COPIEDEXIF}"
${SCRIPT_DIR}/copyExif.sh "${SOURCE_DIR}" "${DIR_CPIEDEXIF}"

DIR_RENAMED="${TARGET_DIR}/3renamed"
mkdir "${DIR_RENAMED}"
${SCRIPT_DIR}/renameByDate.sh "${DIR_CONVERTED}" "${DIR_RENAMED}"

