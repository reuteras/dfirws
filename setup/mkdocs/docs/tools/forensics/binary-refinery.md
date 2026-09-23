# binary-refinery

**Category:** Forensics

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.bin`

**Tags:** malware-analysis, deobfuscation, data-extraction, scripting

The Binary Refinery is a collection of Python scripts that implement transformations of binary data such as compression and encryption. We will often refer to it simply by refinery, which is also the name of the corresponding package.

## Tips
A pipeline of small units (binref -h lists them): carve, xor, aes, zl, pemeta, vstack, xtzip and hundreds more. Every unit has --help; chain them with pipes like CyberChef on the command line. Excluded from the Basic profile.

## Usage
emit sample.bin | xor 0x41 | dump out.bin
