# sigma-cli

**Category:** Signatures and information

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.yml`, `.yaml`

**Tags:** sigma, detection, log-analysis

sigma convert -t <target> -p <pipeline> <rules dir>

## Tips
Converts Sigma rules using the installed backends (elasticsearch, loki, splunk, sqlite) and pipelines (sysmon, windows). 'sigma list targets' shows what is available and 'sigma check' validates rules.

## Usage
sigma convert -t <target> -p <pipeline> <rules dir>
