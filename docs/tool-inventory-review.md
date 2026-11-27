# Tool Inventory Review

**Status: draft, generated 2026-11-27.** A first pass of the current tools against [tool-inclusion-guidelines.md](tool-inclusion-guidelines.md). It lists candidates to look at, not decisions.

## Scope and method

- Scanned 445 `TOOL_DEFINITIONS` entries from `downloads/dfirws/tools_*.json`: 132 Python, 129 release, 59 git, 52 http, 23 enrichment, 21 winget, and 29 from the other sources (basic, node, rust, msys2, go, didier, kape, zimmerman, Visual Studio Build Tools).
- Maintenance signals come from three places:
  - the cached GitHub metadata in `downloads/.metadata/github` (archived flag and latest release date),
  - the last commit in local clones under `mount/git`,
  - the last upload date on PyPI for Python packages.
- A date is only a hint. A stable, finished tool can be old and still fine, and a release date can say nothing about commit activity.
- **Not checked:** whether each tool runs offline in the sandbox, hash/signature verification of downloads, first-run network or telemetry behavior, and whether a tool is a de facto standard. These need a human or a sandbox run.
- `scripts/validate-tool-metadata.ps1` reports 0 errors, 0 warnings and 0 infos on the current tree.

## Summary

| Guideline | Status | Count |
|-----------|--------|-------|
| 3. Maintenance | 0 archived among cached GitHub repos. 25 releases older than 2 years, 6 between 1 and 2 years | 31 |
| 3. Maintenance | Local git clones with last commit older than 2 years / 1-2 years | 22 / 5 |
| 3. Maintenance | PyPI packages with last upload older than 2 years / 1-2 years | 35 / 12 |
| 6. Licensing | License missing, `Unknown` or `See repository` (4 of these are stale JSON) | 80 |
| 6. Licensing | Restricted licenses (proprietary, freeware, commercial) | 34 |
| 8. Metadata | Missing `Homepage` in the generated JSON (stale, see below) | 4 |
| 8. Metadata | Missing `Notes` | 83 |
| 8. Metadata | Missing `Verify` and `InstallVerifyCommand` (excluding enrichment) | 183 |
| 8. Metadata | Tag count outside 2-6 | 58 |
| 8. Metadata | Tags not in the canonical list | 4 |
| 8. Metadata | `Category` not in the canonical list | 33 |
| 4. Online labeling | Tools with `Dependencies = @("online")` | 1 (11 after the first cleanup) |
| 4. Online labeling | Tools whose text mentions the network sandbox or an API key but lack the label | 34 (many false positives, see below) |

## Findings by guideline

### 1. Purpose and overlap

The overlap is mostly deliberate and fits the "cross-validation" rule. The areas with the most tools are below. These are the ones to check for "adds nothing over the others".

| Area (tag) | Tools | Comment |
|------------|-------|---------|
| `decompiler` | 15 | Language-specific (Java: jadx, Recaf, jd-gui, bytecode-viewer; .NET: ILSpy; Python: pycdc, unpy2exe) plus Ghidra, Cutter, Binary Ninja. Four Java decompilers is the most obvious overlap. |
| `deobfuscation` | 16 | Mixed languages and formats. Probably fine. |
| `sigma` | 15 | Mostly rule sets and pySigma backends. Fine. |
| `pe-analysis` | 23 | Includes libraries (pefile, lief, peutils) and GUIs (pestudio, PE-bear, Malcat). Worth a look. |
| `pcap` | 10 | Mostly libraries (scapy, dpkt, pyshark) beside Wireshark and Zui. |
| `yara` | 10 | YARA, yara-x, yara-python and rule sets. Fine. |
| `text-editor` | 9 | VS Code, Notepad++, Neovim, edit, plus extensions. Probably fine. |
| `hex-editor` | 4 | HxD, ImHex, Malcat, hexdump. Fine. |
| `event-log` | 12 | Chainsaw/Hayabusa/Zircolite/APT-Hunter overlap, which is useful for cross-validation. |
| `memory-forensics` | 10 | Includes two Volatility Workbench versions (3 and 2.1). Check whether both are needed. |

### 2. Maturity

Not assessed automatically. Many tools are well-known community tools, but a review needs a human. A few in the lists below look like experiments (for example `HiddenWave`, `Shadow-Pulse`, `hacksguard`, `White-Phoenix`).

### 3. Maintenance

Released more than 2 years ago (GitHub release date):

