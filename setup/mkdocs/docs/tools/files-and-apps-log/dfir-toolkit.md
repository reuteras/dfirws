# dfir-toolkit

**Category:** Files and apps / Log

**Source:** Cargo

**Profiles:** Full, Basic

**File Extensions:** `.evtx`, `.reg`, `.dat`, `.lnk`, `.pf`, `.mft`, `.zip`

**Tags:** forensics, timeline, log-analysis, event-log, registry, filesystem

The dfir-toolkit is a collection of command-line tools for digital forensics and incident response (DFIR) tasks. It includes various utilities for analyzing log files, registry hives, MFT files, and other artifacts commonly encountered in DFIR investigations.

## Tips
A family of small tools: mft2bodyfile, usnjrnl_dump, evtx2bodyfile, evtxanalyze, evtxscan, regdump, cleanhive, pol_export, ipgrep, ts2date, zip2bodyfile. Chain the bodyfile outputs into mactime2 for a unified timeline.

## Usage
mft2bodyfile <MFT file> > mft.bodyfile (see each tool's --help)
