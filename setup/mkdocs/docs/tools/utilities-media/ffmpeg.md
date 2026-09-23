# ffmpeg

**Category:** Utilities / Media

**Homepage:** <https://github.com/BtbN/FFmpeg-Builds>

**Vendor:** BtbN

**License:** MIT

**Source:** GitHub Release

**Profiles:** Full (not included in Basic profile)

**File Extensions:** `.mp4`, `.avi`, `.mkv`, `.mov`, `.mp3`, `.wav`, `.flac`

**Tags:** audio, conversion

ffmpeg is a free and open-source multimedia framework for processing video and audio files. It can be used to convert between different formats, extract audio from video files, and perform various other multimedia processing tasks.

## Tips
Convert media or extract audio and frames from video evidence (ffmpeg -i in.mp4 -vf fps=1 frame%04d.png). ffprobe prints container and stream metadata.

## Usage
ffmpeg -i input.mp4 output.wav
