# hayabusa

**Category:** Files and apps / Log

**Homepage:** <https://github.com/Yamato-Security/hayabusa>

**Vendor:** Yamato-Security

**License:** AGPL-3.0

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.evtx`

**Tags:** log-analysis, event-log, sigma, detection, timeline, incident-response

Hayabusa (隼) is a sigma-based threat hunting and fast forensics timeline generator for Windows event logs.

## Tips
Sigma based EVTX hunting and timelining. Run update-rules from the network sandbox, then csv-timeline or json-timeline; analyse the output with takajo or Timeline Explorer.

## Usage
hayabusa.exe csv-timeline -d <evtx dir> -o timeline.csv
