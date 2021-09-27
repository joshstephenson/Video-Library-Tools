# Video-Library-Tools
BASH shell scripts to encode non-MP4 files as MP4 suitable for Mac and Apple TV and synchronizes them to target directory. This file is meant to be used as a reference for how to encode files using BASH and HandBrakeCLI, not for any _production_ level use.

## Required Elements
- BASH and Mac OS
- HandBrakeCLI via [HandBrake.fr](https://handbrake.fr/downloads2.php) (You'll want to copy this to a bin directory, probably `/usr/local/bin` but as long as it's in your path encode_as_mp4.sh will find it.

### Main File (run this file directly)

[video_library_encoder.sh](video_library_encoder.sh)

#### Usage
If you want to run this directly, then issue this command from Terminal to make the file executable:

`chmod u+x video_library_encoder.sh encode_as_mp4.sh`

Then you can run it like this:

`./video_library_encoder.sh [Source folder] [Destination folder]`

However, if you want to automate this script to run any time a new file is added to your movie folder, do this:
1. Open Automator.app
2. File >> New >> Folder Action
3. Drag "Run Shell Script" to the right hand pane (see "Drag actions or files here to build your workflow.")
4. Choose the folder where you download your (totally legitimately purchased) videos.
5. Paste the recipe below, making sure to modify the first 4 configuration variables if necessary

```
#################################################################
# Configuration Variables
#################################################################
PATH=$PATH:/usr/local/bin                        # This is the directory where you installed HandBrakeCLI
UNCONVERTED=~/Movies/Unconverted                    # This is where your avi, mkv and other non-mp4 files are
CONVERTED=~/Movies/Converted                        # This is where you want your mp4 files to go. Don't use a subdirectory of the above
PROJECT_PATH=~/Projects/Video-Library-Tools         # This is where you cloned this repository

#################################################################
# Internal - You shouldn't need to change these, but feel free to
#################################################################
ENCODER="$PROJECT_PATH/video_library_encoder.sh" 
LOGFILE="$PROJECT_PATH/log.txt"
echo "" >> $LOGFILE
echo $(date) >> $LOGFILE
$ENCODER $UNCONVERTED $CONVERTED >> $LOGFILE
```

#### What it Does
Any files ending in `avi`, `mkv`, `m4v`, `mpeg` or `divx` will be converted to `mp4`. If you need to add other extensions, add them to the second to last line of this file.

This file shows good BASH scripting practices like:
- check for existince of required arguments
- prompting with usage when arguments not passed
- using find command filtering for file extensions and passing each of those as arguments to another command

### Auxiliary File (this will be run by Main file above)

[encode_as_mp4.sh](encode_as_mp4.sh)

#### Usage

`./encode_as_mp4.sh [Video File] [Destination Folder]`

#### What it Does
This file will:
1. Check video's extension. If it's already an MP4 it will skip the following step.
2. If not in MP4, it will use HandBrakeCLI to encode the file as MP4. Destination folder will be passed from `video_library_encoder.sh` to this if you don't run it directly. Subtitles will be used if found in same directory.
3. Original file and or it's parent directory (if the video file was found inside a subdirectory of the source folder) will be moved to Trash.

This file shows good BASH scripting practices like:
- sanitizing directory names
- checking for existence of files
- moving files and safe-deletion via trash
- interacting with applications via `osascript`
- checking for successful encoding
- interacting with STDOUT and STDERR
- using `which` to find commands in the filesystem
- checking for equality of strings, checking for null strings and non-null strings
