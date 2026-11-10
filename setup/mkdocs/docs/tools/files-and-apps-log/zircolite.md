# Zircolite

**Category:** Files and apps / Log

**Homepage:** <https://github.com/wagga40/Zircolite>

**Vendor:** wagga40

**License:** [GNU Lesser General Public License v3.0](https://github.com/wagga40/Zircolite/blob/master/LICENSE)

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.evtx`, `.json`, `.xml`, `.jsonl`

**Tags:** log-analysis, sigma, detection, incident-response

Zircolite is a standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs

## Tips
Run Zircolite.exe from Desktop\readwrite. The rulesets in C:\Tools\zircolite\rules are from the release. C:\Tools is read-only, so Zircolite.exe -U writes updated rules to .\rules in the current folder, which needs network access. The binary only includes the sysmon, windows-logsources and windows-audit pySigma pipelines (list them with -pl).

## Usage
Zircolite.exe --events <evtx folder> --ruleset C:\Tools\zircolite\rules\rules_windows_generic.json

## Sample Commands
- `Zircolite.exe --events C:\git\EVTX-ATTACK-SAMPLES --ruleset C:\Tools\zircolite\rules\rules_windows_generic.json -o Desktop\readwrite\detected_events.json`
