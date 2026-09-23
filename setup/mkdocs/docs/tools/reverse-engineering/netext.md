# NetExt

**Category:** Reverse Engineering

**Homepage:** <http://blogs.msdn.microsoft.com/rodneyviana>

**Vendor:** rodneyviana


**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.dmp`

**Tags:** debugging, memory-forensics, dotnet, plugins

WinDbg extension for data mining managed heap. It also includes commands to list http request, wcf services, WIF tokens among others

## Tips
WinDbg extension for .NET heap analysis: !wheap, !wdo, !whttp, !wcookie and others. Load the DLL matching the bitness of the dump.

## Usage
In WinDbg: .load C:\Tools\NetExt\x64\NetExt.dll
