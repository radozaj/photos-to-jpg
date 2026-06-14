#!/bin/sh

# usage
USAGE='USAGE: ./sortPhotosByAlphabet.sh old_folder new_folder'
if [ $# -ne 2 ]; then
	echo $USAGE
	exit
fi

# source (old) folder must to be readable
if [ ! -d "$1" ] || [ ! -r "$1" ]; then
	echo 'ERROR: old_folder is not readable folder'
	echo $USAGE
	exit
fi
FOLDER="$1"

# destination (new) folder must to be writeable
if [ ! -d "$2" ] || [ ! -w "$2" ]; then
	echo 'ERROR: new_folder is not writeble folder'
	echo $USAGE
	exit
fi
DEST="$2"

# order old folder to new folder
SEQ=1
ls -1 "$FOLDER" | while read FILE; do
	POS=`expr length "$FILE" - 3`
	END=`expr substr "$FILE" "$POS" 4`
	END=`echo "$END" | tr -s [:upper:] [:lower:]`
	cp "$FOLDER/$FILE" "$DEST/`printf "%03d" $SEQ`$END"
	SEQ=`expr $SEQ + 1`
done
