# decai

**Category:** Reverse Engineering

**Homepage:** <https://github.com/radareorg/r2ai>

**Vendor:** radareorg

**License:** MIT License

**Source:** Git

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.elf`, `.bin`, `.so`

**Tags:** reverse-engineering, ai, decompiler

r2js plugin for radare2 with special focus on AI-assisted decompilation. Installed by copying decai.r2.js to the radare2 plugins directory.

## Tips
decai is copied into the radare2 plugins directory at sandbox start. Use 'decai -e api=<provider>' to select the backend and 'decai -d' to decompile the current function; remote backends need the network sandbox.

## Usage
Inside radare2: decai -h
