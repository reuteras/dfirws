# iShutdown

**Category:** Files and apps / Mobile

**Homepage:** <https://github.com/KasperskyLab/iShutdown>

**Vendor:** KasperskyLab

**License:** [Kaspersky](https://github.com/KasperskyLab/iShutdown/blob/master/LICENSE)

**Source:** Git

**Profiles:** Full, Basic

**Tags:** mobile-forensics, forensics

iShutdown scripts: extracts, analyzes, and parses Shutdown.log forensic artifact from iOS Sysdiagnose archives

## Tips
Looks for Pegasus style anomalies in the iOS shutdown.log. Run iShutdown_parse.py to extract the log from a sysdiagnose archive and iShutdown_stats.py for reboot statistics.

## Usage
python C:\git\iShutdown\iShutdown_detect.py <sysdiagnose archive>
