# gostringungarbler

**Category:** Programming / Go

**Homepage:** <https://github.com/mandiant/gostringungarbler>

**Vendor:** Mandiant

**License:** [Apache-2.0](https://github.com/mandiant/gostringungarbler/blob/main/LICENSE)

**Source:** Git

**Profiles:** Full, Basic

**Tags:** reverse-engineering, golang, deobfuscation

Python tool to resolve all strings in Go binaries obfuscated by garble.

## Tips
Recovers strings from Go binaries obfuscated with garble by emulating the decryption routines. Run it from its own venv with venv.ps1 -gostringungarbler if the wrapper fails.

## Usage
gostringungarbler.py <garbled go binary>
