# Video-Library-Tools
BASH shell scripts to encode non-MP4 files as MP4 suitable for Mac and Apple TV and synchronizes them to target directory. This file is meant to be used as a reference for how to encode files using BASH and HandBrakeCLI, not for any _production_ level use.

## Required Elements
- BASH and a Mac OS
- HandBrake via [HandBrake.fr](https://handbrake.fr) (Honestly, I don't know if HandBrakeCLI requires this GUI-based encoder, but it's nice to have around anyway).
- HandBrakeCLI via [HandBrake.fr](https://handbrake.fr/downloads2.php) (You'll want to copy this to a bin directory, probably `/usr/local/bin` but as long as it's in your path encode_as_mp4.sh will find it.

### Main File (run this file directly)

[video_library_encoder.sh](video_library_encoder.sh)

#### Usage:
If you want to run this directly, then issue this command from Terminal:

`chmod u+x video_library_encoder.sh encode_as_mp4.sh move_mp4.sh`

Then you can run it like this:

`./video_library_encoder.sh [Source folder] [Destination folder]`

Any files ending in avi, mkv, m4v, mpeg or divx will be converted to mp4. If you need to add other extensions, add them to the second to last line of this file.

### Auxiliary File (this will be run by Main file above)

[encode_as_mp4.sh](encode_as_mp4.sh)

This file will:
1. Check extension. If it's already an MP4 it will skip the following step.
2. If not in MP4, use HandBrakeCLI to encode the file with output as the destination directory specified above. Destination folder will be passed from `video_library_encoder.sh` to this if you don't run it directly. Subtitles will be used if found in same directory.
3. Original file and or it's parent directory (if the video file was found inside a subdirectory of the source folder) will be moved to Trash.

This has good BASH scripting practices like checking for existence of files, directories and formatting file names and directory names properly before attempting to access.



