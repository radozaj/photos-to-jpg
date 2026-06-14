#!/bin/bash

# usage
USAGE='USAGE: ./convertSortAndResize.sh source_folder target_folder [ prefix delay_sec ] [ ... ]'
if [ $# -lt 2 ]; then
    echo "$USAGE"
    exit 1
fi

# source folder must to be readable
if [ ! -d "$1" ] || [ ! -r "$1" ]; then
    echo 'ERROR: source_folder is not readable folder'
    echo "$USAGE"
    exit 1
fi
SOURCE_DIR=$(echo "$1" | sed -e "s/\/*$//")

# target folder must to be writeable
if [ ! -d "$2" ] || [ ! -w "$2" ]; then
    echo 'ERROR: target_folder is not writeble folder'
    echo "$USAGE"
    exit 1
fi
TARGET_DIR=$(echo "$2" | sed -e "s/\/*$//")

# Všetky argumenty od tretieho ďalej (posuny času) uložíme do poľa
shift 2
DELAY_ARGS=("$@")

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Teraz povieme Pythonu presnú cestu k súboru convert_photos.py
python3 "$SCRIPT_DIR/convert_photos.py" "$SOURCE_DIR" "$TARGET_DIR" "${DELAY_ARGS[@]}"