# PE-sieve

**Category:** Files and apps / PE

**Homepage:** <https://hshrzd.wordpress.com/pe-sieve/>

**Vendor:** hasherezade

**License:** BSD-2-Clause

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`

**Tags:** pe-analysis, malware-analysis, dynamic-analysis

Scans a given process. Recognizes and dumps a variety of potentially malicious implants (replaced/injected PEs, shellcodes, hooks, in-memory patches).

## Tips
Scans one process for injected or hollowed modules, hooks and shellcode and dumps them. Add /imp to reconstruct imports, /shellc to include shellcode scanning and /data to scan data sections.

## Usage
pe-sieve.exe /pid <pid>
