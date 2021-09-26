#!/usr/bin/env bash

# Cleans up original if already encoded
cleanup(){
    directory="$(dirname "$1")/"
    echo "DIRECTORY: $directory"
    echo "SOURCE: $source_dir"
    if [ "$source_dir" == "$directory" ]
    then
        echo "Removing file only: $1"
        $remove_command "$1"
    else
        echo "Removing original file and directory: $directory"
        $remove_command -r "$directory"
    fi
}

# Takes a filename (mp4 file)
#  imports it into TV.app using the `open` command
#  Assumes TV.app is the default file type for MP4 files
#  waits 2 seconds for the import to complete
#  Then pauses TV.app which will start playing by default
#  NOTE: This is only meant to work when TV>>Preferences>>Files>>'Copy files to Media folder when adding to Library' is NOT checked. If this is checked then you'll want to increase the sleep period appropriate for your system's speed
import(){
  echo "Importing '$1' into TV"
  open "$1"
  sleep 2
  # Pause TV.app
  osascript -e 'tell application "TV"
pause
end tell' > /dev/null 2>&1
  cleanup "$1"
  echo "successfully imported $(basename "$1") :)"
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

  # Add trailing slash to directory if necessary
  trailing_slash=$(echo "$directory" | egrep "/$")
  if [ -z "$trailing_slash" ]
  then
    directory="$directory/"
  fi

  # strip the directory, leaving just the filename
  short_file="$(basename "$1")"

  # strip extension and replace with mp4
  short_file="${short_file%.*}.mp4"

  newfilename="$directory$short_file"

  echo "Moving $newfilename"
  if [ -f "$newfilename" ]
  then
    echo "$newfilename already exists."
    remove_flag=$(echo "$2" | grep "-x")
    if [ -n "$remove_flag" ]
    then
        echo "TESTING: Removing original file: $1"
        # $remove_command "$1"
    fi
  else
    echo "about to move"

    # looking for subtitles
    subtitles="$(find "$(dirname "$1")" -name "*.srt" )"
    if [ -n "$subtitles" ]
    then
      echo "Subtitles Found: $subtitles"
      $move_command "$subtitles" "$directory"
    fi
    $move_command "$1" "$newfilename"
    if [ -f "$newfilename" ]
    then
      import "$newfilename"
    else
      echo "failed moving $newfilename :("
    fi
  fi
}

# Encodes Non MP4 file passed into this script into  mp4
encode_file(){
  echo ""
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

  newfilename="$directory$short_file"

  if [ -f "$newfilename" ]
  then
    echo "$newfilename already exists. Removing original."
    cleanup "$1"
  else
    subtitles="$(find "$(dirname "$1")" -name "*.srt" )"
    if [ -n "$subtitles"]
    then
      echo "SUBTITLES Found: $subtitles"
      subtitles="-s $subtitles"
    fi
    echo "Encoding $newfilename"
    $handbrake -i "$1" -o "$newfilename" $arguments "$subtitles"
    if [ -f "$newfilename" ]
    then
      import "$newfilename"
      echo "Waiting 5 minutes before continuing."
      sleep 300
    else
      echo "failed encoding $newfilename :("
    fi
  fi
}

echo "Preparing to Encode"

handbrake=$(which HandBrakeCLI)
if [ ! -f "$handbrake" ]
then
  echo "No HandBrakeCLI command found"
  exit 1
fi
arguments="-e x264 -q 20 -B 160"

move_command=$(which mv)
if [ ! -f "$move_command" ]
then
  echo "No mv command found"
  exit 1
fi

remove_command=$(which rm)
if [ ! -f "$remove_command" ]
then
  echo "No rm command found"
  exit 1
fi

# The file to re-encode
filename=$1
directory=$2
source_dir=$3

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

is_sample=$(echo "$filename" | grep -i 'sample')

if [ -n "$is_sample" ]
then
  echo "Skipping sample file: $filename"
else
  is_mp4=$(echo "$filename" | grep -i '*mp4')
  if [ -n "$is_mp4" ]
  then
    move_file "$filename"
  else
    encode_file "$filename"
  fi
fi

