# Dumpbin

**Category:** Files and apps

**Homepage:** <https://learn.microsoft.com/en-us/cpp/build/reference/dumpbin-options>

**Vendor:** Delphier


**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.obj`, `.lib`

**Tags:** pe-analysis, reverse-engineering

Microsoft COFF Binary File Dumper: Extract from Visual Studio MSVC Tools

## Tips
Microsoft's PE dumper from the MSVC tools: /dependents and /imports for DLL imports, /exports for exports, /disasm for a quick disassembly and /rawdata for section bytes.

## Usage
dumpbin.exe /headers /imports <file.exe>
