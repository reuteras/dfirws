# bmc-tools

**Category:** Files and apps / RDP

**Homepage:** <https://github.com/ANSSI-FR/bmc-tools>

**Vendor:** ANSSI-FR

**License:** [CECILL-2.1 License](https://github.com/ANSSI-FR/bmc-tools/blob/master/LICENCE.txt)

**Source:** Git

**Profiles:** Full, Basic

**Tags:** forensics, network, windows

RDP Bitmap Cache parser

## Tips
Parse RDP bitmap cache files from Users\<user>\AppData\Local\Microsoft\Terminal Server Client\Cache. The -b option writes a collage; feed the individual tiles into RdpCacheStitcher to reconstruct what was seen on screen.

## Usage
bmc-tools.py -s <bcache or cache file or folder> -d <output dir> -b
