# Canonical Categories and Tags

Reference tables for the `Category`, `Tags`, and `SourceType` fields described in [Agents.md](../Agents.md).

## Canonical Categories

| Category | Description |
|----------|-------------|
| `Development` | Build toolchains and development utilities |
| `Editors` | Text editors, code editors, note-taking (e.g. Obsidian) |
| `Enrichment` | Offline threat-intel enrichment databases |
| `Enrichment\Geolocation` | GeoIP and ASN databases |
| `Enrichment\IDS` | Snort/Suricata rule databases |
| `Enrichment\Network` | Network enrichment data (DNS, blocklists, etc.) |
| `Enrichment\Threat Intelligence` | Threat intelligence feeds and IOC lists |
| `Enrichment\Vulnerability` | CVE and vulnerability databases |
| `Enrichment\YARA` | YARA rule collections |
| `Files and apps` | Generic file analysis tools |
| `Files and apps\Browser` | Browser artifact analysis |
| `Files and apps\Database` | Database file analysis (SQLite, ESE, etc.) |
| `Files and apps\Disk` | Disk image and filesystem tools |
| `Files and apps\Email` | Email file analysis (EML, PST, MSG) |
| `Files and apps\JavaScript` | JavaScript analysis and deobfuscation |
| `Files and apps\Log` | Log file viewers and parsers |
| `Files and apps\Mobile` | Mobile device file analysis |
| `Files and apps\Office` | Office document analysis (Word, Excel, OneNote) |
| `Files and apps\PDF` | PDF analysis |
| `Files and apps\PE` | PE/executable file analysis |
| `Forensics` | General digital forensics tools |
| `Forensics\Zimmerman` | Eric Zimmerman's forensics tool suite |
| `Incident Response` | Incident response and triage tools |
| `Malware Analysis` | Malware analysis and investigation |
| `Malware Analysis\Cobalt Strike` | Cobalt Strike artifact analysis |
| `Malware Analysis\DidierStevens` | Didier Stevens' malware analysis suite |
| `Memory` | Memory forensics and analysis |
| `Network` | Network traffic analysis and protocol tools |
| `OS\Android` | Android platform tools |
| `OS\Linux` | Linux-specific tools |
| `OS\Windows` | Windows-specific tools and artifacts |
| `OS\Windows\Active Directory` | Active Directory analysis |
| `OS\Windows\Registry` | Windows Registry analysis |
| `OS\Windows\Sysinternals` | Sysinternals Suite |
| `Programming` | Language runtimes and generic dev tools |
| `Programming\dotNET` | .NET / C# tools |
| `Programming\Go` | Go language tools |
| `Programming\Java` | Java tools |
| `Programming\PowerShell` | PowerShell tools |
| `Programming\Python` | Python tools |
| `Programming\Ruby` | Ruby tools |
| `Programming\Rust` | Rust tools |
| `Reverse Engineering` | Reverse engineering, disassembly, decompilation |
| `Signatures and information` | Detection rules, signatures, and reference data |
| `Signatures and information\Online tools` | Online lookup and reference tools |
| `Utilities` | General utilities and helper tools |
| `Utilities\Browsers` | Web browser applications |
| `Utilities\Cryptography` | Cryptography and encoding utilities |
| `Utilities\CTF` | CTF-specific tools |
| `Utilities\Media` | Audio/video/image utilities |

## Canonical Tag List

