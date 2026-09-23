# pefile

**Category:** Files and apps / PE

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.sys`

**Tags:** pe-analysis, reverse-engineering

import pefile; pe = pefile.PE('file.exe')

## Tips
Parse PE headers, imports, exports and resources in Python. pe.dump_info() prints everything; pe.get_imphash() gives the import hash.

## Usage
import pefile; pe = pefile.PE('file.exe')