BeaconHunter (2021), CobaltStrikeScan (2021), RDPCacheStitcher (2021), PE-utils (2021), jd-gui (2019), Dependencies (2021), obsidian-calendar-plugin (2021), obsidian-timeline (2022), Elfparser-ng (2022), dsq (2022), gron (2022), Ares (2023), binlex (2023), readpe (2023), MetadataPlus (2023), Iaito (2023), sidr (2023), RpcView (2023), gftrace (2023), LogBoost (2024), Ghidra BTIGhidra (2024), Ghidra Cartographer (2024), Notepad++ (2023), ComparePlus (2023), DSpellCheck (2023).

Notes:

- `Notepad++` and its plugins show a 2023 release. Notepad++ itself releases often, so the cached repo is probably the wrong one for that entry. Check the `Homepage`.
- Some of these (`gron`, `jd-gui`, `Dependencies`, `readpe`) are small, finished tools that may be fine.
- Plugin repos can lag behind the host tool and still work.

Between 1 and 2 years: HollowsHunter, Flare-Fakenet-NG, DitExplorer, srum_dump, jwt-cli, YAMAGoya.

Local git clones with last commit older than 2 years:

CimSweep (2017), ToolAnalysisResultSheet (2017), SmartDeblur (2018), RegShot (2019), cutter-jupyter (2020), cutterref (2020), radare2-deep-graph (2020), libimobiledevice-windows (2020), Python-dsstore (2021), HiddenWave (2021), defender-detectionhistory-parser (2022), ese-analyst (2022), PowerSponse (2022), EVTX-ATTACK-SAMPLES (2023), legacy-sigmatools (2023), IDR (2023), Shadow-Pulse (2023), iShutdown (2024), PowerDecode (2024), White-Phoenix (2024), god-mode-rules (2024), chainsaw-rules (2024).

Notes:

- `EVTX-ATTACK-SAMPLES`, `legacy-sigmatools` and `chainsaw-rules` are data or deliberately legacy. Check whether `chainsaw-rules` still adds anything next to `sigma` and `hayabusa-rules`.
- The oldest entries (CimSweep, ToolAnalysisResultSheet, SmartDeblur, RegShot) are the first to review for "still works and still needed".
- The clone dates are as of the last download. Archived status is not checked for git clones.

PyPI last upload older than 2 years:

hexdump (2016), unpy2exe (2018), maclookup (2018), mkyara (2019), speakeasy (2019), python-registry (2019), PySocks (2019), pcode2code (2019), pathlab (2020), pfp (2020), keystone-engine (2020), pwncat (2021), python-magic (2022), pypng (2022), dpkt (2022), textsearch (2022), XLMMacroDeobfuscator (2022), name-that-hash (2022), pyvis (2023), pyOneNote (2023), pyshark (2023), deep_translator (2023), grip (2023), flatten_json (2023), olefile (2023), shodan (2023), toolong (2024), netaddr (2024), openpyxl (2024), oletools (2024), minidump (2024), pefile (2024), protodeep (2024), maldump (2024), rzpipe (2024).

Notes:

- Several are stable de facto libraries (pefile, olefile, oletools, openpyxl, netaddr, dpkt). A slow release cadence is fine for these.
- The PyPI lookup could not find 8 packages by name (EventHawk, White-Phoenix, msidump, dfir_ntfs, filterforge, plus three whose names contain a suffix such as "(Python package)"). They are probably installed from git or under a different name, and need a manual check.

### 4. Works in the sandbox, and online labeling

- Only `malware-bazaar-advanced-search` carries `Dependencies = @("online")`. The `Signatures and information\Online tools` shortcut folder is used by `vt`, `gti-dev-kit` and `malware-bazaar-advanced-search`, but only one entry has it as its `Category`.
- The 34 unlabeled tools break down as follows:
  - **Likely should be labeled:** VirusTotal CLI, gti-dev-kit, malwarebazaar, shodan, maclookup, godap, adalanche, CimSweep, PowerSponse, PatchaPalooza, PowerDecode, msticpy, mcp-server-elasticsearch, Zircolite, hayabusa (rule updates), zaproxy, Burp Suite, PuTTY, Tailscale, Google Earth Pro, pwncat, Ruby (gems).
  - **Probably false positives:** the MaxMind and IPinfo entries need a key only at download time on the host, not at runtime. scapy, requests, paramiko, grip, marimo, deep_translator, WinDbg and CuTE-tui are libraries or tools that only use the network optionally.
- Needs a human pass to decide which of the first group are really network-only and which work usefully offline.

### 5. Source and supply chain

