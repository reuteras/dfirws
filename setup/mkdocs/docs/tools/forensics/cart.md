# cart

**Category:** Forensics

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.cart`

**Tags:** malware-analysis

Compressed and RC4 Transport (CaRT) Neutering format. This is a file format that is used to neuter malware files for distribution in the malware analyst community.

## Tips
Neuters malware for safe transport by RC4 encrypting and compressing it with metadata. Decode with -d before analysis; -s shows the metadata header.

## Usage
cart <file> (creates file.cart) or cart -d file.cart
