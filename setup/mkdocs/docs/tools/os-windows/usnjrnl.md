# usnjrnl

**Category:** OS / Windows

**Source:** Cargo

**Profiles:** Full, Basic

**File Extensions:** `.bin`

**Tags:** filesystem, forensics, ntfs, windows

The usnjrnl tool is a command-line utility for parsing Windows UsnJrnl files. It allows you to extract and analyze information from the USN Journal, which is a feature of the NTFS file system that tracks changes to files and directories. This tool can be useful for forensic investigations and understanding file system activity.

## Tips
Export the J stream of the UsnJrnl from the image first (icat from Sleuthkit or MFTECmd can do it). The output includes the reason flags; filter on FILE_CREATE and RENAME_NEW_NAME to spot tool staging and cleanup.

## Usage
usnjrnl_dump <UsnJrnl J stream> > usn.csv
