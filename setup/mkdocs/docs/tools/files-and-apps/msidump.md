# msidump

**Category:** Files and apps

**Homepage:** <https://github.com/mgeeky/msidump>

**Vendor:** mgeeky


**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.msi`

**Tags:** ioc, data-extraction, enrichment, parsing, forensics

MSI Dump - a tool that analyzes malicious MSI installation packages, extracts files, streams, binary data and incorporates YARA scanner.

## Tips
Lists tables, custom actions and embedded binaries of an MSI and flags suspicious ones; -y runs YARA on the extracted streams. lessmsi is the GUI alternative for benign packages.

## Usage
msidump.py <file.msi> -e <extract dir>
