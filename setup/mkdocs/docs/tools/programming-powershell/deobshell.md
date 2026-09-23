# deobshell

**Category:** Programming / PowerShell

**Homepage:** <https://github.com/thewhiteninja/deobshell>

**Vendor:** thewhiteninja

**License:** [MIT License](https://github.com/thewhiteninja/deobshell/blob/master/LICENSE)

**Source:** Git

**Profiles:** Full, Basic

**Tags:** powershell, deobfuscation, malware-analysis

Powershell script deobfuscation using AST in Python.

## Tips
Rebuilds obfuscated PowerShell from its AST. Use it after PowerDecode when a script relies on string concatenation and format operators; output goes to stdout so redirect it to a file.

## Usage
DeobShell is PoC to deobfuscate Powershell using Abstract Syntax Tree (AST) manipulation in Python. The AST is extracted using a Powershell script by calling System.Management.Automation.Language.Parser and writing relevant nodes to an XML file.
