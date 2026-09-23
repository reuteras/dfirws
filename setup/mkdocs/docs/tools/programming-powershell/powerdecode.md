# PowerDecode

**Category:** Programming / PowerShell

**Homepage:** <https://github.com/Malandrone/PowerDecode>

**Vendor:** Malandrone

**License:** [GPL-3.0 License](https://github.com/Malandrone/PowerDecode/blob/v2.7.2/LICENSE.txt)

**Source:** Git

**Profiles:** Full, Basic

**Tags:** powershell, deobfuscation, malware-analysis

PowerDecode is a PowerShell-based tool that allows to deobfuscate PowerShell scripts obfuscated across multiple layers. The tool performs code dynamic analysis, extracting malware hosting URLs and checking http response.It can also detect if the malware attempts to inject shellcode into memory.

## Tips
Deobfuscates layered PowerShell and extracts URLs and shellcode. Run it in the offline sandbox so URL checks fail safely, or in the network sandbox if you want live HTTP responses; deobshell is the AST based alternative.

## Usage
.\GUI.ps1 (run from C:\git\PowerDecode)