Rules for the `Tags` field are in [Agents.md](../Agents.md#tags-field).

### Analysis Domain

| Tag | Description |
|-----|-------------|
| `acquisition` | Data/disk acquisition and imaging |
| `artifact-extraction` | Extracting forensic artifacts from systems |
| `binary-analysis` | Analyzing binary files |
| `binary-diffing` | Comparing binary files for differences |
| `browser-forensics` | Browser history/cache/artifact analysis |
| `carving` | File carving from raw storage |
| `ctf` | Capture The Flag competition tools |
| `data-extraction` | Extracting data from various formats/sources |
| `data-processing` | Transforming and processing data |
| `data-recovery` | Recovering deleted or corrupted data |
| `debugging` | Debugging executables and processes |
| `decompiler` | Decompiling binaries to source-like code |
| `deobfuscation` | Removing obfuscation from code or scripts |
| `detection` | Detecting malware, threats, or anomalies |
| `detection-rules` | Managing/creating detection rules |
| `disassembler` | Disassembling binary code to assembly |
| `disk-forensics` | Disk and storage media forensics |
| `dynamic-analysis` | Runtime/behavioral analysis |
| `elf-analysis` | ELF binary analysis (Linux executables) |
| `emulation` | Emulating code, CPU, or systems |
| `entropy-analysis` | Entropy analysis of files/sections |
| `file-analysis` | General file analysis and inspection |
| `forensics` | General digital forensics |
| `fuzzy-hashing` | Approximate/fuzzy hash computation |
| `hashing` | Cryptographic hash computation |
| `incident-response` | Incident response activities |
| `ioc` | Indicators of Compromise handling |
| `ioc-scanner` | Scanning for IOCs |
| `log-analysis` | Log file analysis and parsing |
| `malware-analysis` | Malware investigation and analysis |
| `malware-detection` | Automated malware detection/scanning |
| `memory-forensics` | RAM/memory dump analysis |
| `metadata` | File/data metadata extraction |
| `mobile-forensics` | Mobile device forensics |
| `monitoring` | System/event monitoring |
| `network-analysis` | Network traffic and protocol analysis |
| `osint` | Open Source Intelligence gathering |
| `packer-detection` | Detecting packed/obfuscated executables |
| `password-cracking` | Password and hash cracking |
| `pe-analysis` | PE/Portable Executable file analysis |
| `protocol-analysis` | Network protocol analysis and decoding |
| `reverse-engineering` | Reverse engineering binaries and code |
| `static-analysis` | Static code or binary analysis (no execution) |
| `steganography` | Steganography detection and analysis |
| `string-extraction` | Extracting strings from binaries/files |
| `threat-hunting` | Proactive threat hunting |
| `threat-intelligence` | Threat intelligence feeds and data |
| `timeline` | Timeline creation and analysis |
| `triage` | Initial triage and rapid assessment |
| `visualization` | Data visualization and graphing |
| `vulnerability` | Vulnerability research and analysis |

### File Formats / Data Types

| Tag | Description |
|-----|-------------|
| `csv` | CSV file handling |
| `database` | Database files and queries |
| `dns` | DNS records and traffic |
| `email` | Email file formats (EML, PST, MSG) |
| `event-log` | Windows Event Log (EVTX) files |
| `filesystem` | Filesystem structures and analysis |
| `http` | HTTP traffic and requests |
| `javascript` | JavaScript code analysis |
| `json` | JSON format processing |
| `markdown` | Markdown documents |
| `network` | Network-related data and protocols |
| `ntfs` | NTFS filesystem structures |
| `office` | Microsoft Office document formats (Word, Excel, OneNote) |
| `ole` | OLE/Compound Document formats |
| `pcap` | Packet capture files |
| `pdf` | PDF file analysis |
| `powershell` | PowerShell scripts and artifacts |
| `registry` | Windows Registry files and analysis |
| `rtf` | Rich Text Format documents |
| `sigma` | Sigma detection rule format |
| `sqlite` | SQLite database files |
| `vba` | VBA macro analysis |
| `xml` | XML format processing |
| `yaml` | YAML format processing |
| `yara` | YARA rules and scanning |

### Techniques / Features

| Tag | Description |
|-----|-------------|
| `api-tracing` | API call tracing and hooking |
| `audio` | Audio file handling and analysis |
| `automation` | Task automation |
| `blocklist` | Blocklist/denylist management |
| `browser` | Browser applications and web browser tools |
| `compression` | File/data compression and archive handling |
| `conversion` | Format conversion tools |
| `cryptography` | Cryptographic analysis (not just encryption/decryption) |
| `decoding` | Data decoding (Base64, hex, etc.) |
| `decryption` | Data decryption |
| `decompression` | Archive/data decompression |
| `encoding` | Data encoding |
| `encryption` | Data encryption |
| `geolocation` | IP/domain geolocation |
| `graph` | Graph-based data representation |
| `parsing` | Data format parsing |
| `scripting` | Scripting and automation |
| `search` | Search and indexing capabilities |
| `shell` | Shell environments (bash, zsh, PowerShell) |
| `web` | Web application analysis and HTTP tooling |

### Tool Type / Interface

| Tag | Description |
|-----|-------------|
| `cli` | Command-line interface tool |
| `code-editor` | Code editing with syntax support |
| `documentation` | Documentation and reference material |
| `gui` | Graphical user interface |
| `hex-editor` | Hex viewing and editing |
| `mcp` | MCP server for AI integration |
| `plugins` | Plugin or extension (for another tool) |
| `terminal` | Terminal emulator or multiplexer |
| `text-editor` | Plain text editing |
| `tui` | Terminal user interface |
| `viewer` | File/data viewing (read-only) |

### Platform / Runtime

| Tag | Description |
|-----|-------------|
| `ai` | AI/ML-powered analysis |
| `android` | Android platform/artifacts |
| `dotnet` | .NET runtime/ecosystem |
| `golang` | Go language runtime/ecosystem |
| `java` | Java runtime/ecosystem |
| `linux` | Linux-specific tools or analysis |
| `macos` | macOS platform/artifacts |
| `mobile` | Mobile platform (general) |
| `nodejs` | Node.js runtime/ecosystem |
| `python` | Python language/ecosystem |
| `windows` | Windows-specific tools or analysis |

### Security-Specific

| Tag | Description |
|-----|-------------|
| `cobalt-strike` | Cobalt Strike artifact analysis |
| `endpoint-detection` | Endpoint detection capabilities |
| `exploitation` | Exploitation tools (authorized testing) |
| `ids` | Intrusion Detection System rules/integration |
| `mitre-attack` | MITRE ATT&CK framework alignment |
| `phishing` | Phishing analysis tools |
| `ransomware` | Ransomware analysis |
| `security-testing` | Security testing (authorized engagements) |
| `siem` | SIEM platform integration |

### Enrichment / Data Sources

| Tag | Description |
|-----|-------------|
| `enrichment` | Threat intel enrichment databases |
| `maxmind` | MaxMind GeoIP data |
| `mmdb` | MaxMind DB format |

## SourceType Field

Automatically set by `New-CreateToolFiles` from the `-Source` parameter. Maps to display labels in the wiki:

| Source | Wiki Label |
|--------|-----------|
| python | Python |
| node | npm |
| rust | Cargo |
| go | Go |
| release | GitHub Release |
| http | HTTP |
| Git | Git |
| winget | Winget |
| zimmerman | .NET |
| enrichment | Enrichment |
