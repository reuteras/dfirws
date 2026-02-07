#!/usr/bin/env python3
"""
Populate $TOOL_DEFINITIONS skeleton entries in download scripts
with data from install_verify.ps1, dfirws_folder.ps1, and dfirws-install.ps1.

One-time script to fill in Category, Verify, Shortcuts, and
InstallVerifyCommand fields.
"""

from __future__ import annotations

import re
import sys
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


# ---------------------------------------------------------------------------
# Parse install_verify.ps1
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
                entries.append({"command": m2.group(1), "type": m2.group(2).strip('"')})
        elif rest.startswith("$"):
            continue  # skip variable references
        else:
            parts = rest.split()
            if len(parts) >= 2:
                entries.append({"command": parts[0], "type": parts[1]})
    return entries


def build_verify_index(entries: List[dict]) -> Dict[str, List[str]]:
    """Map normalized basename -> list of 'command type' verify strings."""
    index: Dict[str, List[str]] = {}
    for e in entries:
        basename = get_cmd_basename(e["command"])
        norm = normalize(basename)
        if "\\" in e["command"] or "/" in e["command"]:
            vs = f'"{e["command"]}" {e["type"]}'
        else:
            vs = f'{e["command"]} {e["type"]}'
        index.setdefault(norm, []).append(vs)
    return index


# ---------------------------------------------------------------------------
# Parse dfirws_folder.ps1
# ---------------------------------------------------------------------------
def parse_shortcuts(path: Path) -> List[dict]:
    shortcuts = []
    text = path.read_text(encoding="utf-8")
    for line in text.splitlines():
        m = re.search(
            r'Add-Shortcut\s+-SourceLnk\s+"[^"]*\\Desktop\\dfirws\\(.+?)\\([^\\]+)\.lnk"',
            line,
            re.IGNORECASE,
        )
        if m:
            category = m.group(1)
            shortcut_name = m.group(2)
            shortcuts.append({"category": category, "name": shortcut_name})
    return shortcuts


def build_shortcut_index(shortcuts: List[dict]) -> Dict[str, List[dict]]:
    """Map normalized first-word of shortcut name -> list of shortcut entries."""
    index: Dict[str, List[dict]] = {}
    for s in shortcuts:
        name = s["name"]
        # Extract the first word / phrase before parenthetical description
        m = re.match(r"([^(]+)", name)
        key = m.group(1).strip() if m else name
        norm = normalize(key)
        index.setdefault(norm, []).append(s)
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

# tool def Name -> list of verify strings
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
    "stego-lsb": [],  # no verify
    "sqlit-tui": [],  # no verify; built from source
    "markitdown": [],  # no verify in install_verify
    "netaddr": ["C:\\venv\\bin\\netaddr.exe PE32"],
    "pypng": ["C:\\venv\\bin\\priweavepng.py Python"],
    "unpy2exe": ["C:\\venv\\bin\\unpy2exe.py Python"],
    "xlrd": ["C:\\venv\\bin\\runxlrd.py Python"],
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
}

# Shortcut overrides: tool name -> list of (category, shortcut_name) tuples
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
    "Velociraptor": [("IR", "velociraptor.exe (Velociraptor is an advanced digital forensic and incident response tool)")],
    "fq": [("Files and apps", "fq (jq for binary formats)")],
    "fqlite": [("Files and apps\\Database", "fqlite (runs dfirws-install -FQLite)")],
    "Zircolite": [("Files and apps\\Log", "zircolite (Standalone SIGMA-based detection tool)")],
    "ImHex": [("Editors", "ImHex")],
    "chainsaw": [("Files and apps\\Log", "chainsaw (Rapidly work with Forensic Artefacts)")],
    "YARA": [("Signatures and information", "yara"), ("Signatures and information", "yarac")],
    "yara-x": [("Signatures and information", "yr (yara-x)")],
    "yq": [("Signatures and information", "yq (is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor)")],
    "x64dbg": [("Reverse Engineering", "X64dbg (runs dfirws-install -X64dbg)")],
    "hayabusa": [("Files and apps\\Log", "hayabusa (is a sigma-based threat hunting and fast forensics timeline generator)")],
    "takajo": [("Files and apps\\Log", "takajo (is a tool to analyze Windows event logs - hayabusa)")],
    "zaproxy": [("Network", "Zaproxy (runs dfirws-install -Zaproxy)")],
    "DB Browser for SQLite": [("Files and apps\\Database", "DB Browser for SQLite")],
    "YAMAGoya": [("Files and apps\\Log", "YAMAGoya (Yet Another Memory Analyzer)")],
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
    "WinDbg": [],  # No shortcut in dfirws_folder
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
    "toolong": [("Files and apps\\Log", "toolong (tl - A terminal application to view, tail, merge, and search log files)")],
    "visidata": [("Utilities", "visidata (VisiData or vd is an interactive multitool for tabular data)")],
    "XLMMacroDeobfuscator": [("Files and apps\\Office", "xlmdeobfuscator (XLMMacroDeobfuscator can be used to decode obfuscated XLM macros)")],
    "jpterm": [("Utilities", "jpterm (Jupyter in the terminal)")],
    "litecli": [("Files and apps\\Database", "litecli (SQLite CLI with autocompletion and syntax highlighting)")],
    "pwncat": [("Utilities", "pwncat.py (Fancy reverse and bind shell handler)")],
    "sigma-cli": [("Signatures and information", "sigma-cli (This is the Sigma command line interface)")],
    "dfir-unfurl": [
        ("Files and apps\\Browser", "unfurl_app.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl)"),
        ("Files and apps\\Browser", "unfurl.exe"),
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
}


