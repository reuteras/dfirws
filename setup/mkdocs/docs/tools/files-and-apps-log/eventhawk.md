# EventHawk

**Category:** Files and apps / Log

**Homepage:** <https://github.com/Mihir-Choudhary/EventHawk>

**Vendor:** Mihir-Choudhary

**License:** [Apache License 2.0](https://github.com/Mihir-Choudhary/EventHawk/blob/main/LICENSE)

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.evtx`

**Tags:** event-log, log-analysis, threat-hunting, mitre-attack, ioc

EventHawk parses Windows EVTX logs at speed, maps events to MITRE ATT&CK techniques, extracts IOCs and exports to JSON, CSV, XML, HTML, PDF, STIX 2.1, OpenIOC and YARA. Analysis profiles focus on themes such as logon activity, and the Sentinel module builds a baseline from known-good logs and flags anomalies with Sigma rules. Includes a Qt GUI.

## Tips
Run it through eventhawk.ps1 so the dedicated virtual environment is used. Start with 'eventhawk.ps1 profiles' to list the built-in analysis profiles, then 'parse' a folder of EVTX files with --profile and --output. Use --juggernaut for very large collections (DuckDB backed). Hayabusa integration is optional and picks up the hayabusa binary already in dfirws.

## Usage
eventhawk.ps1 parse <evtx folder> --profile <profile> --output results.json

## Sample Commands
- `eventhawk.ps1 profiles`
- `eventhawk.ps1 parse C:\Users\WDAGUtilityAccount\Desktop\readwrite\evtx --profile "Logon/Logoff Activity" --output results.json`
- `eventhawk.ps1 gui`
