#!/usr/bin/env bash

dir="$(dirname ${BASH_SOURCE[0]})"
encode="$dir/encode_as_mp4.sh"
move="$dir/move_mp4.sh"
handbrake=$(which HandBrakeCLI)

source_dir="$1"
target_dir="$2"

usage() {
    echo "$0 [Source folder] [Destination folder]"
    exit 1
}

if [ -z "$source_dir" ]
then
  usage
fi

if [ -z "$target_dir" ]
then
  usage
fi

trailing_slash=$(echo "$source_dir" | egrep "/$")
if [ -z "$trailing_slash" ]
then
source_dir="$source_dir/"
fi

echo "Looking for video files in $1"

# First check to see if HandBrake is running already
# Due to HandBrake's system load, it's best not to run in parallel
if [ $(ps ax | grep $handbrake | egrep -v grep | wc -l) -gt 0 ]
then
    echo "HandBrakeCLI is already running. Aborting."
    exit 0
fi

# Find video files in the directory passed via command line.
# For each file, encode it
while [ $(find -s $source_dir \( -name "*mp4" -o -name "*avi" -o -name "*mkv" -o -name "*m4v" -o -name "*mpeg" -o -name "*divx" \) | wc -l) -gt 0 ]
do
    first=$(find -s $source_dir \( -name "*mp4" -o -name "*avi" -o -name "*mkv" -o -name "*m4v" -o -name "*mpeg" -o -name "*divx" \) | head -1)
    $encode "$first" "$target_dir"
done

# Old meth of using find -exec directly did not pick up new files when adding during batch execution
# Above method of using while loop is superior for that purpose
#find -s $source_dir \( -name "*mp4" -o -name "*avi" -o -name "*mkv" -o -name "*m4v" -o -name "*mpeg" -o -name "*divx" \) -exec \
#$encode {} "$target_dir" "$source_dir" \;

