# GoReSym

**Category:** Programming / Go

**Homepage:** <https://github.com/mandiant/GoReSym>

**Vendor:** mandiant

**License:** [MIT](https://github.com/mandiant/GoReSym/blob/master/LICENSE)

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.elf`

**Tags:** reverse-engineering, golang

Go symbol recovery tool.

## Tips
Recovers Go function names, types, file paths and build info from stripped binaries. Import the JSON into Ghidra with the bundled script or into IDA.

## Usage
GoReSym.exe -t -d -p <go binary> > symbols.json