Not assessed. Suggested follow-ups:

- List download entries that do not verify a hash or signature.
- List `http.ps1` entries that scrape pages for URLs.
- List tools downloaded from a non-upstream mirror or fork.

### 6. Licensing

- 80 entries have no real license: 71 `See repository`, 4 empty, 3 `See individual rule licenses`, and 2 `Unknown`. The GitHub API reports `NONE` or `NOASSERTION` for almost all of them, so they can't be filled automatically. Each needs a manual look at the upstream license file. `tools_rust.json` is stale: `dfir-toolkit`, `usnjrnl`, `CuTE-tui` and `SSHniff` already have Homepage and License in `install_rust_tools.ps1` (usnjrnl's crate license is listed as `non-standard`).
- 34 restricted-license entries are labeled, and the guideline asks that non-commercial limits be stated in `License` and `Notes`. Only `TrID` and `IrfanView` spell out the restriction. Entries labeled just `Freeware` or `Proprietary` should be checked: pestudio, Malcat Lite, OSFMount, MiTeC Structured Storage Viewer, FullEventLogView, PST Walker, PDFStreamDumper, Mail Viewer, both Volatility Workbench versions, NirSoft Browser Utilities, Binary Ninja, DCode, DensityScout, FASM, ProcDOT, API Monitor, MEX, Resource Hacker, Chrome, Burp Suite, Obsidian, OpenVPN, Google Earth Pro, Foxit PDF Reader, WinDbg.
- KAPE and the MaxMind entries follow the opt-in pattern (user-supplied zip or key).

### 7. Safety and handling

Not assessed. Sample sets are already separated (`dfirws-sample-files`, `EVTX-ATTACK-SAMPLES`).

### 8. Metadata

- **Missing `Homepage`:** dfir-toolkit, usnjrnl, CuTE-tui and SSHniff show no Homepage in `tools_rust.json`, but the Rust install script sets one. The generated file is out of date, so regenerate it before trusting the numbers in this section.
- **Non-canonical tags:** `image-restoration` (SmartDeblur), `proxy` (PolarProxy), `shellcode` (speakeasy), `dependencies` (Dependencies). Either add them to the canonical list or replace them.
- **Tag count outside 2-6:** 58 entries. Most are runtimes and plain Python libraries with 0-1 tags (7-Zip, git, GoLang, Rust, numpy, matplotlib, and so on). Probably the guideline should allow 0-1 tags for runtimes and support libraries.
- **`Category` not in the canonical list (33):** these match the real desktop folders (`IR`, `OS`, `Logs`, `Cloud`, `Malware tools`, `Sysinternals`, `Zimmerman`, `DidierStevens`) and the validator accepts them. The list in [categories-and-tags.md](categories-and-tags.md) lags the shortcuts. Either update the list or rename the folders. Entries: ClamAV, Didier Stevens Suite, RegShot, defender-detectionhistory-parser, Trawler, gootloader, PowerSponse, Sysinternals Suite, FullEventLogView, recbin, ProcDOT, apktool, Azure CLI, Android SDK Platform Tools, KAPE, White-Phoenix (venv), regipy, apkid, csvkit, maldump, XELFViewer, Jumplist Browser, Prefetch Browser, adalanche, Elfparser-ng, DitExplorer, srum_dump, Fibratus, sidr, Thumbcacheviewer, Velociraptor, usnjrnl, Zimmerman Tools.
- **Missing `Notes`:** 83 entries.
- **Missing `Verify`:** 183 entries, by source: python 72, git 56, release 35, http 7, node 6, basic 3, winget 3, Visual Studio Build Tools 1. Git repositories that only hold data or scripts are reasonable without one. The 35 release and 7 http entries are the ones most worth fixing, since those are runnable binaries.

## Suggested next steps

1. Decide whether to relax the tag-count and category rules in the guidelines, or fix the entries.
2. Label the remaining online tools with `Dependencies = @("online")` and mention the network sandbox in `Tips`. First batch done: VirusTotal CLI, gti-dev-kit, PowerSponse, OpenVPN, WireGuard, Tailscale, mcp-server-elasticsearch, malwarebazaar, shodan, godap.
3. Fill the remaining unknown licenses by reading each upstream license file. The GitHub API doesn't help for most of them.
4. Add `Verify` entries to the 35 release and 7 http tools that lack one.
5. Review the oldest entries (2017-2021) for "still works and still needed", and the four Java decompilers for overlap.
6. Run the checks that need a human or a sandbox: offline behavior, hash verification, telemetry on first run.
