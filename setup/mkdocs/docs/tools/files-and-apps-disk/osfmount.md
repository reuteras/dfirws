# OSFMount

**Category:** Files and apps / Disk

**Source:** HTTP

**Profiles:** Full, Basic

**File Extensions:** `.dd`, `.raw`, `.E01`, `.img`, `.vmdk`, `.iso`

**Tags:** disk-forensics, filesystem

OSFMount is a tool for mounting disk images and virtual hard disks as virtual drives. It can be used for analyzing disk images, accessing files within them, and performing forensic analysis on the mounted images.

## Tips
Install on demand. Mounts E01, raw, VHD, VMDK and ISO images read-only as drive letters so other tools can parse the file system. Use the write cache option only when you need to boot or modify a copy.

## Usage
dfirws-install.ps1 -OSFMount
