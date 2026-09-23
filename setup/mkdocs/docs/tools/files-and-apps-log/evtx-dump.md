# evtx_dump

**Category:** Files and apps / Log

**Homepage:** <https://github.com/omerbenamram/evtx>

**Vendor:** omerbenamram

**License:** Apache-2.0

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.evtx`

**Tags:** log-analysis, event-log, windows

A Fast (and safe) parser for the Windows XML Event Log (EVTX) format

## Tips
Fast EVTX to XML or JSON converter. Use -o jsonl with --no-indent for bulk processing with jq, and -t for multi threading on large files.

## Usage
evtx_dump.exe -o jsonl <file.evtx> > out.jsonl
