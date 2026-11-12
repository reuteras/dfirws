# pysigma-pipeline-sysmon

**Category:** Signatures and information

**Homepage:** <https://github.com/SigmaHQ/pySigma-pipeline-sysmon/>

**Vendor:** SigmaHQ

**License:** [LGPL-2.1-only](https://github.com/SigmaHQ/pySigma-pipeline-sysmon/blob/main/LICENSE)

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.yml`, `.yaml`

**Tags:** sigma, detection, event-log, windows

sigma convert -t <target> -p sysmon <rules dir>

## Tips
Pipeline that maps generic Sigma log sources to Sysmon event IDs; use it together with the windows pipeline.

## Usage
sigma convert -t <target> -p sysmon <rules dir>
