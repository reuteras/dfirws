# HollowsHunter

**Category:** Files and apps / PE

**Homepage:** <https://github.com/hasherezade/hollows_hunter/wiki>

**Vendor:** hasherezade

**License:** BSD-2-Clause

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.dmp`

**Tags:** malware-analysis, pe-analysis, dynamic-analysis

Scans running processes. Recognizes and dumps a variety of in-memory implants

## Tips
Scans all running processes with PE-sieve to find hollowed, injected or patched code and dumps it. Use it in the sandbox after detonating a sample; /dir sets the dump folder and /imp reconstructs imports.

## Usage
hollows_hunter.exe /pid <pid> (or /loop to scan continuously)
