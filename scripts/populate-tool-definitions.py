#!/usr/bin/env python3
"""
Populate $TOOL_DEFINITIONS skeleton entries in download scripts
with data from install_verify.ps1, dfirws_folder.ps1, and dfirws-install.ps1.

Generates proper PowerShell hashtable format matching http.ps1 conventions:
- Shortcuts = @( @{ Lnk=...; Target=...; Args=...; Icon=...; WorkDir=... } )
- Verify = @( @{ Type="command"; Name=...; Expect=... } )
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

BASE_DIR = Path(__file__).resolve().parent.parent

VERIFY_FILE = BASE_DIR / "setup" / "install" / "install_verify.ps1"
FOLDER_FILE = BASE_DIR / "setup" / "utils" / "dfirws_folder.ps1"
INSTALL_FILE = BASE_DIR / "setup" / "utils" / "dfirws-install.ps1"

DOWNLOAD_FILES = [
    BASE_DIR / "resources" / "download" / "release.ps1",
    BASE_DIR / "resources" / "download" / "winget.ps1",
    BASE_DIR / "resources" / "download" / "python.ps1",
    BASE_DIR / "resources" / "download" / "go.ps1",
    BASE_DIR / "resources" / "download" / "node.ps1",
    BASE_DIR / "resources" / "download" / "rust.ps1",
    BASE_DIR / "resources" / "download" / "msys2.ps1",
]


def normalize(name: str) -> str:
    return re.sub(r"[^a-z0-9]", "", name.lower())


def get_cmd_basename(cmd: str) -> str:
    if "\\" in cmd or "/" in cmd:
        name = cmd.rsplit("\\", 1)[-1].rsplit("/", 1)[-1]
    else:
        name = cmd
    name = re.sub(r"\.(exe|py|dll|bat|ps1)$", "", name, flags=re.IGNORECASE)
    return name


def escape_ps_vars(s: str) -> str:
    """Add backtick before ${...} to prevent expansion in tool definitions."""
    return s.replace("${", "`${")


# ---------------------------------------------------------------------------
# Parse install_verify.ps1 → structured verify entries
# ---------------------------------------------------------------------------
def parse_verify(path: Path) -> List[dict]:
    entries = []
    text = path.read_text(encoding="utf-8")
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        m = re.match(r"Test-Command\s+(.+)", s)
        if not m:
            continue
        rest = m.group(1).strip()

        if rest.startswith('"'):
            m2 = re.match(r'"([^"]+)"\s+("?[^"\s]+"?)', rest)
            if m2:
                entries.append({
                    "Name": m2.group(1),
                    "Expect": m2.group(2).strip('"'),
                })
        elif rest.startswith("$"):
            continue  # skip variable references
        else:
            parts = rest.split()
            if len(parts) >= 2:
                entries.append({"Name": parts[0], "Expect": parts[1]})
    return entries


def build_verify_index(entries: List[dict]) -> Dict[str, List[dict]]:
    """Map normalized basename -> list of {Name, Expect} dicts."""
    index: Dict[str, List[dict]] = {}
    for e in entries:
        basename = get_cmd_basename(e["Name"])
        norm = normalize(basename)
        index.setdefault(norm, []).append(e)
    return index


def parse_verify_string(s: str) -> dict:
    """Parse a legacy verify string like 'artemis PE32' into {Name, Expect}."""
    s = s.strip()
    if s.startswith('"'):
        m = re.match(r'"([^"]+)"\s+(.+)', s)
        if m:
            return {"Name": m.group(1), "Expect": m.group(2).strip('"')}
    m = re.match(r'(\S+)\s+"([^"]+)"', s)
    if m:
        return {"Name": m.group(1), "Expect": m.group(2)}
    parts = s.split(None, 1)
    if len(parts) == 2:
        return {"Name": parts[0], "Expect": parts[1]}
    return {"Name": s, "Expect": "PE32"}


# ---------------------------------------------------------------------------
# Parse dfirws_folder.ps1 → full shortcut data
# ---------------------------------------------------------------------------
def parse_shortcuts_full(path: Path) -> Dict[Tuple[str, str], dict]:
    """Parse Add-Shortcut lines, indexed by (category, name)."""
    index: Dict[Tuple[str, str], dict] = {}
    text = path.read_text(encoding="utf-8")
    for line in text.splitlines():
        m = re.search(
            r"Add-Shortcut\s+-SourceLnk\s+\"([^\"]*\\Desktop\\dfirws\\(.+?)\\([^\\]+)\.lnk)\"",
            line,
            re.IGNORECASE,
        )
        if not m:
            continue
        lnk_path = m.group(1)
        category = m.group(2)
        name = m.group(3)

        # Extract DestinationPath
        m_dest = re.search(r'-DestinationPath\s+"([^"]+)"', line, re.IGNORECASE)
        target = m_dest.group(1) if m_dest else ""

        # Extract Arguments
        m_args = re.search(r'-Arguments\s+"([^"]+)"', line, re.IGNORECASE)
        args = m_args.group(1) if m_args else ""

        # Extract Iconlocation
        m_icon = re.search(r'-Iconlocation\s+"([^"]+)"', line, re.IGNORECASE)
        icon = m_icon.group(1) if m_icon else ""

        # Extract WorkingDirectory
        m_wd = re.search(r'-WorkingDirectory\s+"([^"]+)"', line, re.IGNORECASE)
        workdir = m_wd.group(1) if m_wd else ""

        key = (category, name)
        index[key] = {
            "lnk": lnk_path,
            "target": target,
            "args": args,
            "icon": icon,
            "workdir": workdir,
        }
    return index


# ---------------------------------------------------------------------------
# Parse dfirws-install.ps1
# ---------------------------------------------------------------------------
def parse_install_params(path: Path) -> List[str]:
    params = []
    text = path.read_text(encoding="utf-8")
    for line in text.splitlines():
        m = re.match(r"\s*\[switch\]\$(\w+)", line)
        if m:
            params.append(m.group(1))
    return params


# ---------------------------------------------------------------------------
# Explicit overrides for tricky mappings
# ---------------------------------------------------------------------------

# tool def Name -> list of verify strings (parsed into {Name, Expect} at use time)
VERIFY_OVERRIDES: Dict[str, List[str]] = {
    "aLEAPP": ["aleapp PE32", "aleappGUI PE32"],
    "iLEAPP": ["ileapp PE32", "ileappGUI PE32"],
    "Detect It Easy": ["die PE32", "diec PE32"],
    "HollowsHunter": ["hollows_hunter PE32"],
    "ripgrep": ["rg PE32"],
    "PE-utils": ["pescan PE32"],
    "readpe": ["pescan PE32"],
    "Flare-Floss": ["floss PE32"],
    "Flare-Fakenet-NG": ["fakenet PE32"],
    "yara-x": ["yr PE32"],
    "Jumplist Browser": ["JumplistBrowser PE32"],
    "Prefetch Browser": ["PrefetchBrowser PE32"],
    "YARA": ["yara PE32", "yarac PE32"],
    "ImHex": ["imhex-gui PE32", "imhex PE32"],
    "Elfparser-ng": ['"C:\\Tools\\elfparser-ng\\Release\\elfparser-ng.exe" PE32'],
    "XELFViewer": ['"C:\\Tools\\XELFViewer\\xelfviewer.exe" PE32'],
    "BeaconHunter": ['"${env:ProgramFiles}\\BeaconHunter\\BeaconHunter.exe" PE32'],
    "4n4lDetector": ['"${env:ProgramFiles}\\4N4LDetector\\4N4LDetector.exe" PE32'],
    "Audacity": ['"C:\\Tools\\Audacity\\audacity.exe" PE32'],
    "DBeaver": ['"C:\\Program Files\\dbeaver\\dbeaver.exe" PE32'],
    "dnSpy": ['"C:\\Tools\\dnSpy64\\bin\\dnSpy.dll" PE32'],
    "LogBoost": ['"C:\\Tools\\LogBoost\\LogBoost.exe" PE32'],
    "gftrace": ['"C:\\Tools\\gftrace64\\gftrace.exe" PE32'],
    "hfs": ['"C:\\Tools\\hfs\\hfs.exe" PE32'],
    "Iaito": ['"C:\\Tools\\iaito\\iaito.exe" PE32'],
    "mboxviewer": ['"C:\\Tools\\mboxviewer\\mboxview64.exe" PE32'],
    "RDPCacheStitcher": ['"C:\\Tools\\RdpCacheStitcher\\RdpCacheStitcher.exe" PE32'],
    "takajo": ['"C:\\Tools\\takajo\\takajo.exe" PE32'],
    "fqlite": ['"C:\\Users\\WDAGUtilityAccount\\AppData\\Local\\fqlite\\fqlite.exe" PE32'],
    "DB Browser for SQLite": ['"C:\\Tools\\sqlitebrowser\\DB Browser for SQLite.exe" PE32'],
    "Thumbcacheviewer": ["thumbcache_viewer PE32"],
    "Notepad++": ["notepad++ PE32"],
    "ComparePlus": ['C:\\downloads\\comparePlus.zip "Zip archive data"'],
    "DSpellCheck": ['C:\\downloads\\DSpellCheck.zip "Zip archive data"'],
    "zaproxy": ["zap PE32"],
    "srum_dump": ["srum_dump PE32"],
    "Sleuthkit": ["blkcalc PE32"],
    "Cutter": ["cutter PE32", "rizin PE32"],
    "Obsidian": ['"C:\\Users\\WDAGUtilityAccount\\AppData\\Local\\Programs\\Obsidian\\Obsidian.exe" PE32'],
    "IrfanView": ['"C:\\Program Files\\IrfanView\\i_view64.exe" PE32'],
    "Firefox": ['"C:\\Program Files\\Mozilla Firefox\\firefox.exe" PE32'],
    "Foxit PDF Reader": ['"C:\\Program Files\\Foxit Software\\Foxit PDF Reader\\FoxitPDFReader.exe" PE32'],
    "Google Earth Pro": ['"C:\\Program Files\\Google\\Google Earth Pro\\client\\googleearth.exe" PE32'],
    "VirusTotal CLI": ["vt PE32"],
    "Wireshark": ["Wireshark PE32"],
    "WinMerge": ["WinMergeU PE32"],
    "PuTTY": ["putty PE32"],
    "QEMU": ["qemu-img PE32"],
    "Ruby": ["ruby PE32"],
    "VLC": ["vlc PE32"],
    "Chrome": ["chrome PE32"],
    # Python tools
    "binary-refinery": ["C:\\venv\\bin\\binref.exe PE32"],
    "chepy": ["C:\\venv\\bin\\chepy.exe PE32"],
    "csvkit": ["C:\\venv\\bin\\csvclean.exe PE32", "C:\\venv\\bin\\csvcut.exe PE32"],
    "extract-msg": ["C:\\venv\\bin\\extract_msg.exe PE32"],
    "frida-tools": ["C:\\venv\\bin\\frida.exe PE32", "C:\\venv\\bin\\frida-apk.exe PE32"],
    "ghidrecomp": ["C:\\venv\\bin\\ghidrecomp.exe PE32"],
    "ghidriff": ["C:\\venv\\bin\\ghidriff.exe PE32"],
    "hachoir": ["C:\\venv\\bin\\hachoir-wx.exe PE32"],
    "jsbeautifier": ["C:\\venv\\bin\\js-beautify.exe PE32"],
    "jupyterlab": ["C:\\venv\\uv\\jupyterlab\\Scripts\\jupyter.exe PE32"],
    "litecli": ["C:\\venv\\bin\\litecli.exe PE32"],
    "LnkParse3": ["C:\\venv\\bin\\lnkparse.exe PE32"],
    "magika": ["C:\\venv\\bin\\magika.exe PE32"],
    "maldump": ["C:\\venv\\bin\\maldump.exe PE32"],
    "malwarebazaar": ["C:\\venv\\bin\\bazaar.exe PE32", "C:\\venv\\bin\\yaraify.exe PE32"],
    "minidump": ["C:\\venv\\bin\\minidump.exe PE32"],
    "mkyara": ["C:\\venv\\bin\\mkyara.exe PE32"],
    "msoffcrypto-tool": ["C:\\venv\\bin\\msoffcrypto-tool.exe PE32"],
    "mwcp": ["C:\\venv\\bin\\mwcp.exe PE32"],
    "name-that-hash": ["C:\\venv\\bin\\name-that-hash.exe PE32"],
    "oletools": ["C:\\venv\\bin\\oleid.exe PE32", "C:\\venv\\bin\\olevba.exe PE32", "C:\\venv\\bin\\mraptor.exe PE32"],
    "pcode2code": ["C:\\venv\\bin\\pcode2code.exe PE32"],
    "protodeep": ["C:\\venv\\bin\\protodeep.exe PE32"],
    "ptpython": ["C:\\venv\\bin\\ptpython.exe PE32"],
    "pwncat": ["C:\\venv\\bin\\pwncat.py Python"],
    "rexi": ["C:\\venv\\bin\\rexi.exe PE32"],
    "scapy": ["C:\\venv\\bin\\scapy.exe PE32"],
    "shodan": ["C:\\venv\\bin\\shodan.exe PE32"],
    "time-decode": ["C:\\venv\\bin\\time-decode.exe PE32"],
    "toolong": ["C:\\venv\\bin\\tl.exe PE32"],
    "visidata": ["C:\\venv\\bin\\visidata.exe PE32"],
    "XLMMacroDeobfuscator": ["C:\\venv\\bin\\xlmdeobfuscator.exe PE32"],
    "peepdf-3": ["C:\\venv\\bin\\peepdf.exe PE32"],
    "autoit-ripper": ["C:\\venv\\bin\\autoit-ripper.exe PE32"],
    "cart": ["C:\\venv\\bin\\cart.exe PE32"],
    "deep_translator": ["C:\\venv\\bin\\deep-translator.exe PE32"],
    "docx2txt": ["C:\\venv\\bin\\docx2txt.py Python"],
    "flatten_json": ["C:\\venv\\bin\\flatten_json.exe PE32"],
    "grip": ["C:\\venv\\bin\\grip.exe PE32"],
    "jpterm": ["C:\\venv\\bin\\jpterm.exe PE32"],
    "pyOneNote": ["C:\\venv\\bin\\pyonenote.exe PE32"],
    "dfir_ntfs": ["C:\\venv\\bin\\ntfs_parser.py Python", "C:\\venv\\bin\\fat_parser.py Python"],
    "regipy": ["C:\\venv\\uv\\regipy\\Scripts\\evtx_dump.exe PE32"],
    "acquire": ["C:\\venv\\default\\Scripts\\acquire.exe PE32", "C:\\venv\\default\\Scripts\\acquire-decrypt.exe PE32"],
    "dissect": ["C:\\venv\\default\\Scripts\\rdump.exe PE32"],
    "dissect.target": ["C:\\venv\\default\\Scripts\\target-shell.exe PE32"],
    "sigma-cli": ["C:\\venv\\default\\Scripts\\sigma.exe PE32"],
    "dfir-unfurl": ["C:\\venv\\dfir-unfurl\\Scripts\\unfurl.exe PE32"],
    "stego-lsb": [],
    "sqlit-tui": [],
    "markitdown": [],
    "netaddr": ["C:\\venv\\bin\\netaddr.exe PE32"],
    "pypng": ["C:\\venv\\bin\\priweavepng.py Python"],
    "unpy2exe": ["C:\\venv\\bin\\unpy2exe.py Python"],
    "xlrd": ["C:\\venv\\bin\\runxlrd.py Python"],
    # --- go.ps1 tools ---
    "protodump": [],
    # --- node.ps1 tools ---
    "box-js": [],
    "deobfuscator": [],
    "docsify-cli": [],
    "jsdom": [],
    "LUMEN": [],
    # --- rust.ps1 tools ---
    "dfir-toolkit": [
        "cleanhive PE32",
        "evtx2bodyfile PE32",
        "evtxanalyze PE32",
        "evtxcat PE32",
        "evtxls PE32",
        "evtxscan PE32",
        "hivescan PE32",
        "ipgrep PE32",
        "lnk2bodyfile PE32",
        "mactime2 PE32",
        "pf2bodyfile PE32",
        "pol_export PE32",
        "regdump PE32",
        "ts2date PE32",
        "zip2bodyfile PE32",
    ],
    "usnjrnl": ["usnjrnl_dump PE32"],
    "mft2bodyfile": ["mft2bodyfile PE32"],
    "CuTE-tui": ["cute PE32"],
    "SSHniff": ["sshniff PE32"],
    # --- msys2.ps1 tools ---
    "MSYS2": ["msys2 PE32", "bash PE32", "gcc PE32", "gdb PE32"],
}

# tool def Name -> dfirws category path
CATEGORY_MAP: Dict[str, str] = {
    # release.ps1 tools
    "artemis": "Forensics",
    "godap": "Utilities",
    "BeaconHunter": "Malware tools\\Cobalt Strike",
    "4n4lDetector": "Files and apps\\PE",
    "aLEAPP": "Files and apps\\Phone",
    "iLEAPP": "Files and apps\\Phone",
    "lessmsi": "Files and apps",
    "fx": "Files and apps\\Log",
    "CobaltStrikeScan": "Malware tools\\Cobalt Strike",
    "Audacity": "Utilities\\Media",
    "Ares": "Utilities\\Cryptography",
    "Zui": "Network",
    "RDPCacheStitcher": "Files and apps\\RDP",
    "ffmpeg": "Utilities\\Media",
    "ripgrep": "Files and apps",
    "binlex": "Files and apps",
    "cmder": "Utilities",
    "Recaf": "Programming\\Java",
    "DBeaver": "Files and apps\\Database",
    "Dumpbin": "Files and apps",
    "dnSpy": "Reverse Engineering",
    "Dokany": "Memory",
    "mboxviewer": "Files and apps\\Email",
    "zstd": "Utilities",
    "CyberChef": "Utilities\\Cryptography",
    "redress": "Programming\\Go",
    "h2database": "Files and apps\\Database",
    "INDXRipper": "Files and apps\\Disk",
    "dll_to_exe": "Files and apps\\PE",
    "HollowsHunter": "Files and apps\\PE",
    "PE-bear": "Files and apps\\PE",
    "PE-sieve": "Files and apps\\PE",
    "PE-utils": "Files and apps\\PE",
    "WinObjEx64": "Files and apps\\PE",
    "Detect It Easy": "Files and apps",
    "XELFViewer": "OS\\Linux",
    "jd-gui": "Programming\\Java",
    "LogBoost": "Files and apps\\Log",
    "jq": "Files and apps",
    "Jumplist Browser": "OS\\Windows",
    "MFTBrowser": "Files and apps\\Disk",
    "Prefetch Browser": "OS\\Windows",
    "bytecode-viewer": "Editors",
    "gftrace": "Programming\\Go",
    "adalanche": "OS\\Windows\\Active Directory (AD)",
    "MsgViewer": "Files and apps\\Email",
    "capa": "Files and apps\\PE",
    "capa-rules": "Files and apps\\PE",
    "Ghidra GolangAnalyzerExtension": "Reverse Engineering",
    "PowerShell": "Programming\\PowerShell",
    "Ghidra BTIGhidra": "Reverse Engineering",
    "Ghidra Cartographer": "Reverse Engineering",
    "Flare-Floss": "Utilities",
    "Flare-Fakenet-NG": "Network",
    "GoReSym": "Programming\\Go",
    "mmdbinspect": "Utilities",
    "Elfparser-ng": "OS\\Linux",
    "readpe": "Files and apps\\PE",
    "DitExplorer": "OS\\Windows\\Active Directory (AD)",
    "srum_dump": "OS\\Windows",
    "forensic-timeliner": "IR",
    "jwt-cli": "Programming\\Java",
    "dsq": "Files and apps\\Database",
    "MetadataPlus": "Files and apps\\Office",
    "Loki": "Signatures and information",
    "Notepad++": "Editors",
    "HindSight": "Files and apps\\Browser",
    "evtx_dump": "Files and apps\\Log",
    "ComparePlus": "Editors",
    "DSpellCheck": "Editors",
    "VS Code PowerShell Extension": "Editors",
    "vscode-shellcheck": "Editors",
    "qpdf": "Files and apps\\PDF",
    "Fibratus": "OS\\Windows",
    "Radare2": "Reverse Engineering",
    "Iaito": "Reverse Engineering",
    "hfs": "Network",
    "obsidian-mitre-attack": "Editors",
    "Cutter": "Reverse Engineering",
    "Nerd Fonts": "Utilities",
    "Strawberry Perl": "Programming",
    "sidr": "OS\\Windows",
    "jadx": "Programming\\Java",
    "Sleuthkit": "Files and apps\\Disk",
    "qrtool": "Files and apps",
    "debloat": "Files and apps\\PE",
    "VS Code Spell Checker": "Editors",
    "Thumbcacheviewer": "OS\\Windows",
    "gron": "Files and apps\\Log",
    "MemProcFS": "Memory",
    "upx": "Utilities",
    "Velociraptor": "IR",
    "Witr": "IR",
    "fq": "Files and apps",
    "fqlite": "Files and apps\\Database",
    "Zircolite": "Files and apps\\Log",
    "ImHex": "Editors",
    "chainsaw": "Files and apps\\Log",
    "YARA": "Signatures and information",
    "yara-x": "Signatures and information",
    "yq": "Signatures and information",
    "x64dbg": "Reverse Engineering",
    "hayabusa": "Files and apps\\Log",
    "takajo": "Files and apps\\Log",
    "zaproxy": "Network",
    "edit": "Utilities",
    "DB Browser for SQLite": "Files and apps\\Database",
    "NetExt": "Reverse Engineering",
    "YAMAGoya": "Files and apps\\Log",
    "obsidian-dataview": "Editors",
    "obsidian-kanban": "Editors",
    "quickadd": "Editors",
    "obsidian-calendar-plugin": "Editors",
    "Templater": "Editors",
    "obsidian-tasks": "Editors",
    "obsidian-excalidraw-plugin": "Editors",
    "admonitions": "Editors",
    "obsidian-timeline": "Editors",
    # winget.ps1 tools
    "Autopsy": "Forensics",
    "Burp Suite": "Network",
    "Chrome": "Utilities\\Browsers",
    "Docker Desktop": "Utilities",
    "DotNet 6 Desktop Runtime": "Programming\\dotNET",
    "DotNet 8 Desktop Runtime": "Programming\\dotNET",
    "IrfanView": "Utilities\\Media",
    "Obsidian": "Editors",
    "oh-my-posh": "Utilities",
    "PowerShell 7": "Programming\\PowerShell",
    "PuTTY": "Network",
    "QEMU": "Files and apps",
    "Ruby": "Programming\\Ruby",
    "VLC": "Utilities\\Media",
    "VirusTotal CLI": "Signatures and information\\Online tools",
    "WinMerge": "Files and apps",
    "OpenVPN": "Network",
    "Google Earth Pro": "Utilities",
    "OSFMount": "Files and apps\\Disk",
    "WireGuard": "Network",
    "Wireshark": "Network",
    "Tailscale": "Network",
    "Firefox": "Utilities\\Browsers",
    "Foxit PDF Reader": "Files and apps\\PDF",
    "uv": "Programming\\Python",
    "WinDbg": "Reverse Engineering",
    # python.ps1 tools
    "dfir_ntfs": "Files and apps\\Disk",
    "binary-refinery": "Forensics",
    "regipy": "OS\\Windows\\Registry",
    "peepdf-3": "Files and apps\\PDF",
    "mkdocs": "Utilities",
    "autoit-ripper": "Files and apps",
    "cart": "Forensics",
    "chepy": "Utilities\\Cryptography",
    "csvkit": "Malware tools",
    "deep_translator": "Utilities",
    "docx2txt": "Files and apps\\Office",
    "extract-msg": "Files and apps\\Email",
    "flatten_json": "Files and apps\\Log",
    "frida-tools": "Reverse Engineering",
    "ghidrecomp": "Reverse Engineering",
    "ghidriff": "Reverse Engineering",
    "grip": "Utilities",
    "hachoir": "Files and apps\\PE",
    "jpterm": "Utilities",
    "jsbeautifier": "Files and apps\\JavaScript",
    "jupyterlab": "Utilities",
    "litecli": "Files and apps\\Database",
    "LnkParse3": "OS\\Windows",
    "magika": "Files and apps",
    "maldump": "Malware tools",
    "malwarebazaar": "Signatures and information\\Online tools",
    "markitdown": "Utilities",
    "minidump": "Memory",
    "mkyara": "Signatures and information",
    "msoffcrypto-tool": "Files and apps\\Office",
    "mwcp": "Malware tools",
    "name-that-hash": "Utilities\\Cryptography",
    "netaddr": "Network",
    "numpy": "Programming\\Python",
    "oletools": "Files and apps\\Office",
    "pcode2code": "Files and apps\\Office",
    "pdfalyzer": "Files and apps\\PDF",
    "protodeep": "Network",
    "ptpython": "Programming\\Python",
    "pwncat": "Utilities",
    "pyghidra": "Reverse Engineering",
    "pyOneNote": "Files and apps\\Office",
    "pypng": "Utilities\\CTF",
    "rexi": "Utilities",
    "scapy": "Network",
    "shodan": "Signatures and information\\Online tools",
    "stego-lsb": "Utilities\\CTF",
    "sqlit-tui": "Files and apps\\Database",
    "time-decode": "Utilities",
    "toolong": "Files and apps\\Log",
    "unpy2exe": "Files and apps",
    "visidata": "Utilities",
    "xlrd": "Files and apps\\Office",
    "XLMMacroDeobfuscator": "Files and apps\\Office",
    "XlsxWriter": "Files and apps\\Office",
    "acquire": "Forensics",
    "aiodns": "Programming\\Python",
    "aiohttp": "Programming\\Python",
    "Aspose.Email-for-Python-via-Net": "Files and apps\\Email",
    "BeautifulSoup4": "Programming\\Python",
    "bitstruct": "Programming\\Python",
    "compressed_rtf": "Files and apps\\Office",
    "dissect": "Forensics",
    "dissect.target": "Forensics",
    "dnslib": "Network",
    "flow.record": "Forensics",
    "geoip2": "Network",
    "cabarchive": "Files and apps",
    "dotnetfile": "Programming\\dotNET",
    "dpkt": "Network",
    "elasticsearch": "Files and apps\\Database",
    "evtx": "Files and apps\\Log",
    "graphviz": "Utilities",
    "javaobj-py3": "Programming\\Java",
    "keystone-engine": "Reverse Engineering",
    "lief": "Files and apps\\PE",
    "matplotlib": "Programming\\Python",
    "msticpy": "Forensics",
    "neo4j": "Files and apps\\Database",
    "networkx": "Programming\\Python",
    "olefile": "Files and apps\\Office",
    "openpyxl": "Files and apps\\Office",
    "orjson": "Programming\\Python",
    "paramiko": "Network",
    "pathlab": "Forensics",
    "pefile": "Files and apps\\PE",
    "peutils": "Files and apps\\PE",
    "pfp": "Files and apps\\PE",
    "ppdeep": "Signatures and information",
    "prettytable": "Utilities",
    "pyasn1": "Programming\\Python",
    "pycares": "Network",
    "pycryptodome": "Utilities\\Cryptography",
    "pydivert": "Network",
    "pypdf": "Files and apps\\PDF",
    "pyshark": "Network",
    "PySocks": "Network",
    "python-docx": "Files and apps\\Office",
    "python-dotenv": "Programming\\Python",
    "python-magic": "Files and apps",
    "python-registry": "OS\\Windows\\Registry",
    "pyvis": "Utilities",
    "pyzipper": "Files and apps",
    "requests": "Programming\\Python",
    "rzpipe": "Reverse Engineering",
    "sigma-cli": "Signatures and information",
    "pysigma-backend-elasticsearch": "Signatures and information",
    "pySigma-backend-loki": "Signatures and information",
    "pysigma-backend-splunk": "Signatures and information",
    "pysigma-backend-sqlite": "Signatures and information",
    "pysigma-pipeline-sysmon": "Signatures and information",
    "pysigma-pipeline-windows": "Signatures and information",
    "simplejson": "Programming\\Python",
    "termcolor": "Programming\\Python",
    "textsearch": "Programming\\Python",
    "tomlkit": "Programming\\Python",
    "treelib": "Programming\\Python",
    "unicorn": "Reverse Engineering",
    "xxhash": "Programming\\Python",
    "yara-python": "Signatures and information",
    "dfir-unfurl": "Files and apps\\Browser",
    "hexdump": "Utilities",
    "maclookup": "Network",
    # --- go.ps1 tools ---
    "protodump": "Utilities\\Cryptography",
    # --- node.ps1 tools ---
    "box-js": "Files and apps\\JavaScript",
    "deobfuscator": "Files and apps\\JavaScript",
    "docsify-cli": "Utilities",
    "jsdom": "Files and apps\\JavaScript",
    "LUMEN": "Files and apps\\Log",
    # --- rust.ps1 tools ---
    "dfir-toolkit": "Forensics",
    "usnjrnl": "OS\\Windows",
    "mft2bodyfile": "Files and apps\\Disk",
    "CuTE-tui": "Utilities",
    "SSHniff": "Network",
    # --- msys2.ps1 tools ---
    "MSYS2": "Programming",
}

# tool def Name -> dfirws-install.ps1 parameter name
INSTALL_CMD_MAP: Dict[str, str] = {
    # release.ps1
    "cmder": "CMDer",
    "Dokany": "Dokany",
    "x64dbg": "X64Dbg",
    "jadx": "Jadx",
    "LogBoost": "LogBoost",
    "Loki": "Loki",
    "Fibratus": "Fibratus",
    "DBeaver": "Dbeaver",
    "fqlite": "FQLite",
    "forensic-timeliner": "ForensicTimeliner",
    "zaproxy": "ZAProxy",
    "Zui": "Zui",
    # winget.ps1
    "Autopsy": "Autopsy",
    "Burp Suite": "BurpSuite",
    "Chrome": "Chrome",
    "Docker Desktop": "Docker",
    "Firefox": "Firefox",
    "Foxit PDF Reader": "FoxitReader",
    "Google Earth Pro": "GoogleEarth",
    "Obsidian": "Obsidian",
    "oh-my-posh": "OhMyPosh",
    "OSFMount": "OSFMount",
    "PuTTY": "PuTTY",
    "QEMU": "Qemu",
    "Ruby": "Ruby",
    "VLC": "VLC",
    "WinDbg": "Windbg",
    "WinMerge": "WinMerge",
    "Wireshark": "Wireshark",
    # go.ps1
    "protodump": "GoLang",
    # node.ps1
    "box-js": "Node",
    "deobfuscator": "Node",
    "docsify-cli": "Node",
    "jsdom": "Node",
    "LUMEN": "Node",
    # rust.ps1
    "dfir-toolkit": "Rust",
    "usnjrnl": "Rust",
    "mft2bodyfile": "Rust",
    "CuTE-tui": "Rust",
    "SSHniff": "Rust",
}

# Shortcut overrides: tool name -> list of (category, shortcut_name) tuples
# These are keys into the parsed shortcut index from dfirws_folder.ps1
SHORTCUT_OVERRIDES: Dict[str, List[Tuple[str, str]]] = {
    "artemis": [("Forensics", "artemis")],
    "godap": [("Utilities", "godap (LDAP tool)")],
    "BeaconHunter": [("Malware tools\\Cobalt Strike", "BeaconHunter")],
    "4n4lDetector": [("Files and apps\\PE", "4n4lDetector")],
    "aLEAPP": [
        ("Files and apps\\Phone", "aleapp (Android Logs, Events, and Protobuf Parser)"),
        ("Files and apps\\Phone", "aleappGUI"),
    ],
    "iLEAPP": [
        ("Files and apps\\Phone", "ileapp (iOS Logs, Events, And Plists Parser)"),
        ("Files and apps\\Phone", "iLEAPPGUI"),
    ],
    "CobaltStrikeScan": [("Malware tools\\Cobalt Strike", "CobaltStrikeScan")],
    "Audacity": [("Utilities\\Media", "Audacity")],
    "ffmpeg": [("Utilities\\Media", "ffmpeg")],
    "ripgrep": [("Files and apps", "ripgrep (rg)")],
    "binlex": [("Files and apps", "binlex (A Binary Genetic Traits Lexer)")],
    "DBeaver": [("Files and apps\\Database", "dbeaver (runs dfirws-install -DBeaver)")],
    "dnSpy": [
        ("Reverse Engineering", "dnSpy32"),
        ("Reverse Engineering", "dnSpy64"),
    ],
    "CyberChef": [("Utilities\\Cryptography", "CyberChef")],
    "INDXRipper": [("Files and apps\\Disk", "INDXRipper")],
    "HollowsHunter": [("Files and apps\\PE", "hollows_hunter (Scans running processes. Recognizes and dumps a variety of in-memory implants)")],
    "PE-bear": [("Files and apps\\PE", "PE-bear")],
    "PE-sieve": [("Files and apps\\PE", "PE-sieve (Scans a given process, recognizes and dumps a variety of in-memory implants)")],
    "WinObjEx64": [("Files and apps\\PE", "WinObjEx64")],
    "Detect It Easy": [("Files and apps", "Detect It Easy (determining types of files)")],
    "XELFViewer": [("OS\\Linux", "xelfviewer")],
    "jd-gui": [("Programming\\Java", "jd-gui")],
    "jq": [("Files and apps", "jq ( commandline JSON processor)")],
    "Jumplist Browser": [("OS\\Windows", "Jumplist-Browser")],
    "MFTBrowser": [("Files and apps\\Disk", "MFTBrowser")],
    "Prefetch Browser": [("OS\\Windows", "Prefetch-Browser")],
    "bytecode-viewer": [("Editors", "Bytecode Viewer")],
    "gftrace": [("Programming\\Go", "gftrace")],
    "adalanche": [("OS\\Windows\\Active Directory (AD)", "adalanche (Active Directory ACL Visualizer and Explorer)")],
    "capa": [("Files and apps\\PE", "capa")],
    "Flare-Floss": [("Utilities", "floss")],
    "Flare-Fakenet-NG": [("Network", "Fakenet")],
    "GoReSym": [("Programming\\Go", "GoReSym")],
    "mmdbinspect": [("Utilities", "mmdbinspect (Tool for GeoIP lookup)")],
    "Elfparser-ng": [("OS\\Linux", "elfparser-ng")],
    "DitExplorer": [("OS\\Windows\\Active Directory (AD)", "DitExplorer (Active Directory Database Explorer)")],
    "srum_dump": [("OS\\Windows", "srum-dump (Parses Windows System Resource Usage Monitor (SRUM) database)")],
    "dsq": [("Files and apps\\Database", "dsq (commandline SQL engine for data files)")],
    "MetadataPlus": [("Files and apps\\Office", "MetadataPlus")],
    "Loki": [("Signatures and information", "loki (runs dfirws-install -Loki)")],
    "Notepad++": [("Editors", "Notepad++")],
    "HindSight": [
        ("Files and apps\\Browser", "hindsight (Internet history forensics for Google Chrome and Chromium)"),
        ("Files and apps\\Browser", "hindsight_gui"),
    ],
    "evtx_dump": [("Files and apps\\Log", "evtx_dump (Utility to parse EVTX files)")],
    "qpdf": [("Files and apps\\PDF", "qpdf")],
    "Fibratus": [("OS\\Windows", "fibratus (runs dfirws-install -Fibratus)")],
    "Radare2": [("Reverse Engineering", "radare2")],
    "Iaito": [("Reverse Engineering", "iaito")],
    "hfs": [("Network", "hfs.exe")],
    "Cutter": [("Reverse Engineering", "Cutter")],
    "sidr": [("OS\\Windows", "sidr (Search Index DB Reporter - handles both ESE (.edb) and SQLite)")],
    "Sleuthkit": [("Files and apps\\Disk", "blkcalc (Calculates where data in the unallocated space image)")],
    "debloat": [("Files and apps\\PE", "Debloat")],
    "Thumbcacheviewer": [("OS\\Windows", "Thumbcache Viewer")],
    "gron": [("Files and apps\\Log", "gron (Make JSON greppable)")],
    "MemProcFS": [("Memory", "MemProcFS")],
    "upx": [("Utilities", "upx")],
    "Velociraptor": [("IR", "velociraptor.exe (Velociraptor is an advanced digital forensic and incident response tool that enhances your visibility into your endpoints)")],
    "fq": [("Files and apps", "fq (jq for binary formats)")],
    "fqlite": [("Files and apps\\Database", "fqlite (runs dfirws-install -FQLite)")],
    "Zircolite": [("Files and apps\\Log", "zircolite (Standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs)")],
    "ImHex": [("Editors", "ImHex")],
    "chainsaw": [("Files and apps\\Log", "chainsaw (Rapidly work with Forensic Artefacts)")],
    "YARA": [("Signatures and information", "yara"), ("Signatures and information", "yarac")],
    "yara-x": [("Signatures and information", "yr (yara-x)")],
    "yq": [("Signatures and information", "yq (is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor)")],
    "x64dbg": [("Reverse Engineering", "X64dbg (runs dfirws-install -X64dbg)")],
    "hayabusa": [("Files and apps\\Log", "hayabusa (is a sigma-based threat hunting and fast forensics timeline generator for Windows event logs)")],
    "takajo": [("Files and apps\\Log", "takajo (is a tool to analyze Windows event logs - hayabusa)")],
    "zaproxy": [("Network", "Zaproxy (runs dfirws-install -Zaproxy)")],
    "DB Browser for SQLite": [("Files and apps\\Database", "DB Browser for SQLite")],
    "YAMAGoya": [("Files and apps\\Log", "YAMAGoya (Yet Another Memory Analyzer for malware detection and Guarding Operations with YARA and SIGMA)")],
    "redress": [("Programming\\Go", "Redress")],
    "Ares": [("Utilities\\Cryptography", "ares")],
    "Zui": [("Network", "Zui (runs dfirws-install -Zui)")],
    "lessmsi": [("Files and apps", "lessmsi (A tool to view and extract the contents of a Windows Installer (.msi) file)")],
    "fx": [("Files and apps\\Log", "fx (Terminal JSON viewer and processor)")],
    "Dumpbin": [("Files and apps", "dumpbin (Microsoft COFF Binary File Dumper)")],
    "mboxviewer": [("Files and apps\\Email", "Mbox Viewer")],
    "zstd": [("Utilities", "zstd")],
    "RDPCacheStitcher": [("Files and apps\\RDP", "RdpCacheStitcher")],
    "LogBoost": [("Files and apps\\Log", "logboost (runs dfirws-install -LogBoost)")],
    "Recaf": [("Programming\\Java", "recaf (The modern Java bytecode editor)")],
    "MsgViewer": [("Files and apps\\Email", "msgviewer")],
    "Dokany": [("Memory", "Dokany (runs dfirws-install -Dokany)")],
    "h2database": [("Files and apps\\Database", "h2 database")],
    "jadx": [("Programming\\Java", "Jadx (runs dfirws-install -Jadx)")],
    # winget.ps1
    "Autopsy": [("Forensics", "Autopsy (runs dfirws-install -Autopsy)")],
    "Burp Suite": [("Network", "Burp Suite (runs dfirws-install -BurpSuite)")],
    "Chrome": [("Utilities\\Browsers", "Chrome (runs dfirws-install -Chrome)")],
    "Docker Desktop": [("Utilities", "Docker (runs dfirws-install.ps1 -Docker)")],
    "Obsidian": [("Editors", "Obsidian (runs dfirws-install -Obsidian)")],
    "oh-my-posh": [("Utilities", "Oh-My-Posh (runs dfirws-install -OhMyPosh)")],
    "PuTTY": [("Network", "PuTTY (runs dfirws-install -PuTTY)")],
    "VLC": [("Utilities\\Media", "VLC (runs dfirws-install -VLC)")],
    "WinMerge": [("Files and apps", "WinMerge (runs dfirws-install -WinMerge)")],
    "Wireshark": [("Network", "Wireshark (runs dfirws-install -Wireshark)")],
    "Firefox": [("Utilities\\Browsers", "Firefox (runs dfirws-install -Firefox)")],
    "Foxit PDF Reader": [("Files and apps\\PDF", "Foxit Reader for pdf files (runs dfirws-install -FoxitReader)")],
    "Google Earth Pro": [("Utilities", "Google Earth (runs dfirws-install -GoogleEarth)")],
    "OSFMount": [("Files and apps\\Disk", "OSFMount (runs dfirws-install -OSFMount)")],
    "VirusTotal CLI": [("Signatures and information\\Online tools", "vt (A command-line tool for interacting with VirusTotal)")],
    "WinDbg": [],
    # python.ps1
    "binary-refinery": [("Forensics", "binary-refinery")],
    "chepy": [("Utilities\\Cryptography", "chepy")],
    "csvkit": [("Malware tools", "csvkit (tools for working with csv files)")],
    "extract-msg": [("Files and apps\\Email", "extract_msg")],
    "autoit-ripper": [("Files and apps", "autoit-ripper")],
    "magika": [("Files and apps", "magika (A tool like file and file-magic based on AI)")],
    "maldump": [("Malware tools", "maldump.exe (Multi-quarantine extractor)")],
    "malwarebazaar": [("Signatures and information\\Online tools", "bazaar")],
    "markitdown": [("Utilities", "markitdown (Python tool for converting files and office documents to Markdown)")],
    "mkyara": [("Signatures and information", "mkyara")],
    "msoffcrypto-tool": [("Files and apps\\Office", "msoffcrypto-tool")],
    "name-that-hash": [("Utilities\\Cryptography", "name-that-hash (also available as nth)")],
    "oletools": [
        ("Files and apps\\Office", "oleid"),
        ("Files and apps\\Office", "olevba"),
        ("Files and apps\\Office", "mraptor"),
        ("Files and apps\\Office", "msodde"),
    ],
    "pcode2code": [("Files and apps\\Office", "pcode2code")],
    "peepdf-3": [("Files and apps\\PDF", "peepdf-3 (peepdf - peepdf-3 is a Python 3 tool to explore PDF files)")],
    "rexi": [("Utilities", "rexi.exe (Terminal UI for Regex Testing)")],
    "scapy": [("Network", "scapy")],
    "shodan": [("Signatures and information\\Online tools", "shodan")],
    "time-decode": [("Utilities", "time-decode")],
    "toolong": [("Files and apps\\Log", "toolong (tl - A terminal application to view, tail, merge, and search log files (plus JSONL))")],
    "visidata": [("Utilities", "visidata (VisiData or vd is an interactive multitool for tabular data)")],
    "XLMMacroDeobfuscator": [("Files and apps\\Office", "xlmdeobfuscator (XLMMacroDeobfuscator can be used to decode obfuscated XLM macros)")],
    "jpterm": [("Utilities", "jpterm (Jupyter in the terminal)")],
    "litecli": [("Files and apps\\Database", "litecli (SQLite CLI with autocompletion and syntax highlighting)")],
    "pwncat": [("Utilities", "pwncat.py (Fancy reverse and bind shell handler)")],
    "sigma-cli": [("Signatures and information", "sigma-cli (This is the Sigma command line interface using the pySigma library to manage, list and convert Sigma rules into query languages)")],
    "dfir-unfurl": [
        ("Files and apps\\Browser", "unfurl_app.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl)"),
        ("Files and apps\\Browser", "unfurl.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl)"),
    ],
    "jsbeautifier": [("Files and apps\\JavaScript", "js-beautify (Javascript beautifier)")],
    "hachoir": [("Files and apps\\PE", "hachoir-tools")],
    "ghidrecomp": [],
    "ghidriff": [],
    "grip": [],
    "LnkParse3": [],
    "minidump": [],
    "protodeep": [],
    "ptpython": [],
    "pyOneNote": [],
    "dfir_ntfs": [
        ("Files and apps\\Disk", "ntfs_parser.py (Extract information from NTFS metadata files, volumes, and shadow copies)"),
        ("Files and apps\\Disk", "fat_parser.py (Extract information from FAT files)"),
    ],
    "regipy": [
        ("OS\\Windows\\Registry", "regipy-diff"),
        ("OS\\Windows\\Registry", "regipy-dump"),
    ],
    "acquire": [
        ("Forensics", "acquire.exe (dissect)"),
        ("Forensics", "acquire-decrypt.exe (dissect)"),
    ],
    "dissect": [("Forensics", "rdump.exe (dissect)")],
    "dissect.target": [
        ("Forensics", "target-query.exe (dissect)"),
        ("Forensics", "target-shell.exe (dissect)"),
    ],
    # --- go.ps1 tools ---
    "protodump": [],
    # --- node.ps1 tools ---
    "box-js": [("Files and apps\\JavaScript", "box-js (is a utility to analyze malicious JavaScript files)")],
    "deobfuscator": [("Files and apps\\JavaScript", "deobfuscator (synchrony)")],
    "docsify-cli": [],
    "jsdom": [("Files and apps\\JavaScript", "jsdom (opens README in Notepad++)")],
    "LUMEN": [("Files and apps\\Log", "Lumen (Browser-based EVTX Companion)")],
    # --- rust.ps1 tools ---
    "dfir-toolkit": [
        ("Files and apps\\Log", "cleanhive (merges logfiles into a hive file - dfir-toolkit)"),
        ("Files and apps\\Log", "evtvenv x2bodyfile (creates bodyfile from Windows evtx files - dfir-toolkit)"),
        ("Files and apps\\Log", "evtxanalyze (crate provide functions to analyze evtx files - dfir-toolkit)"),
        ("Files and apps\\Log", "evtxcat (Display one or more events from an evtx file - dfir-toolkit)"),
        ("Files and apps\\Log", "evtxls (Display one or more events from an evtx file - dfir-toolkit)"),
        ("Files and apps\\Log", "evtxscan (Find time skews in an evtx file - dfir-toolkit)"),
        ("Files and apps\\Log", "ipgrep (search for IP addresses in text files - dfir-toolkit)"),
        ("Files and apps\\Log", "pf2bodyfile.exe (creates bodyfile from Windows Prefetch files - dfir-toolkit)"),
        ("Files and apps\\Disk", "mactime2 (replacement for mactime - dfir-toolkit)"),
        ("Files and apps\\Disk", "mft2bodyfile (parses an MFT file (and optionally the corresponding UsnJrnl) to bodyfile - dfir-toolkit - janstarke)"),
        ("OS\\Windows", "lnk2bodyfile (Parse Windows LNK files and create bodyfile output - dfir-toolkit)"),
        ("OS\\Windows\\Registry", "pol_export (Exporter for Windows Registry Policy Files - dfir-toolkit)"),
        ("OS\\Windows\\Registry", "regdump (parses registry hive files and prints a bodyfile - dfir-toolkit)"),
    ],
    "usnjrnl": [("OS\\Windows", "usnjrnl_dump (Parses Windows UsnJrnl files - dfir-toolkit - janstarke)")],
    "mft2bodyfile": [("Files and apps\\Disk", "mft2bodyfile (parses an MFT file (and optionally the corresponding UsnJrnl) to bodyfile - dfir-toolkit - janstarke)")],
    "CuTE-tui": [],
    "SSHniff": [],
    # --- msys2.ps1 tools ---
    "MSYS2": [],
}

# ---------------------------------------------------------------------------
# File‑extension → tools mapping  (keys are tool names as in $TOOL_DEFINITIONS)
# Values are lists of extensions *with* the leading dot.
# ---------------------------------------------------------------------------

FILE_EXTENSIONS_MAP: Dict[str, List[str]] = {
    # --- release.ps1 tools ---
    "4n4lDetector": [".exe", ".dll"],
    "adalanche": [".json"],
    "aLEAPP": [".tar", ".zip"],
    "Ares": [".exe", ".dll"],
    "artemis": [".exe", ".dll", ".evtx", ".reg"],
    "Audacity": [".wav", ".mp3", ".flac", ".ogg", ".aiff"],
    "BeaconHunter": [".dmp", ".exe", ".dll"],
    "binary-refinery": [".exe", ".dll", ".bin"],
    "binlex": [".exe", ".dll", ".elf", ".bin"],
    "bytecode-viewer": [".class", ".jar", ".apk", ".dex"],
    "cart": [".cart"],
    "chainsaw": [".evtx"],
    "cmder": [],
    "CobaltStrikeScan": [".exe", ".dll", ".dmp", ".bin"],
    "ComparePlus": [],
    "Cutter": [".exe", ".dll", ".elf", ".bin", ".so", ".dylib"],
    "CyberChef": [".bin", ".txt", ".json", ".hex"],
    "DB Browser for SQLite": [".db", ".sqlite", ".sqlite3"],
    "DBeaver": [".db", ".sqlite", ".sqlite3", ".sql"],
    "dbSpy": [".db", ".sqlite", ".sqlite3"],
    "debloat": [".exe", ".dll"],
    "Detect It Easy": [".exe", ".dll", ".elf", ".mach-o", ".bin"],
    "DitExplorer": [".dit"],
    "dll_to_exe": [".dll"],
    "Dokany": [],
    "DSpellCheck": [],
    "dsq": [".json", ".csv", ".tsv", ".parquet"],
    "Dumpbin": [".exe", ".dll", ".obj", ".lib"],
    "edit": [],
    "Elfparser-ng": [".elf", ".so"],
    "evtx_dump": [".evtx"],
    "ffmpeg": [".mp4", ".avi", ".mkv", ".mov", ".mp3", ".wav", ".flac"],
    "Fibratus": [".etl"],
    "Flare-Fakenet-NG": [".pcap"],
    "Flare-Floss": [".exe", ".dll", ".bin"],
    "forensic-timeliner": [".evtx", ".csv", ".json"],
    "fq": [".pcap", ".pcapng", ".mp4", ".mp3", ".flac", ".zip", ".tar", ".gif", ".png"],
    "fqlite": [".db", ".sqlite", ".sqlite3"],
    "fx": [".json"],
    "gftrace": [".exe"],
    "Ghidra BTIGhidra": [".exe", ".dll", ".elf", ".bin", ".so"],
    "Ghidra Cartographer": [".exe", ".dll", ".elf", ".bin", ".so"],
    "Ghidra GolangAnalyzerExtension": [".exe", ".elf"],
    "godap": [],
    "GoReSym": [".exe", ".elf"],
    "gron": [".json"],
    "h2database": [".h2.db"],
    "hayabusa": [".evtx"],
    "HindSight": [".db", ".sqlite"],
    "HollowsHunter": [".exe", ".dll", ".dmp"],
    "Iaito": [".exe", ".dll", ".elf", ".bin", ".so"],
    "iLEAPP": [".tar", ".zip"],
    "ImHex": [".exe", ".dll", ".bin", ".hex", ".elf"],
    "INDXRipper": [".bin"],
    "jadx": [".apk", ".dex", ".jar", ".class", ".zip"],
    "jd-gui": [".class", ".jar"],
    "jq": [".json"],
    "Jumplist Browser": [".automaticDestinations-ms", ".customDestinations-ms"],
    "jwt-cli": [],
    "lessmsi": [".msi"],
    "LogBoost": [".evtx", ".csv", ".json"],
    "Loki": [".exe", ".dll", ".bin"],
    "mboxviewer": [".mbox", ".eml"],
    "MemProcFS": [".dmp", ".raw", ".vmem", ".img"],
    "MetadataPlus": [".exe", ".dll", ".doc", ".docx", ".xls", ".xlsx", ".pdf", ".jpg", ".png"],
    "MFTBrowser": [".mft"],
    "mmdbinspect": [".mmdb"],
    "MsgViewer": [".msg"],
    "Nerd Fonts": [".ttf", ".otf"],
    "NetExt": [".dmp"],
    "Notepad++": [".txt", ".log", ".xml", ".json", ".csv", ".ps1", ".py", ".js"],
    "PE-bear": [".exe", ".dll", ".sys"],
    "PE-sieve": [".exe", ".dll"],
    "PE-utils": [".exe", ".dll", ".sys"],
    "PowerShell": [".ps1", ".psm1", ".psd1"],
    "Prefetch Browser": [".pf"],
    "qpdf": [".pdf"],
    "qrtool": [".png", ".svg"],
    "Radare2": [".exe", ".dll", ".elf", ".bin", ".so", ".mach-o"],
    "RDPCacheStitcher": [".bmc", ".bin"],
    "readpe": [".exe", ".dll", ".sys"],
    "Recaf": [".class", ".jar"],
    "redress": [".exe", ".elf"],
    "ripgrep": [],
    "sidr": [".db", ".sqlite"],
    "Sleuthkit": [".dd", ".raw", ".E01", ".img", ".vmdk"],
    "srum_dump": [".dat"],
    "Strawberry Perl": [".pl", ".pm"],
    "takajo": [".json"],
    "Templater": [],
    "Thumbcacheviewer": [".db"],
    "upx": [".exe", ".dll", ".elf"],
    "Velociraptor": [".json", ".csv"],
    "VS Code PowerShell Extension": [".ps1", ".psm1", ".psd1"],
    "VS Code Spell Checker": [],
    "Witr": [],
    "WinObjEx64": [],
    "x64dbg": [".exe", ".dll"],
    "XELFViewer": [".elf", ".mach-o"],
    "YAMAGoya": [".yar", ".yara"],
    "YARA": [".yar", ".yara", ".exe", ".dll", ".bin"],
    "yara-x": [".yar", ".yara", ".exe", ".dll", ".bin"],
    "yq": [".yaml", ".yml", ".json", ".xml", ".toml"],
    "zaproxy": [],
    "Zircolite": [".evtx", ".json"],
    "Zui": [".pcap", ".pcapng", ".zng"],
    # obsidian plugins
    "admonitions": [],
    "obsidian-calendar-plugin": [],
    "obsidian-dataview": [],
    "obsidian-excalidraw-plugin": [],
    "obsidian-kanban": [],
    "obsidian-mitre-attack": [],
    "obsidian-tasks": [],
    "obsidian-timeline": [],
    # --- winget.ps1 tools ---
    "Autopsy": [".dd", ".raw", ".E01", ".img", ".vmdk"],
    "Burp Suite": [],
    "Chrome": [".html", ".htm", ".js", ".css"],
    "Docker Desktop": [],
    "DotNet 6 Desktop Runtime": [],
    "DotNet 8 Desktop Runtime": [],
    "Firefox": [".html", ".htm", ".js", ".css"],
    "Foxit PDF Reader": [".pdf"],
    "Google Earth Pro": [".kml", ".kmz"],
    "IrfanView": [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".ico", ".webp"],
    "obsidian": [".md"],
    "oh-my-posh": [],
    "OpenVPN": [".ovpn"],
    "OSFMount": [".dd", ".raw", ".E01", ".img", ".vmdk", ".iso"],
    "PowerShell 7": [".ps1", ".psm1", ".psd1"],
    "PuTTY": [],
    "QEMU": [".qcow2", ".vmdk", ".vdi", ".img", ".iso"],
    "Ruby": [".rb"],
    "Tailscale": [],
    "uv": [".py"],
    "VLC": [".mp4", ".avi", ".mkv", ".mov", ".mp3", ".wav", ".flac"],
    "VirusTotal CLI": [],
    "WinDbg": [".dmp", ".exe", ".dll", ".sys"],
    "WinMerge": [],
    "WireGuard": [],
    "Wireshark": [".pcap", ".pcapng", ".cap"],
    # --- python.ps1 tools ---
    "dfir_ntfs": [".mft", ".dd", ".raw", ".img"],
    "binary-refinery": [".exe", ".dll", ".bin"],
    "regipy": [".reg", ".dat"],
    "peepdf-3": [".pdf"],
    "mkdocs": [".md", ".yml"],
    "XLMMacroDeobfuscator": [".xls", ".xlsm", ".xlsb"],
    "jsbeautifier": [".js"],
    "chepy": [".bin", ".txt", ".hex"],
    "name-that-hash": [],
    "ppdeep": [],
    "pycryptodome": [],
    "lief": [".exe", ".dll", ".elf", ".mach-o"],
    "pefile": [".exe", ".dll", ".sys"],
    "peutils": [".exe", ".dll"],
    "pfp": [".bin"],
    "maldump": [".dmp"],
    "Aspose.Email-for-Python-via-Net": [".msg", ".eml", ".pst", ".ost", ".mbox"],
    "autoit-ripper": [".exe"],
    "cabarchive": [".cab"],
    "compressed_rtf": [".rtf"],
    "docx2txt": [".docx"],
    "extract-msg": [".msg"],
    "flattenJSON": [".json"],
    "hachoir": [".exe", ".dll", ".png", ".jpg", ".zip", ".tar", ".gz"],
    "magika": [],
    "msoffcrypto-tool": [".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx"],
    "olefile": [".doc", ".xls", ".ppt", ".msg"],
    "oletools": [".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".rtf"],
    "openpyxl": [".xlsx"],
    "pcode2code": [".doc", ".xls", ".ppt"],
    "pdfalyzer": [".pdf"],
    "protodeep": [".bin"],
    "pyOneNote": [".one"],
    "python-docx": [".docx"],
    "xlrd": [".xls"],
    "XlsxWriter": [".xlsx"],
    "evtx": [".evtx"],
    "python-registry": [".reg", ".dat"],
    "aiodns": [],
    "aiohttp": [],
    "dnslib": [],
    "dpkt": [".pcap", ".pcapng"],
    "geoip2": [".mmdb"],
    "maclookup": [],
    "netaddr": [],
    "paramiko": [],
    "pycares": [],
    "pydivert": [".pcap"],
    "pyshark": [".pcap", ".pcapng"],
    "PySocks": [],
    "scapy": [".pcap", ".pcapng"],
    "frida-tools": [".exe", ".apk", ".ipa"],
    "ghidrecomp": [".exe", ".dll", ".elf"],
    "ghidriff": [".exe", ".dll", ".elf"],
    "keystone-engine": [],
    "pyghidra": [".exe", ".dll", ".elf"],
    "rzpipe": [".exe", ".dll", ".elf", ".bin"],
    "unicorn": [],
    "csvkit": [".csv"],
    "mwcp": [".exe", ".dll", ".bin"],
    "malwarebazaar": [],
    "mkyara": [".exe", ".dll", ".bin"],
    "sigma-cli": [".yml", ".yaml"],
    "pysigma-backend-elasticsearch": [".yml", ".yaml"],
    "pySigma-backend-loki": [".yml", ".yaml"],
    "pysigma-backend-splunk": [".yml", ".yaml"],
    "pysigma-backend-sqlite": [".yml", ".yaml"],
    "pysigma-pipeline-sysmon": [".yml", ".yaml"],
    "pysigma-pipeline-windows": [".yml", ".yaml"],
    "shodan": [],
    "yara-python": [".yar", ".yara"],
    "BeautifulSoup4": [".html", ".htm", ".xml"],
    "deep_translator": [],
    "dfir-unfurl": [],
    "graphviz": [".dot", ".gv"],
    "grip": [".md"],
    "hexdump": [".bin"],
    "jpterm": [".json"],
    "jupyterlab": [".ipynb"],
    "LnkParse3": [".lnk"],
    "markitdown": [".docx", ".xlsx", ".pptx", ".pdf", ".html"],
    "matplotlib": [],
    "minidump": [".dmp"],
    "networkx": [],
    "numpy": [],
    "orjson": [".json"],
    "prettytable": [],
    "ptpython": [".py"],
    "pwncat": [],
    "pypdf": [".pdf"],
    "pypng": [".png"],
    "pyvis": [],
    "pyzipper": [".zip"],
    "requests": [],
    "rexi": [],
    "simplejson": [".json"],
    "termcolor": [],
    "textsearch": [],
    "time-decode": [],
    "tomlkit": [".toml"],
    "toolong": [".log", ".txt"],
    "treelib": [],
    "unpy2exe": [".exe"],
    "visidata": [".csv", ".tsv", ".json", ".sqlite", ".xlsx"],
    "xxhash": [],
    "bitstruct": [],
    "dotnetfile": [".exe", ".dll"],
    "stego-lsb": [".png", ".bmp", ".wav"],
    "acquire": [".tar"],
    "dissect": [".dd", ".raw", ".tar"],
    "dissect.target": [".dd", ".raw", ".tar", ".vmdk", ".E01"],
    "flow.record": [".rec"],
    "msticpy": [".json", ".csv"],
    "pathlab": [],
    "elasticsearch": [],
    "litecli": [".db", ".sqlite"],
    "neo4j": [],
    "sqlit-tui": [".db", ".sqlite", ".sqlite3"],
    # --- go.ps1 tools ---
    "protodump": [".exe", ".dll", ".elf", ".bin"],
    # --- node.ps1 tools ---
    "box-js": [".js"],
    "deobfuscator": [".js"],
    "docsify-cli": [".md", ".html"],
    "jsdom": [".html", ".htm", ".js"],
    "LUMEN": [".evtx"],
    # --- rust.ps1 tools ---
    "dfir-toolkit": [".evtx", ".reg", ".dat", ".lnk", ".pf", ".mft", ".zip"],
    "usnjrnl": [".bin"],
    "mft2bodyfile": [".mft"],
    "CuTE-tui": [],
    "SSHniff": [".pcap", ".pcapng"],
    # --- msys2.ps1 tools ---
    "MSYS2": [],
}

# ---------------------------------------------------------------------------
# Tags mapping  (keys are tool names as in $TOOL_DEFINITIONS)
# Values are lists of tag strings.
# ---------------------------------------------------------------------------

TAGS_MAP: Dict[str, List[str]] = {
    # --- release.ps1 tools ---
    "4n4lDetector": ["malware-analysis", "pe-analysis", "detection"],
    "adalanche": ["active-directory", "attack-path", "visualization"],
    "aLEAPP": ["mobile-forensics", "android", "artifact-extraction"],
    "Ares": ["malware-analysis", "pe-analysis"],
    "artemis": ["forensics", "artifact-extraction", "triage"],
    "Audacity": ["audio", "multimedia", "steganography"],
    "BeaconHunter": ["malware-analysis", "cobalt-strike", "memory-forensics"],
    "binary-refinery": ["malware-analysis", "deobfuscation", "data-extraction", "scripting"],
    "binlex": ["malware-analysis", "binary-analysis", "similarity"],
    "bytecode-viewer": ["reverse-engineering", "java", "decompiler", "deobfuscation"],
    "cart": ["malware-analysis", "packaging"],
    "chainsaw": ["log-analysis", "incident-response", "sigma", "detection"],
    "cmder": ["terminal", "shell"],
    "CobaltStrikeScan": ["malware-analysis", "cobalt-strike", "detection"],
    "ComparePlus": ["text-editor", "diff"],
    "Cutter": ["reverse-engineering", "disassembler", "decompiler"],
    "CyberChef": ["data-processing", "encoding", "decoding", "deobfuscation", "encryption", "hashing"],
    "DB Browser for SQLite": ["database", "sqlite", "gui"],
    "DBeaver": ["database", "gui"],
    "dbSpy": ["database", "sqlite", "visualization"],
    "debloat": ["malware-analysis", "pe-analysis", "deobfuscation"],
    "Detect It Easy": ["pe-analysis", "file-identification", "packer-detection"],
    "DitExplorer": ["active-directory", "forensics"],
    "dll_to_exe": ["pe-analysis", "conversion"],
    "Dokany": ["filesystem", "mounting"],
    "DSpellCheck": ["text-editor"],
    "dsq": ["data-processing", "sql", "json", "csv"],
    "Dumpbin": ["pe-analysis", "reverse-engineering"],
    "edit": ["text-editor"],
    "Elfparser-ng": ["reverse-engineering", "elf-analysis", "linux"],
    "evtx_dump": ["log-analysis", "event-log", "windows"],
    "ffmpeg": ["multimedia", "video", "audio", "conversion"],
    "Fibratus": ["etw", "windows", "monitoring"],
    "Flare-Fakenet-NG": ["malware-analysis", "network-simulation", "dynamic-analysis"],
    "Flare-Floss": ["malware-analysis", "string-extraction", "deobfuscation"],
    "forensic-timeliner": ["forensics", "timeline"],
    "fq": ["data-processing", "binary-analysis", "file-format"],
    "fqlite": ["database", "sqlite", "forensics"],
    "fx": ["json", "data-processing", "visualization"],
    "gftrace": ["reverse-engineering", "api-tracing", "golang"],
    "Ghidra BTIGhidra": ["reverse-engineering", "disassembler", "decompiler"],
    "Ghidra Cartographer": ["reverse-engineering", "disassembler", "visualization"],
    "Ghidra GolangAnalyzerExtension": ["reverse-engineering", "golang"],
    "godap": ["active-directory", "ldap"],
    "GoReSym": ["reverse-engineering", "golang", "symbol-recovery"],
    "gron": ["json", "data-processing", "grep"],
    "h2database": ["database", "java"],
    "hayabusa": ["log-analysis", "event-log", "sigma", "detection", "timeline", "incident-response"],
    "HindSight": ["browser-forensics", "chrome", "artifact-extraction"],
    "HollowsHunter": ["malware-analysis", "pe-analysis", "process-injection"],
    "Iaito": ["reverse-engineering", "disassembler", "gui"],
    "iLEAPP": ["mobile-forensics", "ios", "artifact-extraction"],
    "ImHex": ["hex-editor", "binary-analysis", "pattern-language"],
    "INDXRipper": ["ntfs", "filesystem", "forensics"],
    "jadx": ["reverse-engineering", "android", "decompiler", "java", "deobfuscation"],
    "jd-gui": ["reverse-engineering", "java", "decompiler"],
    "jq": ["json", "data-processing", "cli"],
    "Jumplist Browser": ["windows", "forensics", "artifact-extraction"],
    "jwt-cli": ["web", "authentication", "jwt"],
    "lessmsi": ["windows", "installer"],
    "LogBoost": ["log-analysis", "event-log"],
    "Loki": ["malware-analysis", "ioc-scanner", "yara", "detection"],
    "mboxviewer": ["email", "forensics"],
    "MemProcFS": ["memory-forensics", "filesystem"],
    "MetadataPlus": ["metadata", "file-analysis"],
    "MFTBrowser": ["ntfs", "filesystem", "forensics"],
    "mmdbinspect": ["geolocation", "maxmind"],
    "MsgViewer": ["email", "forensics", "outlook"],
    "Nerd Fonts": ["fonts", "terminal"],
    "NetExt": ["debugging", "memory-forensics", "dotnet"],
    "Notepad++": ["text-editor", "syntax-highlighting"],
    "PE-bear": ["pe-analysis", "reverse-engineering"],
    "PE-sieve": ["pe-analysis", "malware-analysis", "process-injection"],
    "PE-utils": ["pe-analysis", "reverse-engineering"],
    "PowerShell": ["scripting", "shell", "automation"],
    "Prefetch Browser": ["windows", "forensics", "prefetch"],
    "qpdf": ["pdf", "data-processing"],
    "qrtool": ["qr-code", "encoding", "decoding"],
    "Radare2": ["reverse-engineering", "disassembler", "debugging"],
    "RDPCacheStitcher": ["rdp", "forensics", "windows"],
    "readpe": ["pe-analysis", "reverse-engineering"],
    "Recaf": ["reverse-engineering", "java", "decompiler", "deobfuscation"],
    "redress": ["reverse-engineering", "golang"],
    "ripgrep": ["search", "grep", "cli"],
    "sidr": ["browser-forensics", "forensics"],
    "Sleuthkit": ["disk-forensics", "filesystem", "forensics"],
    "srum_dump": ["windows", "forensics", "srum"],
    "Strawberry Perl": ["scripting", "perl"],
    "takajo": ["log-analysis", "hayabusa", "timeline"],
    "Templater": ["obsidian", "automation"],
    "Thumbcacheviewer": ["windows", "forensics", "thumbnails"],
    "upx": ["packing", "pe-analysis", "compression"],
    "Velociraptor": ["incident-response", "forensics", "endpoint-detection"],
    "VS Code PowerShell Extension": ["text-editor", "powershell"],
    "VS Code Spell Checker": ["text-editor"],
    "Witr": ["forensics", "triage"],
    "WinObjEx64": ["windows", "kernel", "debugging"],
    "x64dbg": ["reverse-engineering", "debugging", "dynamic-analysis"],
    "XELFViewer": ["reverse-engineering", "elf-analysis"],
    "YAMAGoya": ["yara", "rule-generation"],
    "YARA": ["yara", "malware-analysis", "detection", "signatures"],
    "yara-x": ["yara", "malware-analysis", "detection", "signatures"],
    "yq": ["yaml", "data-processing", "cli"],
    "zaproxy": ["web", "security-testing", "proxy"],
    "Zircolite": ["log-analysis", "sigma", "detection", "incident-response"],
    "Zui": ["network-analysis", "pcap", "zeek"],
    # obsidian plugins
    "admonitions": ["obsidian"],
    "obsidian-calendar-plugin": ["obsidian"],
    "obsidian-dataview": ["obsidian", "data-processing"],
    "obsidian-excalidraw-plugin": ["obsidian", "drawing"],
    "obsidian-kanban": ["obsidian", "project-management"],
    "obsidian-mitre-attack": ["obsidian", "mitre-attack", "threat-intelligence"],
    "obsidian-tasks": ["obsidian", "task-management"],
    "obsidian-timeline": ["obsidian", "timeline"],
    # --- winget.ps1 tools ---
    "Autopsy": ["disk-forensics", "forensics", "gui", "artifact-extraction"],
    "Burp Suite": ["web", "security-testing", "proxy"],
    "Chrome": ["browser", "web"],
    "Docker Desktop": ["containers", "virtualization"],
    "DotNet 6 Desktop Runtime": ["dotnet", "runtime"],
    "DotNet 8 Desktop Runtime": ["dotnet", "runtime"],
    "Firefox": ["browser", "web"],
    "Foxit PDF Reader": ["pdf", "viewer"],
    "Google Earth Pro": ["geolocation", "osint", "visualization"],
    "IrfanView": ["image-viewer", "multimedia"],
    "obsidian": ["note-taking", "markdown", "documentation"],
    "oh-my-posh": ["terminal", "shell", "theming"],
    "OpenVPN": ["vpn", "network"],
    "OSFMount": ["disk-forensics", "mounting", "filesystem"],
    "PowerShell 7": ["scripting", "shell", "automation"],
    "PuTTY": ["ssh", "network", "terminal"],
    "QEMU": ["virtualization", "emulation"],
    "Ruby": ["scripting", "ruby"],
    "Tailscale": ["vpn", "network"],
    "uv": ["python", "package-management"],
    "VLC": ["multimedia", "video", "audio"],
    "VirusTotal CLI": ["malware-analysis", "threat-intelligence", "ioc-scanner"],
    "WinDbg": ["debugging", "memory-forensics", "kernel"],
    "WinMerge": ["diff", "file-comparison"],
    "WireGuard": ["vpn", "network"],
    "Wireshark": ["network-analysis", "pcap", "protocol-analysis"],
    # --- python.ps1 tools ---
    "dfir_ntfs": ["ntfs", "filesystem", "forensics", "disk-forensics"],
    "regipy": ["registry", "windows", "forensics"],
    "peepdf-3": ["pdf", "malware-analysis", "javascript"],
    "mkdocs": ["documentation", "markdown"],
    "XLMMacroDeobfuscator": ["office", "macro", "deobfuscation", "malware-analysis"],
    "jsbeautifier": ["javascript", "deobfuscation", "beautifier"],
    "chepy": ["data-processing", "encoding", "decoding", "deobfuscation", "hashing"],
    "name-that-hash": ["hashing", "identification"],
    "ppdeep": ["hashing", "fuzzy-hashing", "similarity"],
    "pycryptodome": ["encryption", "cryptography"],
    "lief": ["pe-analysis", "elf-analysis", "binary-analysis"],
    "pefile": ["pe-analysis", "reverse-engineering"],
    "peutils": ["pe-analysis", "packer-detection"],
    "pfp": ["binary-analysis", "file-format"],
    "maldump": ["malware-analysis", "memory-forensics"],
    "Aspose.Email-for-Python-via-Net": ["email", "forensics", "data-extraction"],
    "autoit-ripper": ["malware-analysis", "autoit", "deobfuscation"],
    "cabarchive": ["archive", "data-extraction"],
    "compressed_rtf": ["office", "rtf", "data-extraction"],
    "docx2txt": ["office", "word", "data-extraction"],
    "extract-msg": ["email", "outlook", "data-extraction"],
    "flattenJSON": ["json", "data-processing"],
    "hachoir": ["binary-analysis", "metadata", "file-format"],
    "magika": ["file-identification", "machine-learning"],
    "msoffcrypto-tool": ["office", "encryption", "decryption"],
    "olefile": ["office", "ole", "data-extraction"],
    "oletools": ["office", "macro", "malware-analysis", "vba"],
    "openpyxl": ["office", "excel", "data-extraction"],
    "pcode2code": ["office", "vba", "decompiler"],
    "pdfalyzer": ["pdf", "malware-analysis", "visualization"],
    "protodeep": ["protobuf", "reverse-engineering"],
    "pyOneNote": ["office", "onenote", "data-extraction"],
    "python-docx": ["office", "word", "data-extraction"],
    "xlrd": ["office", "excel", "data-extraction"],
    "XlsxWriter": ["office", "excel"],
    "evtx": ["log-analysis", "event-log", "windows"],
    "python-registry": ["registry", "windows", "forensics"],
    "aiodns": ["network", "dns"],
    "aiohttp": ["network", "http"],
    "dnslib": ["network", "dns"],
    "dpkt": ["network-analysis", "pcap", "protocol-analysis"],
    "geoip2": ["geolocation", "network", "maxmind"],
    "maclookup": ["network", "mac-address"],
    "netaddr": ["network", "ip-address"],
    "paramiko": ["network", "ssh", "scripting"],
    "pycares": ["network", "dns"],
    "pydivert": ["network", "packet-capture"],
    "pyshark": ["network-analysis", "pcap", "protocol-analysis"],
    "PySocks": ["network", "proxy"],
    "scapy": ["network-analysis", "pcap", "packet-crafting"],
    "frida-tools": ["reverse-engineering", "dynamic-analysis", "instrumentation"],
    "ghidrecomp": ["reverse-engineering", "decompiler"],
    "ghidriff": ["reverse-engineering", "binary-diffing"],
    "keystone-engine": ["reverse-engineering", "assembler"],
    "pyghidra": ["reverse-engineering", "decompiler", "scripting"],
    "rzpipe": ["reverse-engineering", "radare2", "scripting"],
    "unicorn": ["reverse-engineering", "emulation"],
    "csvkit": ["csv", "data-processing", "cli"],
    "mwcp": ["malware-analysis", "configuration-extraction"],
    "malwarebazaar": ["malware-analysis", "threat-intelligence", "ioc-scanner"],
    "mkyara": ["yara", "rule-generation", "malware-analysis"],
    "sigma-cli": ["sigma", "detection", "log-analysis"],
    "pysigma-backend-elasticsearch": ["sigma", "detection", "elasticsearch"],
    "pySigma-backend-loki": ["sigma", "detection", "loki"],
    "pysigma-backend-splunk": ["sigma", "detection", "splunk"],
    "pysigma-backend-sqlite": ["sigma", "detection", "sqlite"],
    "pysigma-pipeline-sysmon": ["sigma", "detection", "sysmon"],
    "pysigma-pipeline-windows": ["sigma", "detection", "windows"],
    "shodan": ["osint", "network", "reconnaissance"],
    "yara-python": ["yara", "malware-analysis", "detection"],
    "BeautifulSoup4": ["web", "html-parsing", "scraping"],
    "deep_translator": ["translation", "text-processing"],
    "dfir-unfurl": ["url-analysis", "forensics", "visualization"],
    "graphviz": ["visualization", "graph"],
    "grip": ["markdown", "preview"],
    "hexdump": ["hex-editor", "binary-analysis"],
    "jpterm": ["json", "data-processing", "tui"],
    "jupyterlab": ["python", "notebook", "data-analysis"],
    "LnkParse3": ["windows", "forensics", "shortcut-analysis"],
    "markitdown": ["conversion", "markdown", "data-extraction"],
    "matplotlib": ["visualization", "plotting"],
    "minidump": ["memory-forensics", "windows"],
    "networkx": ["visualization", "graph"],
    "numpy": ["data-analysis", "scientific-computing"],
    "orjson": ["json", "data-processing"],
    "prettytable": ["data-processing", "formatting"],
    "ptpython": ["python", "repl"],
    "pwncat": ["exploitation", "post-exploitation"],
    "pypdf": ["pdf", "data-extraction"],
    "pypng": ["image", "steganography"],
    "pyvis": ["visualization", "graph"],
    "pyzipper": ["archive", "encryption"],
    "requests": ["network", "http"],
    "rexi": ["regex", "data-processing", "tui"],
    "simplejson": ["json", "data-processing"],
    "termcolor": ["terminal", "formatting"],
    "textsearch": ["text-processing", "search"],
    "time-decode": ["timestamp", "forensics", "decoding"],
    "tomlkit": ["toml", "data-processing"],
    "toolong": ["log-analysis", "tui"],
    "treelib": ["data-processing", "tree"],
    "unpy2exe": ["reverse-engineering", "python", "decompiler"],
    "visidata": ["data-processing", "tui", "csv"],
    "xxhash": ["hashing"],
    "bitstruct": ["binary-analysis", "data-processing"],
    "dotnetfile": ["pe-analysis", "dotnet"],
    "stego-lsb": ["steganography", "image", "audio"],
    "acquire": ["forensics", "incident-response", "disk-imaging"],
    "dissect": ["forensics", "incident-response", "data-extraction"],
    "dissect.target": ["forensics", "incident-response", "artifact-extraction"],
    "flow.record": ["forensics", "data-processing"],
    "msticpy": ["threat-intelligence", "incident-response", "jupyter"],
    "pathlab": ["forensics", "filesystem"],
    "elasticsearch": ["database", "elasticsearch", "siem"],
    "litecli": ["database", "sqlite", "cli"],
    "neo4j": ["database", "graph"],
    "sqlit-tui": ["database", "sqlite", "tui"],
    # --- go.ps1 tools ---
    "protodump": ["reverse-engineering", "protobuf", "binary-analysis", "data-extraction"],
    # --- node.ps1 tools ---
    "box-js": ["malware-analysis", "javascript", "dynamic-analysis", "deobfuscation"],
    "deobfuscator": ["javascript", "deobfuscation", "malware-analysis"],
    "docsify-cli": ["documentation", "markdown"],
    "jsdom": ["javascript", "html-parsing", "dom"],
    "LUMEN": ["log-analysis", "event-log", "forensics", "visualization"],
    # --- rust.ps1 tools ---
    "dfir-toolkit": ["forensics", "timeline", "log-analysis", "event-log", "registry", "bodyfile"],
    "usnjrnl": ["filesystem", "forensics", "ntfs", "windows"],
    "mft2bodyfile": ["filesystem", "forensics", "ntfs", "bodyfile"],
    "CuTE-tui": ["tui", "http", "network"],
    "SSHniff": ["network-analysis", "ssh", "pcap"],
    # --- msys2.ps1 tools ---
    "MSYS2": ["build-environment", "shell", "linux-tools", "gcc", "debugging"],
    # --- http.ps1 tools ---
    "Visual Studio Code": ["text-editor", "ide", "powershell"],
    "Sysinternals Suite": ["windows", "debugging", "monitoring", "system-administration"],
    "ExifTool": ["metadata", "file-analysis", "image"],
    "pestudio": ["pe-analysis", "malware-analysis", "static-analysis"],
    "HxD": ["hex-editor", "binary-analysis"],
    "TrID": ["file-identification"],
    "Malcat Lite": ["pe-analysis", "malware-analysis", "hex-editor", "disassembler"],
    "MiTeC Structured Storage Viewer": ["office", "ole", "data-extraction"],
    "FullEventLogView": ["log-analysis", "event-log", "windows"],
    "PST Walker": ["email", "forensics", "outlook"],
    "Win API Search": ["reverse-engineering", "windows", "api"],
    "PDFStreamDumper": ["pdf", "malware-analysis", "javascript"],
    "Mail Viewer": ["email", "forensics"],
    "Volatility Workbench 3": ["memory-forensics", "gui"],
    "Volatility Workbench 2.1": ["memory-forensics", "gui"],
    "NirSoft Browser Utilities": ["browser-forensics", "artifact-extraction"],
    "winpmem": ["memory-forensics", "acquisition"],
    "Binary Ninja": ["reverse-engineering", "disassembler", "decompiler"],
    "Gpg4win": ["encryption", "pgp", "signing"],
    "Tor Browser": ["browser", "privacy", "network"],
    "DCode": ["timestamp", "forensics", "decoding"],
    "VeraCrypt": ["encryption", "disk-encryption"],
    "Neo4j": ["database", "graph", "visualization"],
    "recbin": ["binary-analysis", "carving"],
    "capa Explorer Web": ["malware-analysis", "capability-analysis", "visualization"],
    "LibreOffice": ["office", "document-viewer"],
    "Npcap": ["network-analysis", "packet-capture"],
    "SQLite Tools": ["database", "sqlite", "cli"],
    "OpenVPN Connect": ["vpn", "network"],
    "bulk_extractor": ["forensics", "carving", "data-extraction"],
    "DensityScout": ["malware-analysis", "entropy-analysis"],
    "Nmap": ["network-analysis", "port-scanning", "reconnaissance"],
    "FASM": ["reverse-engineering", "assembler"],
    "Windows Terminal (Canary)": ["terminal", "shell"],
    "ProcDOT": ["malware-analysis", "visualization", "dynamic-analysis"],
    "geolocus-cli": ["geolocation", "osint"],
    "Graphviz": ["visualization", "graph"],
    "API Monitor": ["reverse-engineering", "api-tracing", "dynamic-analysis"],
    "JavaFX SDK": ["java", "gui", "runtime"],
    "apktool": ["reverse-engineering", "android", "decompiler"],
    "PHP": ["scripting", "web"],
    "hashcat": ["password-cracking", "hashing"],
    "vmss2core": ["memory-forensics", "vmware", "conversion"],
    "MEX": ["debugging", "windbg", "dotnet"],
    "Elastic Stack (ELK + Beats)": ["siem", "log-analysis", "elasticsearch", "visualization"],
}

# Add http.ps1 tools to FILE_EXTENSIONS_MAP
FILE_EXTENSIONS_MAP.update({
    "Visual Studio Code": [".ps1", ".py", ".js", ".ts", ".json", ".xml", ".yaml", ".md"],
    "Sysinternals Suite": [".exe", ".dll", ".sys"],
    "ExifTool": [".jpg", ".jpeg", ".png", ".gif", ".tiff", ".pdf", ".doc", ".docx", ".mp4"],
    "pestudio": [".exe", ".dll", ".sys"],
    "HxD": [".exe", ".dll", ".bin", ".hex"],
    "TrID": [],
    "Malcat Lite": [".exe", ".dll", ".elf", ".bin", ".sys"],
    "MiTeC Structured Storage Viewer": [".doc", ".xls", ".ppt", ".msg"],
    "FullEventLogView": [".evtx"],
    "PST Walker": [".pst"],
    "Win API Search": [],
    "PDFStreamDumper": [".pdf"],
    "Mail Viewer": [".eml", ".msg"],
    "Volatility Workbench 3": [".dmp", ".raw", ".vmem", ".img"],
    "Volatility Workbench 2.1": [".dmp", ".raw", ".vmem", ".img"],
    "NirSoft Browser Utilities": [".db", ".sqlite"],
    "winpmem": [".raw", ".aff4"],
    "Binary Ninja": [".exe", ".dll", ".elf", ".bin", ".so", ".dylib"],
    "Gpg4win": [".gpg", ".asc", ".pgp"],
    "Tor Browser": [".html", ".htm"],
    "DCode": [],
    "VeraCrypt": [".hc", ".tc"],
    "Neo4j": [],
    "recbin": [".bin"],
    "capa Explorer Web": [".exe", ".dll"],
    "LibreOffice": [".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".odt", ".ods", ".odp"],
    "Npcap": [".pcap", ".pcapng"],
    "SQLite Tools": [".db", ".sqlite", ".sqlite3"],
    "OpenVPN Connect": [".ovpn"],
    "bulk_extractor": [".dd", ".raw", ".E01", ".img"],
    "DensityScout": [".exe", ".dll", ".bin"],
    "Nmap": [],
    "FASM": [".asm"],
    "Windows Terminal (Canary)": [],
    "ProcDOT": [".csv", ".log"],
    "geolocus-cli": [".json"],
    "Graphviz": [".dot", ".gv"],
    "API Monitor": [".exe", ".dll"],
    "JavaFX SDK": [".jar"],
    "apktool": [".apk"],
    "PHP": [".php"],
    "hashcat": [],
    "vmss2core": [".vmss", ".vmsn"],
    "MEX": [".dmp"],
    "Elastic Stack (ELK + Beats)": [".json", ".log"],
})


# ---------------------------------------------------------------------------
# Formatting helpers – generate PowerShell hashtable array syntax
# ---------------------------------------------------------------------------

def format_verify_block(verify_items: List[dict], indent: str = "    ") -> str:
    """Format verify items as PowerShell @( @{...} ) block.

    Each item is a dict with keys: Name, Expect.
    """
    if not verify_items:
        return "@()"
    lines = ["@("]
    for v in verify_items:
        lines.append(f"{indent}    @{{")
        lines.append(f'{indent}        Type = "command"')
        lines.append(f'{indent}        Name = "{v["Name"]}"')
        lines.append(f'{indent}        Expect = "{v["Expect"]}"')
        lines.append(f"{indent}    }}")
    lines.append(f"{indent})")
    return "\n".join(lines)


def format_shortcuts_block(
    shortcut_items: List[dict], indent: str = "    "
) -> str:
    """Format shortcut items as PowerShell @( @{...} ) block.

    Each item is a dict with keys: lnk, target, args, icon, workdir.
    Values are backtick-escaped for use in tool definitions.
    """
    if not shortcut_items:
        return "@()"
    lines = ["@("]
    for s in shortcut_items:
        lnk = escape_ps_vars(s["lnk"])
        target = escape_ps_vars(s["target"])
        args = escape_ps_vars(s["args"])
        icon = escape_ps_vars(s["icon"])
        workdir = escape_ps_vars(s["workdir"])
        lines.append(f"{indent}    @{{")
        lines.append(f'{indent}        Lnk      = "{lnk}"')
        lines.append(f'{indent}        Target   = "{target}"')
        lines.append(f'{indent}        Args     = "{args}"')
        lines.append(f'{indent}        Icon     = "{icon}"')
        lines.append(f'{indent}        WorkDir  = "{workdir}"')
        lines.append(f"{indent}    }}")
    lines.append(f"{indent})")
    return "\n".join(lines)


def format_ps_string_array(items: List[str]) -> str:
    """Format a list of strings as PowerShell @("a", "b") syntax."""
    if not items:
        return "@()"
    quoted = ", ".join(f'"{item}"' for item in items)
    return f"@({quoted})"


# ---------------------------------------------------------------------------
# Resolve data for a tool definition
# ---------------------------------------------------------------------------

def resolve_verify(
    name: str, verify_index: Dict[str, List[dict]]
) -> List[dict]:
    """Resolve verify entries for a tool: override first, then auto-match."""
    override_strings = VERIFY_OVERRIDES.get(name)
    if override_strings is not None:
        return [parse_verify_string(s) for s in override_strings]
    norm = normalize(name)
    return verify_index.get(norm, [])


def resolve_shortcuts(
    name: str, shortcut_index: Dict[Tuple[str, str], dict]
) -> List[dict]:
    """Resolve full shortcut data for a tool from SHORTCUT_OVERRIDES + parsed index."""
    override_keys = SHORTCUT_OVERRIDES.get(name)
    if override_keys is None:
        return []
    result = []
    for cat, sname in override_keys:
        data = shortcut_index.get((cat, sname))
        if data:
            result.append(data)
        else:
            # Shortcut not found in parsed data – create minimal entry
            lnk = f"${{HOME}}\\Desktop\\dfirws\\{cat}\\{sname}.lnk"
            result.append({
                "lnk": lnk,
                "target": "${CLI_TOOL}",
                "args": "",
                "icon": "",
                "workdir": "${HOME}\\Desktop",
            })
    return result


# ---------------------------------------------------------------------------
# Update definitions in a download script
# ---------------------------------------------------------------------------

def update_definitions_in_file(
    path: Path,
    stats: dict,
    verify_index: Dict[str, List[dict]],
    shortcut_index: Dict[Tuple[str, str], dict],
) -> None:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)

    result = []
    i = 0
    while i < len(lines):
        line = lines[i]

        if re.match(r"\s*\$TOOL_DEFINITIONS\s*\+=\s*@\{", line):
            block_lines = [line]
            i += 1
            brace_depth = 1
            while i < len(lines) and brace_depth > 0:
                block_lines.append(lines[i])
                brace_depth += lines[i].count("{") - lines[i].count("}")
                i += 1

            name_match = None
            for bl in block_lines:
                m = re.match(r'\s*Name\s*=\s*"([^"]+)"', bl)
                if m:
                    name_match = m.group(1)
                    break

            if name_match:
                category = CATEGORY_MAP.get(name_match, "")
                verify = resolve_verify(name_match, verify_index)
                install_cmd = ""
                if name_match in INSTALL_CMD_MAP:
                    install_cmd = f"dfirws-install.ps1 -{INSTALL_CMD_MAP[name_match]}"
                shortcuts = resolve_shortcuts(name_match, shortcut_index)
                file_exts = FILE_EXTENSIONS_MAP.get(name_match, [])
                tags = TAGS_MAP.get(name_match, [])

                fields_populated = 0
                if category:
                    fields_populated += 1
                if verify:
                    fields_populated += 1
                if install_cmd:
                    fields_populated += 1
                if shortcuts:
                    fields_populated += 1
                if file_exts:
                    fields_populated += 1
                if tags:
                    fields_populated += 1

                if fields_populated > 0:
                    stats["tools_with_data"] += 1
                    stats["fields_populated"] += fields_populated
                else:
                    stats["tools_without_data"] += 1

                verify_str = format_verify_block(verify)
                shortcuts_str = format_shortcuts_block(shortcuts)
                file_exts_str = format_ps_string_array(file_exts)
                tags_str = format_ps_string_array(tags)

                new_block = []
                new_block.append(f"$TOOL_DEFINITIONS += @{{\n")
                new_block.append(f'    Name = "{name_match}"\n')
                new_block.append(f'    Category = "{category}"\n')
                new_block.append(f"    Shortcuts = {shortcuts_str}\n")
                new_block.append(f'    InstallVerifyCommand = "{install_cmd}"\n')
                new_block.append(f"    Verify = {verify_str}\n")
                new_block.append(f"    FileExtensions = {file_exts_str}\n")
                new_block.append(f"    Tags = {tags_str}\n")
                new_block.append(f'    Notes = ""\n')
                new_block.append(f'    Tips = ""\n')
                new_block.append(f'    Usage = ""\n')
                new_block.append(f"    SampleCommands = @()\n")
                new_block.append(f"    SampleFiles = @()\n")
                new_block.append(f"}}\n")
                result.extend(new_block)
            else:
                result.extend(block_lines)
            continue

        result.append(line)
        i += 1

    path.write_text("".join(result), encoding="utf-8")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

HTTP_FILE = BASE_DIR / "resources" / "download" / "http.ps1"


def patch_tags_extensions(path: Path, stats: dict) -> None:
    """Patch only FileExtensions and Tags into existing tool definition blocks.

    Unlike update_definitions_in_file, this preserves all existing fields and
    only inserts/replaces FileExtensions and Tags lines.
    """
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)

    result = []
    i = 0
    while i < len(lines):
        line = lines[i]

        if re.match(r"\s*\$TOOL_DEFINITIONS\s*\+=\s*@\{", line):
            block_lines = [line]
            i += 1
            brace_depth = 1
            while i < len(lines) and brace_depth > 0:
                block_lines.append(lines[i])
                brace_depth += lines[i].count("{") - lines[i].count("}")
                i += 1

            name_match = None
            for bl in block_lines:
                m = re.match(r'\s*Name\s*=\s*"([^"]+)"', bl)
                if m:
                    name_match = m.group(1)
                    break

            if name_match:
                file_exts = FILE_EXTENSIONS_MAP.get(name_match, [])
                tags = TAGS_MAP.get(name_match, [])

                fields_populated = 0
                if file_exts:
                    fields_populated += 1
                if tags:
                    fields_populated += 1

                if fields_populated > 0:
                    stats["tools_with_data"] += 1
                    stats["fields_populated"] += fields_populated
                else:
                    stats["tools_without_data"] += 1

                file_exts_str = format_ps_string_array(file_exts)
                tags_str = format_ps_string_array(tags)

                # Remove existing FileExtensions/Tags lines
                filtered = []
                for bl in block_lines:
                    if not re.match(r"\s+FileExtensions\s*=", bl) and \
                       not re.match(r"\s+Tags\s*=", bl):
                        filtered.append(bl)

                # Insert before Notes at top-level depth (depth==1 means
                # inside the outer @{} but not inside nested structures).
                new_block = []
                inserted = False
                depth = 0
                for bl in filtered:
                    depth += bl.count("{") - bl.count("}")
                    # Insert at depth 1 before Notes, or at depth 0
                    # (closing brace of outer block)
                    if not inserted and (
                        (depth == 1 and re.match(r'\s+Notes\s*=', bl)) or
                        depth == 0
                    ):
                        new_block.append(f"    FileExtensions = {file_exts_str}\n")
                        new_block.append(f"    Tags = {tags_str}\n")
                        inserted = True
                    new_block.append(bl)
                result.extend(new_block)
            else:
                result.extend(block_lines)
            continue

        result.append(line)
        i += 1

    path.write_text("".join(result), encoding="utf-8")


def main() -> int:
    for p in [VERIFY_FILE, FOLDER_FILE, INSTALL_FILE]:
        if not p.exists():
            print(f"ERROR: {p} not found")
            return 1
    for p in DOWNLOAD_FILES:
        if not p.exists():
            print(f"ERROR: {p} not found")
            return 1

    verify_entries = parse_verify(VERIFY_FILE)
    verify_index = build_verify_index(verify_entries)
    shortcut_index = parse_shortcuts_full(FOLDER_FILE)
    install_params = parse_install_params(INSTALL_FILE)

    print(f"Parsed {len(verify_entries)} verify commands from install_verify.ps1")
    print(f"Parsed {len(shortcut_index)} shortcuts from dfirws_folder.ps1")
    print(f"Parsed {len(install_params)} install parameters from dfirws-install.ps1")
    print(f"Built verify index with {len(verify_index)} unique command names")
    print()

    print(f"Category mappings defined: {len(CATEGORY_MAP)}")
    print(f"Verify overrides defined: {len(VERIFY_OVERRIDES)}")
    print(f"Shortcut overrides defined: {len(SHORTCUT_OVERRIDES)}")
    print(f"Install command mappings defined: {len(INSTALL_CMD_MAP)}")
    print(f"File extension mappings defined: {len(FILE_EXTENSIONS_MAP)}")
    print(f"Tags mappings defined: {len(TAGS_MAP)}")
    print()

    total_stats = {"tools_with_data": 0, "tools_without_data": 0, "fields_populated": 0}

    for path in DOWNLOAD_FILES:
        file_stats = {"tools_with_data": 0, "tools_without_data": 0, "fields_populated": 0}
        print(f"Processing {path.name}...")
        update_definitions_in_file(path, file_stats, verify_index, shortcut_index)
        print(f"  Tools with data populated: {file_stats['tools_with_data']}")
        print(f"  Tools without data: {file_stats['tools_without_data']}")
        print(f"  Total fields populated: {file_stats['fields_populated']}")
        total_stats["tools_with_data"] += file_stats["tools_with_data"]
        total_stats["tools_without_data"] += file_stats["tools_without_data"]
        total_stats["fields_populated"] += file_stats["fields_populated"]

    # Patch FileExtensions and Tags into http.ps1 (preserves existing fields)
    if HTTP_FILE.exists():
        http_stats = {"tools_with_data": 0, "tools_without_data": 0, "fields_populated": 0}
        print(f"Patching {HTTP_FILE.name} (FileExtensions + Tags only)...")
        patch_tags_extensions(HTTP_FILE, http_stats)
        print(f"  Tools with data populated: {http_stats['tools_with_data']}")
        print(f"  Tools without data: {http_stats['tools_without_data']}")
        print(f"  Total fields populated: {http_stats['fields_populated']}")
        total_stats["tools_with_data"] += http_stats["tools_with_data"]
        total_stats["tools_without_data"] += http_stats["tools_without_data"]
        total_stats["fields_populated"] += http_stats["fields_populated"]

    print()
    print("=== Summary ===")
    total = total_stats["tools_with_data"] + total_stats["tools_without_data"]
    print(f"Total tool definitions: {total}")
    print(f"Tools with at least one field populated: {total_stats['tools_with_data']}")
    print(f"Tools with no data: {total_stats['tools_without_data']}")
    print(f"Total fields populated: {total_stats['fields_populated']}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
