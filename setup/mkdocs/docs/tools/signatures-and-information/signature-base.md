# signature-base

**Category:** Signatures and information

**Homepage:** <https://github.com/Neo23x0/signature-base>

**Vendor:** Neo23x0

**License:** [Detection Rule License (DRL) 1.1](https://github.com/Neo23x0/signature-base?tab=License-1-ov-file)

**Source:** Git

**Profiles:** Full, Basic

**File Extensions:** `.yara`

**Tags:** yara, detection-rules, ioc

YARA signature and IOC database for my scanners and tools.

## Tips
The YARA rules and IOCs used by Loki and THOR. Some rules need external variables (filename, filepath, extension, filetype); Loki sets them for you, with plain yara pass -d filename=x or exclude those rules.

## Usage
yara -r C:\git\signature-base\yara <dir>