def format_verify(items: List[str]) -> str:
    if not items:
        return "@()"
    if len(items) == 1:
        return f'@("{items[0]}")'
    inner = ", ".join(f'"{v}"' for v in items)
    return f"@({inner})"


def format_shortcuts(items: List[Tuple[str, str]]) -> str:
    if not items:
        return "@()"
    entries = []
    for cat, name in items:
        entries.append(f"{cat}\\{name}")
    if len(entries) == 1:
        return f'@("{entries[0]}")'
    inner = ", ".join(f'"{e}"' for e in entries)
    return f"@({inner})"


def update_definitions_in_file(
    path: Path, stats: dict, verify_index: Dict[str, List[str]]
) -> None:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)

    # Find each $TOOL_DEFINITIONS += @{ ... } block and update it
    result = []
    i = 0
    while i < len(lines):
        line = lines[i]

        # Detect start of a tool definition block
        if re.match(r"\s*\$TOOL_DEFINITIONS\s*\+=\s*@\{", line):
            # Collect the entire block
            block_lines = [line]
            i += 1
            brace_depth = 1
            while i < len(lines) and brace_depth > 0:
                block_lines.append(lines[i])
                brace_depth += lines[i].count("{") - lines[i].count("}")
                i += 1

            # Extract the Name
            name_match = None
            for bl in block_lines:
                m = re.match(r'\s*Name\s*=\s*"([^"]+)"', bl)
                if m:
                    name_match = m.group(1)
                    break

            if name_match:
                # Get category
                category = CATEGORY_MAP.get(name_match, "")
                # Get verify - try override first, then auto-match
                verify = VERIFY_OVERRIDES.get(name_match)
                if verify is None:
                    norm = normalize(name_match)
                    verify = verify_index.get(norm, [])
                # Get install command
                install_cmd = ""
                if name_match in INSTALL_CMD_MAP:
                    install_cmd = f"dfirws-install.ps1 -{INSTALL_CMD_MAP[name_match]}"
                # Get shortcuts
                shortcut_data = SHORTCUT_OVERRIDES.get(name_match)
                shortcuts: List[Tuple[str, str]] = []
                if shortcut_data is not None:
                    shortcuts = shortcut_data
                else:
                    shortcuts = []

                # Track stats
                fields_populated = 0
                if category:
                    fields_populated += 1
                if verify:
                    fields_populated += 1
                if install_cmd:
                    fields_populated += 1
                if shortcuts:
                    fields_populated += 1

                if fields_populated > 0:
                    stats["tools_with_data"] += 1
                    stats["fields_populated"] += fields_populated
                else:
                    stats["tools_without_data"] += 1

                # Rebuild the block with populated fields
                new_block = []
                new_block.append(f'$TOOL_DEFINITIONS += @{{\n')
                new_block.append(f'    Name = "{name_match}"\n')
                new_block.append(f'    Category = "{category}"\n')
                new_block.append(f'    Shortcuts = {format_shortcuts(shortcuts)}\n')
                new_block.append(f'    InstallVerifyCommand = "{install_cmd}"\n')
                new_block.append(f'    Verify = {format_verify(verify)}\n')
                new_block.append(f'    Notes = ""\n')
                new_block.append(f'    Tips = ""\n')
                new_block.append(f'    Usage = ""\n')
                new_block.append(f'    SampleCommands = @()\n')
                new_block.append(f'    SampleFiles = @()\n')
                new_block.append(f'}}\n')
                result.extend(new_block)
            else:
                # No name found, keep as-is
                result.extend(block_lines)
            continue

        result.append(line)
        i += 1

    path.write_text("".join(result), encoding="utf-8")


def main() -> int:
    # Verify source files exist
    for p in [VERIFY_FILE, FOLDER_FILE, INSTALL_FILE]:
        if not p.exists():
            print(f"ERROR: {p} not found")
            return 1
    for p in DOWNLOAD_FILES:
        if not p.exists():
            print(f"ERROR: {p} not found")
            return 1

    # Parse sources
    verify_entries = parse_verify(VERIFY_FILE)
    verify_index = build_verify_index(verify_entries)
    shortcuts = parse_shortcuts(FOLDER_FILE)
    install_params = parse_install_params(INSTALL_FILE)

    print(f"Parsed {len(verify_entries)} verify commands from install_verify.ps1")
    print(f"Parsed {len(shortcuts)} shortcuts from dfirws_folder.ps1")
    print(f"Parsed {len(install_params)} install parameters from dfirws-install.ps1")
    print(f"Built verify index with {len(verify_index)} unique command names")
    print()

    # Report category coverage
    print(f"Category mappings defined: {len(CATEGORY_MAP)}")
    print(f"Verify overrides defined: {len(VERIFY_OVERRIDES)}")
    print(f"Shortcut overrides defined: {len(SHORTCUT_OVERRIDES)}")
    print(f"Install command mappings defined: {len(INSTALL_CMD_MAP)}")
    print()

    # Process each download file
    total_stats = {"tools_with_data": 0, "tools_without_data": 0, "fields_populated": 0}

    for path in DOWNLOAD_FILES:
        file_stats = {"tools_with_data": 0, "tools_without_data": 0, "fields_populated": 0}
        print(f"Processing {path.name}...")
        update_definitions_in_file(path, file_stats, verify_index)
        print(f"  Tools with data populated: {file_stats['tools_with_data']}")
        print(f"  Tools without data: {file_stats['tools_without_data']}")
        print(f"  Total fields populated: {file_stats['fields_populated']}")
        total_stats["tools_with_data"] += file_stats["tools_with_data"]
        total_stats["tools_without_data"] += file_stats["tools_without_data"]
        total_stats["fields_populated"] += file_stats["fields_populated"]

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
