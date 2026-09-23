# dissect

**Category:** Forensics

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.dd`, `.raw`, `.tar`

**Tags:** forensics, incident-response, data-extraction

target-query -f users <image>

## Tips
The Dissect framework: target-query runs plugins against images (E01, VMDK, VHDX, tar, acquire collections) without mounting, target-shell browses the file system and target-dump exports records. Pipe records into rdump for CSV or JSON.

## Usage
target-query -f users <image>
