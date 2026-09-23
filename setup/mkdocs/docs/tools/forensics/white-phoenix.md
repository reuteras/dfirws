# White-Phoenix

**Category:** Forensics

**Homepage:** <https://github.com/cyberark/White-Phoenix>

**Vendor:** CyberArk

**License:** [Apache License 2.0](https://github.com/cyberark/White-Phoenix/blob/main/LICENSE)

**Source:** Git

**Profiles:** Full (not included in Basic profile)

**Tags:** ransomware, decryption, data-recovery

A tool to recover content from files encrypted with intermittent encryption

## Tips
Works on files hit by intermittent encryption (BlackCat, Play, Qilin, BianLian and similar). Supports PDF, Office, zip based formats and some media; recovery is partial, so triage the most valuable files first.

## Usage
venv.ps1 -whitephoenix ; White-Phoenix.py -f <encrypted file> -o <output dir>
