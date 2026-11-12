# sigma-cli

**Category:** Signatures and information

**Homepage:** <https://github.com/SigmaHQ/sigma-cli>

**Vendor:** SigmaHQ

**License:** [LGPL-2.1-or-later](https://github.com/SigmaHQ/sigma-cli/blob/main/LICENSE.txt)

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.yml`, `.yaml`

**Tags:** sigma, detection, log-analysis

sigma convert -t <target> -p <pipeline> <rules dir>

## Tips
Converts Sigma rules using the installed backends (elasticsearch, loki, splunk, sqlite) and pipelines (sysmon, windows). 'sigma list targets' shows what is available and 'sigma check' validates rules.

## Usage
sigma convert -t <target> -p <pipeline> <rules dir>
