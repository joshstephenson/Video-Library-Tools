#!/usr/bin/env bash

echo "Preparing to Move and Import"

command=$(which mv)
if [ ! -f "$command" ]
then
  echo "No command found"
  exit 1
fi

# The file to re-encode
filename=$1
directory=$2

if [ -z "$1" ]
then
  echo "You must specify a file to encode"
  exit 1
else
  if [ -z "$2" ]
  then
    echo "You must specify a target directory"
    exit 1
  fi
fi

# Takes a filename (mp4 file)
#  imports it into iTunes using the `open` command
#  waits 2 seconds for the import to complete
#  Then pauses iTunes which will start playing the file by default
#  NOTE: This is only meant to work when iTunes>>Preferences>>Advanced>>'Copy files to iTunes Media folder when adding to library' is NOT checked. If this is checked then you'll want to increase the sleep period appropriate for your system's CPU power
import(){
  echo "Importing '$1' into iTunes"
  open "$1"
  sleep 2
  # Pause iTunes
  osascript -e 'tell application "iTunes"
pause
end tell' > /dev/null 2>&1
  sleep 1
}

# Moves MP4 file passed into this script to target dir
move_file(){
  if [ -z "$1" ]
  then
    echo "You must provide a filename to encode_file()"
    exit 1
  fi
  echo "Encoding file: $1"

  trailing_slash=$(echo "$directory" | egrep "/$")
  if [ -z "$trailing_slash" ]
  then
    echo "needs trailing slash"
    directory="$directory/"
  fi

  # strip the directory, leaving just the filename
  short_file="$(basename "$1")"

  # strip extension and replace with mp4
  short_file="${short_file%.*}.mp4"
  echo "short_file: $short_file"

  newfilename="$directory$short_file"

  echo "Moving $newfilename"
  if [ -f "$newfilename" ]
  then
    echo "$newfilename already exists. not overwriting."
  else
    echo "about to move"

    # not doing anythnig with subtitles yet
    subtitles="$(find "$(dirname "$1")" -name "*.srt" )"
    if [ -n "$subtitles" ]
    then
      echo "SUBTITLES Found: $subtitles"
      $command "$subtitles" "$directory"
    fi
    $command "$1" "$newfilename"
    if [ -f "$newfilename" ]
    then
      import "$newfilename"
      echo "successfully moved $newfilename :)"
      echo "Waiting 0 minutes before continuing. Good CPU :)"
    else
      echo "failed moving $newfilename :("
    fi
  fi
}

is_sample=$(echo "$filename" | grep -i 'sample')

if [ -n "$is_sample" ]
then
  echo "Skipping sample file: $filename"
else
  move_file "$filename"
fi
echo ""