# pycdc

**Category:** Reverse Engineering

**Homepage:** <https://github.com/zrax/pycdc>

**Vendor:** Michael Hansen (zrax)

**License:** [GNU General Public License v3.0](https://github.com/zrax/pycdc/blob/master/LICENSE)

**Source:** Installer

**Profiles:** Full, Basic

**File Extensions:** `.pyc`, `.pyo`

**Tags:** decompiler, reverse-engineering, python

pycdc (Decompyle++) is a C++ decompiler and disassembler for Python bytecode covering Python 1.0 through 3.13. pycdc produces Python source, pycdas a bytecode listing.

## Tips
Use pycdc on the .pyc files produced by pyinstxtractor-ng. When decompilation of newer bytecode fails, pycdas still gives a readable disassembly. Only available when the MSYS2 build sandbox is enabled in the profile.

## Usage
pycdc file.pyc

## Sample Commands
- `pycdc file.pyc`
- `pycdas file.pyc`
