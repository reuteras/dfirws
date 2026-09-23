# binlex

**Category:** Files and apps

**Homepage:** <https://github.com/c3rb3ru5d3d53c/binlex>

**Vendor:** c3rb3ru5d3d53c

**License:** MIT

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.elf`, `.bin`

**Tags:** malware-analysis, binary-analysis, binary-diffing

binlex is a binary genetic traits lexer for malware analysis.

## Tips
Extracts genetic traits (byte and instruction patterns) from PE and ELF code for similarity analysis. Compare traits between samples to cluster a malware family or write YARA rules.

## Usage
binlex -i <file> -o traits.json
