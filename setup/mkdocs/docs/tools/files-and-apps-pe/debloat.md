# debloat

**Category:** Files and apps / PE

**Homepage:** <https://github.com/Squiblydoo/debloat>

**Vendor:** Squiblydoo

**License:** BSD-3-Clause

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`

**Tags:** malware-analysis, pe-analysis, deobfuscation

A GUI and CLI tool for removing bloat from executables

## Tips
Removes junk padding that malware uses to exceed sandbox and upload size limits so the file can be scanned and shared. Keep the original for hashing.

## Usage
debloat.exe <bloated.exe>
