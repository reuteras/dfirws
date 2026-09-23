# pyinstxtractor-ng

**Category:** Files and apps

**Homepage:** <https://github.com/pyinstxtractor/pyinstxtractor-ng>

**Vendor:** pyinstxtractor

**License:** [GNU General Public License v3.0](https://github.com/pyinstxtractor/pyinstxtractor-ng/blob/master/LICENSE)

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.exe`

**Tags:** reverse-engineering, python, data-extraction

PyInstaller Extractor Next Generation extracts the Python scripts, modules and PYZ archives from PyInstaller generated Windows and Linux executables, including encrypted ones.

## Tips
The extracted .pyc files are written to <file>_extracted. Decompile or disassemble them with pycdc / pycdas (built in the MSYS2 sandbox) - the entry point script is usually named after the original executable.

## Usage
pyinstxtractor-ng sample.exe

## Sample Commands
- `pyinstxtractor-ng sample.exe`
- `pycdc sample.exe_extracted\sample.pyc`
