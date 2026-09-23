# lief

**Category:** Files and apps / PE

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.elf`, `.mach-o`

**Tags:** pe-analysis, elf-analysis, binary-analysis

import lief; b = lief.parse('file.exe')

## Tips
Parse and modify PE, ELF, Mach-O and DEX files. Good for scripted extraction of imports, resources, signatures and for patching headers.

## Usage
import lief; b = lief.parse('file.exe')
