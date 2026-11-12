# yara-python

**Category:** Signatures and information

**Homepage:** <https://github.com/VirusTotal/yara-python>

**Vendor:** VirusTotal

**License:** [Apache-2.0](https://github.com/VirusTotal/yara-python/blob/master/LICENSE)

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.yar`, `.yara`

**Tags:** yara, malware-analysis, detection

import yara; rules = yara.compile('rules.yar')

## Tips
YARA from Python for scripted scanning. The yara and yr command line tools are usually more convenient for one off scans.

## Usage
import yara; rules = yara.compile('rules.yar')
