# Python Tool Invocation Reference

The DFIRWS sandbox has multiple Python environments. Understanding the structure avoids path errors and ensures the correct interpreter and dependencies are used.

## Python environments overview

| Environment | Path | Purpose |
| ----------- | ---- | ------- |
| System Python | `C:\Tools\python\python.exe` | Base interpreter (on PATH) |
| Default venv | `C:\venv\default\` | General-purpose venv with most forensic packages |
| UV tool bin | `C:\venv\bin\` | Standalone tool executables installed by uv |
| UV managed venvs | `C:\venv\uv\<tool>\` | Isolated per-tool venvs managed by uv |
| Specialized venvs | `C:\venv\<name>\` | Purpose-built venvs for specific tools |

## Invocation patterns

### Pattern 1: Direct executables from `C:\venv\bin\`

Most Python tools are available as standalone `.exe` files. Use these directly:

```
C:\venv\bin\olevba.exe Desktop\readonly\document.docx
C:\venv\bin\mraptor.exe Desktop\readonly\document.docx
C:\venv\bin\oleid.exe Desktop\readonly\document.docx
C:\venv\bin\magika.exe Desktop\readonly\suspect.exe
C:\venv\bin\hindsight.exe -i Desktop\readonly\chrome_profile -o Desktop\readwrite\hindsight_output
C:\venv\bin\chepy.exe "base64string"
C:\venv\bin\time-decode.exe -t 132853852800000000 --type filetime
C:\venv\bin\visidata.exe Desktop\readwrite\results.csv
C:\venv\bin\lnkparse.exe Desktop\readonly\shortcut.lnk
C:\venv\bin\extract_msg.exe Desktop\readonly\email.msg
```

### Pattern 2: Default venv entry points at `C:\venv\default\Scripts\`

Some tools install their entry points in the default venv:

```
C:\venv\default\Scripts\vol.exe -f Desktop\readonly\memory.raw windows.pslist
C:\venv\default\Scripts\acquire.exe --help
C:\venv\default\Scripts\rdump.exe Desktop\readonly\hive
C:\venv\default\Scripts\sigma.exe convert -t <target> -f Desktop\readonly\rule.yml
```

### Pattern 3: Specialized venvs at `C:\venv\<name>\`

Some tools have their own isolated virtual environments:

```
C:\venv\zircolite\Scripts\python.exe C:\git\zircolite\zircolite.py -e Desktop\readonly\evtx
C:\venv\dfir-unfurl\Scripts\unfurl.exe "https://example.com/path?param=value"
C:\venv\white-phoenix\Scripts\python.exe C:\git\White-Phoenix\wp.py
C:\venv\evt2sigma\Scripts\python.exe C:\git\evt2sigma\evt2sigma.py
```

### Pattern 4: Didier Stevens Python scripts

These scripts are in `C:\Tools\DidierStevens\` (also copied to `C:\Tools\bin\`) and run with the system Python:

```
python C:\Tools\DidierStevens\oledump.py Desktop\readonly\document.doc
python C:\Tools\DidierStevens\pdfid.py Desktop\readonly\suspect.pdf
python C:\Tools\DidierStevens\pdf-parser.py Desktop\readonly\suspect.pdf
python C:\Tools\DidierStevens\emldump.py Desktop\readonly\email.eml
python C:\Tools\DidierStevens\base64dump.py Desktop\readonly\encoded.txt
python C:\Tools\DidierStevens\1768.py Desktop\readonly\beacon.bin
python C:\Tools\DidierStevens\xorsearch.py Desktop\readonly\suspect.bin
python C:\Tools\DidierStevens\zipdump.py Desktop\readonly\archive.zip
python C:\Tools\DidierStevens\pecheck.py Desktop\readonly\suspect.exe
python C:\Tools\DidierStevens\strings.py Desktop\readonly\suspect.exe
python C:\Tools\DidierStevens\byte-stats.py Desktop\readonly\suspect.exe
```

### Pattern 5: UV-managed per-tool venvs at `C:\venv\uv\<tool>\`

Some tools are managed in isolated uv environments:

```
C:\venv\uv\regipy\Scripts\python.exe -m regipy Desktop\readonly\NTUSER.DAT
C:\venv\uv\jupyterlab\Scripts\jupyter.exe lab
```

## Common Python forensic libraries (available in default venv)

These libraries can be imported in Python scripts for custom analysis:

| Library | Purpose |
| ------- | ------- |
| `pefile` | PE file parsing |
| `lief` | Binary format parsing (PE, ELF, Mach-O) |
| `yara-python` | YARA rule matching from Python |
| `dissect` | Forensic artifact parsing framework |
| `regipy` | Registry hive parsing |
| `volatility3` | Memory forensics framework |
| `scapy` | Network packet manipulation |
| `dpkt` | Network packet parsing |
| `pandas` | Data analysis and CSV/JSON processing |
| `openpyxl` | Excel file reading/writing |
| `cryptography` | Cryptographic operations |
| `impacket` | Network protocol implementations |
| `msticpy` | Microsoft Threat Intelligence Python library |
| `oletools` | OLE/Office file analysis |
| `geoip2` | MaxMind GeoIP database reader |

**Example custom script:**

```python
# Save as Desktop\readwrite\analyze.py and run with:
# C:\venv\default\Scripts\python.exe Desktop\readwrite\analyze.py

import pefile
import json

pe = pefile.PE(r"Desktop\readonly\suspect.exe")
info = {
    "imphash": pe.get_imphash(),
    "sections": [{"name": s.Name.decode().strip('\x00'), "entropy": s.get_entropy()} for s in pe.sections],
    "imports": {e.dll.decode(): [i.name.decode() if i.name else str(i.ordinal) for i in e.imports] for e in pe.DIRECTORY_ENTRY_IMPORT}
}
with open(r"Desktop\readwrite\pe_analysis.json", "w") as f:
    json.dump(info, f, indent=2)
```

## Troubleshooting

| Issue | Solution |
| ----- | -------- |
| `ModuleNotFoundError` | The library may be in a different venv. Try `C:\venv\default\Scripts\python.exe` instead of system `python` |
| Tool not found in `C:\venv\bin\` | Check `C:\venv\default\Scripts\` or specialized venvs |
| Permission error writing files | Make sure output goes to `Desktop\readwrite\`, not `Desktop\readonly\` |
| Python version mismatch | DFIRWS uses Python 3.11 by default |
