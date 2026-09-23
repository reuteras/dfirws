# hacksguard

**Category:** Files and apps / PE

**Homepage:** <https://github.com/Rhacknarok/hacksguard>

**Vendor:** Rhacknarok

**License:** [MIT License](https://github.com/Rhacknarok/hacksguard/blob/main/LICENSE)

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.dll`, `.sys`, `.elf`, `.so`, `.dylib`

**Tags:** pe-analysis, yara, triage, static-analysis, malware-analysis

hacksguard is a fast, multi-threaded terminal UI for static malware triage. It parses PE, ELF and Mach-O headers and sections, calculates entropy, imphash and Rich header data, extracts strings and Authenticode certificates, runs YARA rules and combines it all into a heuristic risk score.

## Tips
Run it in Windows Terminal for the best TUI rendering. Use --json <file> for headless output that can be fed to other tools or a SIEM. Point --yara at the signature-base or your own rule directory to add signature matches to the score.

## Usage
hacksguard sample.exe

## Sample Commands
- `hacksguard sample.exe`
- `hacksguard --json report.json sample.exe`
