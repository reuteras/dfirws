# YARA

**Category:** Signatures and information

**Homepage:** <https://virustotal.github.io/yara/>

**Vendor:** VirusTotal

**License:** BSD-3-Clause

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.yar`, `.yara`, `.exe`, `.dll`, `.bin`

**Tags:** yara, malware-analysis, detection, detection-rules

YARA is a tool for identifying and classifying malware.

## Tips
Scan files with YARA rules; -s prints matching strings and -m the metadata. Compile large rule sets with yarac for reuse. yara-x is the newer engine with the same rule syntax.

## Usage
yara -r rules.yar <file or dir>
