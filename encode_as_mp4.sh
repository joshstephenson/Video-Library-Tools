#!/usr/bin/env bash

# Change this to true if you only want to mv files that are already mp4 files
# Leaving this as false will re-encode them when subtitles are found
FORCE_ENCODE=false
DIR="$(dirname ${BASH_SOURCE[0]})"
RECIPIENT=$(cat "$DIR/whom_to_notify.txt")

notify() {
# Don't attempt to notify anyone if a `whom_to_notify.txt` file is not present
    if [ -n $RECIPIENT ];
    then
    filename=$1
    echo $filename
    osascript -e 'tell application "Messages" to send "'"$1"' is done converting." to buddy "'"$RECIPIENT"'"'
    fi
}


# Cleans up original if already encoded
cleanup(){
    arguments="-fv"
    $move_command $arguments "$1" ~/.Trash/
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
  echo "successfully imported $(basename "$1") :)"
  sleep 1
}

# Moves MP4 file passed into this script to target dir
move_file(){
  filename="$1"
  newfilename="$2"
  echo "here: $newfilename"

  $move_command "$filename" "$newfilename"
  if [ -f "$newfilename" ]
  then
    import "$newfilename"
    cleanup "$filename"
  else
    echo "failed moving $newfilename :("
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
  echo "new: $newfilename"

  if [ -f "$newfilename" ]
  then
    echo "$newfilename already exists. Removing original."
    cleanup "$1"
  else
    subtitles="$(find "$(dirname "$1")" -name "*.srt" | paste -sd "," - )"

    # if this is already an mp4 and we don't have subtitles, then just move the file
    is_mp4=$(echo "$filename" | egrep '/*mp4$')
    if [ -n "$is_mp4" -a -z "$subtitles" ]
    then
      move_file "$filename" "$newfilename"

    # Otherwise let's encode it and include the subtitles
    else
      echo "Encoding $newfilename"

    # Look for subtitles
      arguments="-e x264 -q 20 -B 160"

      if [ -n "$subtitles" ]
      then
        echo "Subtitles found"
        $handbrake -i "$1" -o "$newfilename" $arguments --srt-file "$subtitles" 1> /dev/null 2>&1
      else
        $handbrake -i "$1" -o "$newfilename" $arguments 1> /dev/null 2>&1
      fi

      # Check that handbrake didn't return an error and the newfile exists
      if [ $? == 0 -a -f "$newfilename" ]
      then
        import "$newfilename"
        notify "$short_file"
        cleanup "$1"
        sleep 5
      else
        echo "Failed encoding $newfilename :(" >&2
        exit 1
      fi
    fi
  fi
}

handbrake=$(which HandBrakeCLI)
if [ ! -f "$handbrake" ]
then
  echo "No HandBrakeCLI command found"
  exit 1
fi

move_command=$(which mv)
if [ ! -f "$move_command" ]
then
  echo "No mv command found"
  exit 1
fi

# The file to re-encode
filename=$1
directory=$2
source_dir=$3

usage() {
  echo "$0 [Video File] [Destination Folder]"
  exit 1
}

if [ -z "$1" ]
then
    usage
else
  if [ -z "$2" ]
  then
    usage
  fi
fi

echo "Preparing to Encode"

is_sample=$(echo "$filename" | grep -i 'sample')

if [ -n "$is_sample" ]
then
  echo "Skipping sample file: $filename"
else
  encode_file "$filename"
fi

