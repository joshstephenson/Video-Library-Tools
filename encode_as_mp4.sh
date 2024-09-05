#!/usr/bin/env bash

# Change this to true if you only want to mv files that are already mp4 files
# Leaving this as false will re-encode them when SUBTITLES are found
DIR=$(dirname "${BASH_SOURCE[0]}")
RECIPIENT=$(cat "$DIR/whom_to_notify.txt")

notify() {
# Don't attempt to notify anyone if a `whom_to_notify.txt` file is not present
        if [ -n "$RECIPIENT" ];
        then
        FILENAME=$1
        echo "$FILENAME"
        osascript -e 'tell application "Messages" to send "'"$1"' is done converting." to buddy "'"$RECIPIENT"'"'
        fi
}

cleanup(){
    echo "Moving ${1} to Trash."
    ARGUMENTS="-fv"
    $MOVE_COMMAND $ARGUMENTS "$1" ~/.Trash/
}


import(){
    # Takes a filename (mp4 file)
#    imports it into TV.app using the `open` command
#    Assumes TV.app is the default file type for MP4 files
#    waits 2 seconds for the import to complete
#    Then pauses TV.app which will start playing by default
#    NOTE: This is only meant to work when TV>>Preferences>>Files>>'Copy files to Media folder when adding to Library' is NOT checked. If this is checked then you'll want to increase the sleep period appropriate for your system's speed
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
    FILENAME="$1"
    NEW_FILENAME="$2"
    echo "here: $NEW_FILENAME"

    $MOVE_COMMAND "$FILENAME" "$NEW_FILENAME"
    if [ -f "$NEW_FILENAME" ]
    then
        import "$NEW_FILENAME"
        cleanup "$FILENAME"
    else
        echo "Failed moving $NEW_FILENAME :("
    fi
}

run() {
    echo "Encoding $2"
    if [ -n "$3" ] && [ -n "$4" ] # We have subtitles
    then
        $HANDBRAKE_CMD -i "$1" -o "$2" -e x264 --aencoder copy:aac --srt-file "$3" --srt-lang "$4" #1> /dev/null 2>&1
    else
        $HANDBRAKE_CMD -i "$1" -o "$2" -e x264 --aencoder copy:aac #1> /dev/null 2>&1
    fi
}

get_subtitle_files() {
    # Get the names of the SUBTITLES from the names of the files
    SUBS=()
    for SRT in ${1}; do
        SUBS+=( "$SRT" )
    done
    SUB_STR=$(IFS=, ; echo "${SUBS[*]}")
}

get_subtitle_langs() {
    # Get the names of the SUBTITLES from the names of the files
    LANGS=()
    for SRT in ${1}; do
        # Assumes the subtitle file is named the language of the SUBTITLES
        LANG=$(echo "${SRT}" | tr '/' '.' | awk -F'.' '{print $(NF-1)}')
        LANGS+=( "$LANG" )
    done
    LANG_STR=$(IFS=, ; echo "${LANGS[*]}")
}

# Encodes Non MP4 file passed into this script into    mp4
encode_file(){
    if [ -z "$1" ]
    then
        echo "You must provide a filename argument to encode_file()"
        exit 1
    fi

    FILENAME="${1}"
    TRAILING_SLASH=$(echo "$DIRECTORY" | grep -E "/$")
    if [ -z "$TRAILING_SLASH" ]
    then
        DIRECTORY="$DIRECTORY/"
    fi

    # strip the DIRECTORY, leaving just the FILENAME
    SHORT_FILE="$(basename "$FILENAME")"

    # strip extension and replace with mp4
    SHORT_FILE="${SHORT_FILE%.*}.mp4"

    NEW_FILENAME="$DIRECTORY$SHORT_FILE"

    if [ -f "$NEW_FILENAME" ]
    then
        echo "$NEW_FILENAME already exists. Exiting..."
        exit
    fi

    IFS=$'\n'
    SUBTITLES=$(find "$(dirname "$FILENAME")" -name "*.srt" )

    if [ -n "$SUBTITLES" ]
    then
        get_subtitle_files "$SUBTITLES"
        get_subtitle_langs "$SUBTITLES"
    fi

    run "$FILENAME" "$NEW_FILENAME" "$SUB_STR" "$LANG_STR"

    if [ $? == 0 ]  && [ -f "$NEW_FILENAME" ]
    then
        import "$NEW_FILENAME"
        notify "$SHORT_FILE"
        cleanup "$1"
        sleep 5
    else
        echo "Failed encoding $NEW_FILENAME :(" >&2
        exit 1
    fi
}

HANDBRAKE_CMD=$(which HandBrakeCLI)
if [ ! -f "$HANDBRAKE_CMD" ]
then
    echo "No HandBrakeCLI command found"
    exit 1
fi

MOVE_COMMAND=$(which mv)
if [ ! -f "$MOVE_COMMAND" ]
then
    echo "No mv command found"
    exit 1
fi

# The file to re-encode
FILENAME=$1
DIRECTORY=$2

usage() {
    echo "$0 [Video File] [Destination Folder]"
    exit 1
}

if [ -z "$1" ] || [ -z "$2" ]
then
    usage
fi

IS_SAMPLE=$(echo "$FILENAME" | grep -i 'sample')

if [ -n "$IS_SAMPLE" ]
then
    echo "Skipping sample file: $FILENAME"
else
    encode_file "$FILENAME"
fi

