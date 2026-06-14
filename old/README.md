# photos-to-jpg

Convert *.jpg and *.heic to *.jpg with copying EXIF info and remaned by date of taken

## Installation

Install prerequisites

````bash
sudo apt install gimp
ln -s gimp-script/Smaller-photos.scm ~/.config/GIMP/3.0/scripts/Smaller-photos.scm
sudo apt install exiftool
````

## Usage

````bash
./allForHeic.sh source_folder target_folder
````

In target folder creates folder for each step:
* "1converted" - converted photos to jpg
* "2copiedexif" - photos with exif from heic
* "3renamed" - renamed photos by date of taken
