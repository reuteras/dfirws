# artemis

**Category:** Forensics

**Homepage:** <https://puffycid.github.io/artemis-api>

**Vendor:** puffyCid

**License:** MIT

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.evtx`, `.reg`

**Tags:** forensics, artifact-extraction, triage

Artemis is a tool for extracting and analyzing Windows artifacts. It can be used for triage and forensic analysis of Windows systems, allowing investigators to quickly gather information about the system and its activity.

## Tips
Collects and parses Windows and macOS artifacts (MFT, registry, event logs, prefetch, shimcache and more) using TOML collection files or JavaScript. Output is JSON or JSONL; use the examples in the repository as templates.

## Usage
artemis.exe -t <collection.toml> or artemis.exe -j <script.js>
