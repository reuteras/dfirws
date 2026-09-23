# Autopsy

**Category:** Forensics

**Homepage:** <http://www.sleuthkit.org/autopsy/>

**Vendor:** sleuthkit


**Source:** GitHub Release

**Profiles:** Full (not included in Basic profile)

**File Extensions:** `.dd`, `.raw`, `.E01`, `.img`, `.vmdk`

**Tags:** disk-forensics, forensics, gui, artifact-extraction

Autopsy is a digital forensics platform that allows users to analyze disk images and extract artifacts from them. It provides a graphical user interface for examining file systems, recovering deleted files, and analyzing network traffic.

## Tips
Install on demand since it is large. Create the case in the readwrite folder so it survives closing the sandbox, and add modules from autopsy_addon_modules if you need them.

## Usage
dfirws-install.ps1 -Autopsy
