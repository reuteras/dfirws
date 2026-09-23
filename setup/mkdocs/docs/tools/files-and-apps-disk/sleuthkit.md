# Sleuthkit

**Category:** Files and apps / Disk

**Homepage:** <http://www.sleuthkit.org/sleuthkit/>

**Vendor:** sleuthkit


**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.dd`, `.raw`, `.E01`, `.img`, `.vmdk`

**Tags:** disk-forensics, filesystem, forensics

The Sleuth Kit® (TSK) is a library and collection of command line digital forensics tools that allow you to investigate volume and file system data. The library can be incorporated into larger digital forensics tools and the command line tools can be directly used to find evidence.

## Tips
Command line file system tools: mmls for partitions, fls for listing files, icat to extract by inode, tsk_recover for bulk recovery, blkls for unallocated space and mactime for timelines.

## Usage
mmls image.E01 ; fls -o <sector offset> -r image.E01
