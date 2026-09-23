# APT-Hunter

**Category:** Files and apps / Log

**Homepage:** <https://github.com/ahmedkhlief/APT-Hunter>

**Vendor:** ahmedkhlief

**License:** [GPL-3.0 License](https://github.com/ahmedkhlief/APT-Hunter/blob/main/LICENSE)

**Source:** Git

**Profiles:** Full, Basic

**File Extensions:** `.evtx`

**Tags:** event-log, threat-hunting

APT-Hunter is Threat Hunting tool for windows event logs which made by purple team mindset to provide detect APT movements hidden in the sea of windows event logs to decrease the time to uncover suspicious activity.

## Tips
Feed it a folder of exported EVTX files (Security, System, PowerShell, Sysmon, TerminalServices and others). Output is CSV and Excel with detections plus a timeline; combine with hayabusa or chainsaw for broader Sigma coverage.

## Usage
python C:\git\APT-Hunter\APT-Hunter.py -p <folder with evtx files> -o <output name> -allreport
