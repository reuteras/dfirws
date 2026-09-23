# sigma

**Category:** Signatures and information

**Homepage:** <https://sigmahq.io/>

**Vendor:** SigmaHQ


**Source:** Git

**Profiles:** Full, Basic

**Tags:** sigma, detection-rules, siem

Main Sigma Rule Repository

## Tips
Main Sigma rule repository. Convert rules with sigma-cli using the installed backends (elasticsearch, loki, splunk, sqlite) and pipelines (sysmon, windows), or point hayabusa and chainsaw at the rules directory.

## Usage
sigma convert -t <backend> -p <pipeline> C:\git\sigma\rules
