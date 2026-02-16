# DFIRWS Paths and Tool Selection Reference

Use this file when command/path specificity matters. All paths are Windows-native.

## Core paths
- `C:\Tools\` - pre-extracted forensic and reverse engineering binaries.
- `C:\Tools\bin\` - wrapper scripts and small utilities (on PATH).
- `C:\Tools\Zimmerman\net6\` - Eric Zimmerman .NET forensic tools.
- `C:\Tools\DidierStevens\` - Didier Stevens Python analysis scripts (also copied to `C:\Tools\bin\`).
- `C:\Tools\sysinternals\` - Microsoft Sysinternals Suite (80+ tools).
- `C:\venv\` - Python virtual environments and script launchers.
- `C:\venv\bin\` - Python tool executables installed via uv.
- `C:\venv\default\Scripts\` - default venv entry-point scripts.
- `C:\git\` - cloned repositories used by some toolchains.
- `C:\enrichment\` - threat intelligence and enrichment data (read-only).
- `C:\downloads\` - installer cache (read-only).
- `Desktop\readonly\` - read-only evidence/input directory.
- `Desktop\readwrite\` - writable analyst workspace (default for case output).

## Tool selection by artifact type

### Event logs (`.evtx`)

| Tool | Path | Use case |
|------|------|----------|
| Hayabusa | `C:\Tools\hayabusa\hayabusa.exe` | SIGMA-based threat hunting, timeline generation |
| Chainsaw | `C:\Tools\chainsaw\chainsaw.exe` | Fast SIGMA/keyword search across event logs |
| EvtxECmd | `C:\Tools\Zimmerman\net6\EvtxeCmd\EvtxECmd.exe` | Detailed EVTX parsing to CSV/JSON |
| evtx_dump | `C:\Tools\bin\evtx_dump.exe` | Raw EVTX to XML/JSON conversion |
| FullEventLogView | `C:\Tools\FullEventLogView\FullEventLogView.exe` | GUI event log viewer |
| Zircolite | `C:\venv\zircolite\Scripts\python.exe C:\git\zircolite\zircolite.py` | Standalone SIGMA detection engine |
| takajo | `C:\Tools\takajo\takajo.exe` | Post-process Hayabusa JSONL output |
| LUMEN | `C:\Tools\LUMEN\` | Event log visualization |
| LogBoost | `C:\Tools\LogBoost\LogBoost.exe` | Log enrichment and analysis |
| YAMAGoya | `C:\Tools\YAMAGoya\YAMAGoya.exe` | YARA/SIGMA rule analyzer |

**Quick triage commands:**
```
C:\Tools\hayabusa\hayabusa.exe csv-timeline -d Desktop\readonly\evtx -o Desktop\readwrite\hayabusa_timeline.csv
C:\Tools\chainsaw\chainsaw.exe hunt Desktop\readonly\evtx -s C:\Tools\chainsaw\sigma\ --mapping C:\Tools\chainsaw\mappings\sigma-event-logs-all.yml -o Desktop\readwrite\chainsaw_results.csv --csv
C:\Tools\Zimmerman\net6\EvtxeCmd\EvtxECmd.exe -d Desktop\readonly\evtx --csv Desktop\readwrite\evtxecmd_output
```

### Registry hives (`NTUSER.DAT`, `SYSTEM`, `SOFTWARE`, `SAM`, `SECURITY`, etc.)

| Tool | Path | Use case |
|------|------|----------|
| RegistryExplorer | `C:\Program Files\RegistryExplorer\RegistryExplorer.exe` | GUI registry hive viewer |
| RegRipper 4.0 | `C:\git\RegRipper4.0\rip.exe` | Scripted broad registry extraction |
| regipy (CLI) | `C:\venv\bin\registry-dump.exe` | Python-based registry parsing |
| regipy (MCP) | Via MCP server if enabled | Interactive registry analysis |
| ShellBagsExplorer | `C:\Program Files\ShellBagsExplorer\ShellBagsExplorer.exe` | Shell bag artifact viewer |
| SBECmd | `C:\Tools\Zimmerman\net6\SBECmd.exe` | CLI shell bags extraction |
| AmcacheParser | `C:\Tools\Zimmerman\net6\AmcacheParser.exe` | Amcache registry parsing |
| AppCompatCacheParser | `C:\Tools\Zimmerman\net6\AppCompatCacheParser.exe` | Shimcache analysis |

**Quick triage commands:**
```
C:\git\RegRipper4.0\rip.exe -r Desktop\readonly\SYSTEM -a > Desktop\readwrite\system_regripper.txt
C:\Tools\Zimmerman\net6\AmcacheParser.exe -f Desktop\readonly\Amcache.hve --csv Desktop\readwrite\amcache_output
C:\Tools\Zimmerman\net6\AppCompatCacheParser.exe -f Desktop\readonly\SYSTEM --csv Desktop\readwrite\shimcache_output
```

### Executables / DLLs / PE files

| Tool | Path | Use case |
|------|------|----------|
| capa | `C:\Tools\capa\capa.exe` | Capability detection (maps to MITRE ATT&CK) |
| Detect It Easy | `C:\Tools\die\die.exe` | Packer/compiler/linker detection |
| pestudio | `C:\Tools\pestudio\pestudio.exe` | PE static analysis GUI |
| PE-bear | `C:\Tools\PE-bear\PE-bear.exe` | PE structure viewer |
| PE-sieve | `C:\Tools\pe-sieve\pe-sieve64.exe` | Process memory scanning |
| HollowsHunter | `C:\Tools\HollowsHunter\hollows_hunter64.exe` | Process injection detection |
| FLOSS | `C:\Tools\floss\floss.exe` | Obfuscated string extraction |
| DensityScout | `C:\Tools\densityscout\densityscout.exe` | Entropy/packing detection |
| 4n4lDetector | `C:\Tools\4n4lDetector\4n4lDetector.exe` | PE analysis GUI |
| TrID | `C:\Tools\trid\trid.exe` | File type identification |
| Ghidra | Via `ghidraRun.bat` in Ghidra install dir | Deep static reverse engineering |
| radare2 | `C:\Tools\radare2\bin\radare2.exe` | CLI reverse engineering/disassembly |
| Cutter | `C:\Tools\cutter\cutter.exe` | GUI reverse engineering (radare2 front-end) |
| x64dbg | Via installed shortcut | Dynamic debugging |
| ImHex | `C:\Tools\imhex\imhex.exe` | Hex editor with pattern language |
| Malcat Lite | `C:\Tools\malcat\bin\malcat.exe` | Malware analysis viewer |
| strings (Sysinternals) | `C:\Tools\sysinternals\strings.exe` | String extraction |
| sigcheck (Sysinternals) | `C:\Tools\sysinternals\sigcheck.exe` | Signature and certificate checking |

**Quick triage commands:**
```
C:\Tools\capa\capa.exe Desktop\readonly\suspect.exe -j > Desktop\readwrite\capa_results.json
C:\Tools\floss\floss.exe Desktop\readonly\suspect.exe -j > Desktop\readwrite\floss_strings.json
C:\Tools\die\diec.exe Desktop\readonly\suspect.exe
C:\Tools\sysinternals\sigcheck.exe -accepteula -a -h Desktop\readonly\suspect.exe
C:\Tools\densityscout\densityscout.exe -pe Desktop\readonly\suspect.exe
```

### Memory images

| Tool | Path | Use case |
|------|------|----------|
| VolatilityWorkbench 3 | `C:\Tools\VolatilityWorkbench\VolatilityWorkbench.exe` | GUI memory forensics (Vol3) |
| VolatilityWorkbench 2 | `C:\Tools\VolatilityWorkbench2\VolatilityWorkbench.exe` | GUI memory forensics (Vol2) |
| volatility3 (Python) | `C:\venv\default\Scripts\vol.exe` or via `python -m volatility3` | CLI memory forensics |
| MemProcFS | `C:\Tools\MemProcFS\` | Memory as filesystem |

**Quick triage commands:**
```
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.info
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.pslist > Desktop\readwrite\vol3_pslist.txt
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.netscan > Desktop\readwrite\vol3_netscan.txt
```

### Network captures (`.pcap`, `.pcapng`)

| Tool | Path | Use case |
|------|------|----------|
| Wireshark | Via installed shortcut | GUI packet analysis |
| tshark | In Wireshark install dir | CLI packet analysis |
| Zui | `C:\Tools\Zui\Zui.exe` | Network traffic analysis GUI |
| scapy | `C:\venv\bin\scapy.exe` | Python packet manipulation |
| FakeNet-NG | `C:\Tools\FakeNet-NG\` | Network simulation for malware |

### Browser artifacts / SQLite

| Tool | Path | Use case |
|------|------|----------|
| BrowsingHistoryView | `C:\Tools\nirsoft\BrowsingHistoryView.exe` | Browser history extraction |
| ChromeCacheView | `C:\Tools\nirsoft\ChromeCacheView.exe` | Chrome cache viewer |
| MZCacheView | `C:\Tools\nirsoft\MZCacheView.exe` | Firefox cache viewer |
| IECacheView | `C:\Tools\nirsoft\IECacheView.exe` | IE/Edge cache viewer |
| Hindsight | `C:\venv\bin\hindsight.exe` | Chrome/Edge forensic analysis |
| DB Browser for SQLite | `C:\Tools\sqlitebrowser\DB Browser for SQLite.exe` | GUI SQLite viewer |
| fqlite | `C:\Tools\fqlite\` | SQLite forensic queries |
| litecli | `C:\venv\bin\litecli.exe` | Interactive SQLite CLI |
| dsq | `C:\Tools\bin\dsq.exe` | SQL queries against JSON/CSV/etc. |
| dfir-unfurl | `C:\venv\dfir-unfurl\Scripts\unfurl.exe` | URL parsing and analysis |

### Office documents (`.docx`, `.xlsx`, `.pptx`, OLE files)

| Tool | Path | Use case |
|------|------|----------|
| olevba | `C:\venv\bin\olevba.exe` | VBA macro extraction and analysis |
| oleid | `C:\venv\bin\oleid.exe` | OLE file identifier |
| oledump.py | `C:\Tools\DidierStevens\oledump.py` | OLE stream extraction |
| mraptor | `C:\venv\bin\mraptor.exe` | Detect auto-exec macros |
| msoffcrypto-tool | `C:\venv\bin\msoffcrypto-tool.exe` | Decrypt password-protected Office docs |
| pcode2code | `C:\venv\bin\pcode2code.exe` | VBA P-code decompilation |
| XLMMacroDeobfuscator | `C:\venv\bin\xlmdeobfuscator.exe` | Excel 4.0 macro deobfuscation |
| MiTeC SSV | `C:\Tools\SSView\SSView.exe` | Structured storage viewer |
| MetadataPlus | `C:\Tools\MetadataPlus\MetadataPlus.exe` | Office metadata extraction |
| LibreOffice | Via installed shortcut | Open/inspect Office files |

**Quick triage commands:**
```
C:\venv\bin\oleid.exe Desktop\readonly\document.docx
C:\venv\bin\olevba.exe Desktop\readonly\document.docx
C:\venv\bin\mraptor.exe Desktop\readonly\document.docx
python C:\Tools\DidierStevens\oledump.py Desktop\readonly\document.doc
```

### PDF files

| Tool | Path | Use case |
|------|------|----------|
| pdfid.py | `C:\Tools\DidierStevens\pdfid.py` | PDF structure identifier (detect JavaScript, OpenAction) |
| pdf-parser.py | `C:\Tools\DidierStevens\pdf-parser.py` | PDF object/stream extraction |
| peepdf | `C:\venv\bin\peepdf.exe` | Interactive PDF analysis |
| qpdf | `C:\Tools\bin\qpdf.exe` | PDF transformation/repair |
| PDFStreamDumper | `C:\Tools\PDFStreamDumper\PDFStreamDumper.exe` | GUI PDF stream extraction |
| Foxit PDF Reader | Via installed shortcut | Safe PDF viewing |

**Quick triage commands:**
```
python C:\Tools\DidierStevens\pdfid.py Desktop\readonly\suspect.pdf
python C:\Tools\DidierStevens\pdf-parser.py --stats Desktop\readonly\suspect.pdf
```

### Email (`.eml`, `.msg`, `.pst`, `.mbox`)

| Tool | Path | Use case |
|------|------|----------|
| emldump.py | `C:\Tools\DidierStevens\emldump.py` | EML file analysis |
| extract-msg | `C:\venv\bin\extract_msg.exe` | MSG file extraction |
| Mail Viewer (MiTeC) | `C:\Tools\MailView\MailView.exe` | GUI email viewer |
| PST Walker | `C:\Tools\pstwalker\PSTWalker.exe` | PST file browser |
| mboxviewer | `C:\Tools\mboxviewer\mboxview64.exe` | MBOX file viewer |
| msgviewer | `C:\Tools\bin\msgviewer.bat` | MSG file viewer (Java) |

### Archives and unknown containers

| Tool | Path | Use case |
|------|------|----------|
| 7-Zip | `C:\Program Files\7-Zip\7z.exe` | Universal archive extraction |
| TrID | `C:\Tools\trid\trid.exe` | File type identification |
| file-magic.py | `C:\Tools\DidierStevens\file-magic.py` | File identification |
| magika | `C:\venv\bin\magika.exe` | Google ML-based file type detection |
| find-file-in-file.py | `C:\Tools\DidierStevens\find-file-in-file.py` | Nested file/embedded payload detection |
| zipdump.py | `C:\Tools\DidierStevens\zipdump.py` | ZIP structure analysis |

### Disk images and filesystem artifacts

| Tool | Path | Use case |
|------|------|----------|
| Sleuthkit | `C:\Tools\sleuthkit\bin\` (fls, icat, mmls, etc.) | Filesystem forensics CLI |
| OSFMount | Via installed shortcut | Mount disk images as drive letters |
| MFTECmd | `C:\Tools\Zimmerman\net6\MFTECmd.exe` | MFT parsing |
| DFIR-NTFS | `C:\venv\bin\ntfs_parser.py` | Python NTFS parser |
| INDXRipper | `C:\venv\bin\INDXRipper.exe` | NTFS INDX attribute parser |
| MFTBrowser | `C:\Tools\MFTBrowser\MFTBrowser.exe` | GUI MFT viewer |

**Quick triage commands:**
```
C:\Tools\Zimmerman\net6\MFTECmd.exe -f Desktop\readonly\$MFT --csv Desktop\readwrite\mft_output
C:\Tools\sleuthkit\bin\mmls.exe Desktop\readonly\disk.dd
C:\Tools\sleuthkit\bin\fls.exe -r -o <offset> Desktop\readonly\disk.dd > Desktop\readwrite\fls_listing.txt
```

### Windows artifact parsing (Jump Lists, LNK, Prefetch, Recycle Bin, SRUM, etc.)

| Tool | Path | Use case |
|------|------|----------|
| JLECmd | `C:\Tools\Zimmerman\net6\JLECmd.exe` | Jump list parsing |
| LECmd | `C:\Tools\Zimmerman\net6\LECmd.exe` | LNK file parsing |
| PECmd | `C:\Tools\Zimmerman\net6\PECmd.exe` | Prefetch file parsing |
| RBCmd | `C:\Tools\Zimmerman\net6\RBCmd.exe` | Recycle Bin parsing |
| SrumECmd | `C:\Tools\Zimmerman\net6\SrumECmd.exe` | SRUM database parsing |
| WxTCmd | `C:\Tools\Zimmerman\net6\WxTCmd.exe` | Windows 10 Timeline parsing |
| recbin | `C:\Tools\bin\recbin.exe` | Recycle Bin parser (alternative) |
| lnkparse | `C:\venv\bin\lnkparse.exe` | Python LNK parser |
| TimelineExplorer | `C:\Program Files\TimelineExplorer\TimelineExplorer.exe` | GUI timeline/CSV viewer |
| Jumplist Browser | `C:\Tools\JumplistBrowser\JumplistBrowser.exe` | GUI jump list viewer |
| Prefetch Browser | `C:\Tools\PrefetchBrowser\PrefetchBrowser.exe` | GUI prefetch viewer |
| LastActivityView | `C:\Tools\nirsoft\LastActivityView.exe` | Recent activity summary |

**Quick triage commands:**
```
C:\Tools\Zimmerman\net6\PECmd.exe -d Desktop\readonly\Prefetch --csv Desktop\readwrite\prefetch_output
C:\Tools\Zimmerman\net6\LECmd.exe -d Desktop\readonly\lnk_files --csv Desktop\readwrite\lnk_output
C:\Tools\Zimmerman\net6\JLECmd.exe -d Desktop\readonly\jumplists --csv Desktop\readwrite\jumplist_output
C:\Tools\Zimmerman\net6\RBCmd.exe -d Desktop\readonly\$Recycle.Bin --csv Desktop\readwrite\recyclebin_output
```

### Mobile forensics

| Tool | Path | Use case |
|------|------|----------|
| aLEAPP | `C:\Tools\aLEAPP\aleappGUI.exe` | Android artifact parsing |
| iLEAPP | `C:\Tools\iLEAPP\ileappGUI.exe` | iOS artifact parsing |
| apktool | `C:\Tools\bin\apktool.bat` | APK decompiling |
| jadx | `C:\Tools\jadx\bin\jadx-gui.bat` | Android decompiler GUI |

### Malware detection and IOC scanning

| Tool | Path | Use case |
|------|------|----------|
| YARA | `C:\Tools\yara\yara64.exe` | Signature-based malware detection |
| yara-x | `C:\Tools\yara-x\yr.exe` | Next-gen YARA engine |
| Loki | `C:\Tools\loki\loki.exe` | IOC scanner (hashes, filenames, YARA) |
| ClamAV | `C:\Program Files\ClamAV\clamscan.exe` | Antivirus scanning |
| CobaltStrikeScan | `C:\Tools\CobaltStrikeScan\CobaltStrikeScan.exe` | Cobalt Strike beacon detection |
| BeaconHunter | `C:\Tools\BeaconHunter\BeaconHunter.exe` | Cobalt Strike detection GUI |
| 1768.py | `C:\Tools\DidierStevens\1768.py` | Cobalt Strike config extraction |

**Quick triage commands:**
```
C:\Tools\yara\yara64.exe -r C:\enrichment\yara\yara-forge-rules-core.yar Desktop\readonly\suspect.exe
C:\Tools\capa\capa.exe Desktop\readonly\suspect.exe
"C:\Program Files\ClamAV\clamscan.exe" Desktop\readonly\suspect.exe
```

### Encoding, decoding, and data transformation

| Tool | Path | Use case |
|------|------|----------|
| CyberChef | `C:\Tools\CyberChef\CyberChef.html` (open in browser) | Swiss army knife for data transformations |
| base64dump.py | `C:\Tools\DidierStevens\base64dump.py` | Base64 stream extraction |
| xorsearch.py | `C:\Tools\DidierStevens\xorsearch.py` | XOR-encoded content search |
| xor-kpa.py | `C:\Tools\DidierStevens\xor-kpa.py` | XOR known-plaintext attack |
| decode-vbe.py | `C:\Tools\DidierStevens\decode-vbe.py` | VBScript Encoded decode |
| chepy | `C:\venv\bin\chepy.exe` | Python CyberChef alternative (CLI) |
| DCode | `C:\Tools\DCode\DCode.exe` | Timestamp decoder |
| time-decode | `C:\venv\bin\time-decode.exe` | Timestamp format decoder |

### Timestamp and timeline tools

| Tool | Path | Use case |
|------|------|----------|
| TimelineExplorer | `C:\Program Files\TimelineExplorer\TimelineExplorer.exe` | View and filter CSV timelines |
| forensic-timeliner | `C:\Tools\forensic-timeliner\` | Automated timeline generation |
| DCode | `C:\Tools\DCode\DCode.exe` | Individual timestamp decode |
| time-decode | `C:\venv\bin\time-decode.exe` | CLI timestamp decoder |

### Sysinternals (selected tools at `C:\Tools\sysinternals\`)

| Tool | Binary | Use case |
|------|--------|----------|
| strings | `strings.exe` | Extract printable strings |
| sigcheck | `sigcheck.exe` | Digital signature verification |
| autorunsc | `autorunsc.exe` | Persistence location enumeration |
| handle | `handle.exe` | List open handles |
| listdlls | `listdlls.exe` | List loaded DLLs |
| procmon | `Procmon.exe` | Process activity monitor |
| procexp | `procexp.exe` | Advanced task manager |
| tcpview | `tcpview.exe` | TCP/UDP connection viewer |

### Active Directory and LDAP

| Tool | Path | Use case |
|------|------|----------|
| godap | `C:\Tools\bin\godap.exe` | LDAP analysis |
| AdaLanche | `C:\Tools\AdaLanche\` | AD analysis |

### Data querying and visualization

| Tool | Path | Use case |
|------|------|----------|
| fx | `C:\Tools\bin\fx.exe` | Interactive JSON viewer |
| jq | `C:\Tools\bin\jq.exe` | JSON processor |
| fq | `C:\Tools\bin\fq.exe` | Binary format querying (like jq for binary) |
| gron | `C:\Tools\bin\gron.exe` | Make JSON greppable |
| dsq | `C:\Tools\bin\dsq.exe` | SQL queries on JSON/CSV files |
| visidata | `C:\venv\bin\visidata.exe` | Terminal data viewer for CSV/JSON/SQLite |
| Graphviz | `C:\Program Files\Graphviz\bin\dot.exe` | Graph rendering |
| Neo4j | `C:\Tools\neo4j\` | Graph database for relationship analysis |

## Reproducibility pattern
For each task, return:
1. Input path assumptions.
2. Command block(s) with absolute paths.
3. Output location (under `Desktop\readwrite\`).
4. Validation command for sanity-checking generated output.

## Safety notes
- Prefer command options that avoid modifying source artifacts.
- Treat `Desktop\readonly` as source evidence and avoid writing back to it.
- Write derived artifacts (CSV/JSON/reports) under `Desktop\readwrite\cases\<case-id>\`.
- If a tool requires write access to source paths, copy source to a working folder first and preserve original hashes.
- Use `certutil -hashfile <file> SHA256` or `C:\Tools\DidierStevens\hash.py` to verify file integrity before and after operations.
