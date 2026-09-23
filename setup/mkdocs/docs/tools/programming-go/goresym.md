# GoReSym

**Category:** Programming / Go

**Homepage:** <https://github.com/mandiant/GoReSym>

**Vendor:** Mandiant

**License:** MIT License

**Source:** Git

**Profiles:** Full, Basic

**Tags:** reverse-engineering, golang

Go symbol recovery tool

## Tips
Recovers Go function names, types, file paths and build info from stripped binaries. Import the JSON into Ghidra with the bundled script or into IDA to rename functions.

## Usage
GoReSym.exe -t -d -p <go binary> > symbols.json
