# Trawler

**Category:** IR

**Homepage:** <https://github.com/joeavanzato/Trawler>

**Vendor:** joeavanzato

**License:** [MIT License](https://github.com/joeavanzato/Trawler/blob/main/LICENSE)

**Source:** Git

**Profiles:** Full, Basic

**Tags:** windows, malware-analysis, threat-hunting

PowerShell script helping Incident Responders discover potential adversary persistence mechanisms.

## Tips
Trawler hunts persistence on a live system. In the sandbox point it at a mounted image or a KAPE collection with -drivetarget and the hive parameters to review persistence offline; PyrsistenceSniper is the Python alternative.

## Usage
Get-Help trawler ; trawler -scanoptions All
