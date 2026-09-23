# white-phoenix

**Category:** IR

**Homepage:** <https://github.com/cyberark/White-Phoenix>

**Vendor:** CyberArk

**License:** [Apache License 2.0](https://github.com/cyberark/White-Phoenix/blob/main/LICENSE)

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.encrypted`, `.locked`, `.enc`

**Tags:** ransomware, encryption, decryption, forensics, data-recovery

White-Phoenix is a tool that recovers content from files encrypted by Ransomware using intermittent encryption. It is designed to help incident responders and forensic analysts to retrieve data from encrypted files when the decryption key is not available.

## Tips
Works on files hit by intermittent encryption (BlackCat, Play, Qilin and similar). Supports PDF, Office and zip based formats; recovery is partial so triage the most valuable files first. Excluded from the Basic profile.

## Usage
venv.ps1 -whitephoenix ; White-Phoenix.py -f <encrypted file> -o <output dir>
