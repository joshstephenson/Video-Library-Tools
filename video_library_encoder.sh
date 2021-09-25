#!/usr/bin/env bash

dir=$(dirname ${BASH_SOURCE[0]})
encode="$dir/encode_as_mp4.sh"
move="$dir/move_mp4.sh"

source_dir="$1"
target_dir="$2"

usage() {
    echo "$0 [Source folder] [Destination folder]"
    exit
}

# Find non-MP4 files in the directory specified on the command line
if [ -z "$source_dir" ]
then
  usage
fi

if [ -z "$target_dir" ]
then
  usage
fi

echo "Looking for video files in $1"

# Find non-mp4 video files in the directory passed via command line.
# For each file, encode it

find $source_dir \( -name "*mp4" \) -exec \
$move {} "$target_dir" \;

find $source_dir \( -name "*avi" -o -name "*mkv" -o -name "*m4v" -o -name "*mpeg" -o -name "*divx" \) -exec \
$encode {} "$target_dir" \;

