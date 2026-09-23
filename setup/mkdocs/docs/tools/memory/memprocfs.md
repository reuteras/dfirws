# MemProcFS

**Category:** Memory

**Homepage:** <https://github.com/ufrisk/MemProcFS>

**Vendor:** ufrisk

**License:** AGPL-3.0

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.dmp`, `.raw`, `.vmem`, `.img`

**Tags:** memory-forensics, filesystem

MemProcFS is an easy and convenient way of viewing physical memory as files in a virtual file system.

## Tips
To fix the problem with python from Cutter you can run this in the terminal before running MemProcFS: $env:PATH = ($env:PATH -split ';' | Where-Object {$_ -notlike '*cutter*'}) -join ';'

## Usage
MemProcFS.exe -device <memory image> -forensic 1
