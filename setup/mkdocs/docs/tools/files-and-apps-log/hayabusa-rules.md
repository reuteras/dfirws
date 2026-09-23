# hayabusa-rules

**Category:** Files and apps / Log

**Homepage:** <https://github.com/Yamato-Security/hayabusa-rules>

**Vendor:** Yamato-Security


**Source:** Git

**Profiles:** Full, Basic

**File Extensions:** `.evtx`

**Tags:** event-log, detection-rules, sigma

Curated Windows event log Sigma rules used in Hayabusa and Velociraptor.

## Tips
The curated Sigma rules used by hayabusa, also usable with other Sigma tools. Keep the checkout current since detections change often.

## Usage
hayabusa.exe csv-timeline -d <evtx dir> -r C:\git\hayabusa-rules -o timeline.csv
