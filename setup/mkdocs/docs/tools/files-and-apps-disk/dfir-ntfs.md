# dfir_ntfs

**Category:** Files and apps / Disk

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.mft`, `.dd`, `.raw`, `.img`

**Tags:** ntfs, filesystem, forensics, disk-forensics

An NTFS/FAT parser for digital forensics & incident response.

## Tips
Parses NTFS (MFT, USN journal, LogFile) and FAT structures including deleted entries and can decrypt BitLocker volumes with a key. fat_parser.py handles FAT12/16/32 images.

## Usage
ntfs_parser.py <image or MFT file> --mft-csv out.csv
