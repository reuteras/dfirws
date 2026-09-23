# WinDbg

**Category:** Reverse Engineering

**Vendor:** Microsoft

**License:** Proprietary

**Source:** Winget

**Profiles:** Full, Basic

**File Extensions:** `.dmp`, `.exe`, `.dll`, `.sys`

**Tags:** debugging, memory-forensics, windows

WinDbg is a powerful debugger from Microsoft that can be used for analyzing crash dumps, debugging applications, and performing memory forensics. It is commonly used in incident response and malware analysis to investigate system crashes and analyze the behavior of malicious software.

## Tips
Open crash dumps and full memory dumps in the modern WinDbg; load the NetExt extension with .load for managed heap analysis. Symbol downloads need the network sandbox or a local symbol store.

## Usage
windbgx <dump file>
