# upx

**Category:** Utilities

**Homepage:** <https://upx.github.io>

**Vendor:** upx


**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.elf`

**Tags:** packer-detection, pe-analysis, compression

UPX is a free, portable, extendable, high-performance executable packer.

## Tips
Unpacks UPX packed samples. If it fails the sample uses a modified UPX header; fix the header in PE-bear or dump the unpacked image from memory instead.

## Usage
upx -d packed.exe -o unpacked.exe
