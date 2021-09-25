# Video-Library-Tools
BASH shell scripts to encode non-MP4 files as MP4 suitable for Mac and Apple TV and synchronizes them to target directory. This file is meant to be used as a reference for how to encode files using BASH and HandBrakeCLI, not for any _production_ level use.

## Required Elements
- BASH and a Mac OS
- HandBrake via [HandBrake.fr](https://handbrake.fr) (Honestly, I'm not entirely sure yo
- HandBrakeCLI via [HandBrake.fr](https://handbrake.fr/downloads2.php) (You'll want to copy this to a bin directory, probably `/usr/local/bin` but as long as it's in your path encode_as_mp4.sh will find it.

## Main File (run this file directly)
### video_library_encoder.sh

### Usage:
If you want to run this directly, then issue these commands:
1. `chmod u+x video_library_encoder.sh`
2. `chmod u+x encode_as_mp4.sh`
3. `chmod u+x move_mp4.sh`

Then you can run it like this:

`./video_library_encoder.sh [Source folder] [Destination folder]`

## Auxiliary Files (these will be run by Main file above)
These files are outdated. They were intended for use with iTunes and need to be updated for use with Apple TV.

### encode_as_mp4.sh
This file will use HandBrake CLI to encode the file with output as the destination directory specified above. Destination folder will be passed from video_library_encoder.sh to this if you don't run it directly. This has good BASH scripting practices like checking for existence of files, directories and formatting file names and directory names properly before attempting to access.

### move_mp4.sh
This file will move the file in iTunes which is now deprecated so this needs to be updated. This has good examples for using `osascript` to tell apps to perform operations.
