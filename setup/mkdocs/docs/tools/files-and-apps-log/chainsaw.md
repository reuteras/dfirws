# chainsaw

**Category:** Files and apps / Log

**Homepage:** <https://github.com/WithSecureLabs/chainsaw>

**Vendor:** WithSecureLabs

**License:** GPL-3.0

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.evtx`

**Tags:** log-analysis, incident-response, sigma, detection

Rapidly Search and Hunt through Windows Forensic Artefacts

## Tips
Fast Sigma based hunting in EVTX plus search and dump commands for other artifacts (MFT, SRUM, shimcache). Use the mappings shipped with chainsaw and add chainsaw-rules for more coverage.

## Usage
chainsaw hunt <evtx dir> -s <sigma rules dir> --mapping <mapping.yml>
