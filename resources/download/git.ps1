. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

New-Item -ItemType Directory -Force -Path mount\git | Out-Null
Set-Location mount\git
if (Test-Path .\PatchaPalooza) {
    # Remove PatchaPalooza directory if it exists since we do a local patch
    Remove-Item -Recurse -Force .\PatchaPalooza 2>&1 | Out-Null
}
if (Test-Path .\AuthLogParser) {
    # Remove AuthLogParser since it has been renamed to MasterParser
    Remove-Item -Recurse -Force .\AuthLogParser 2>&1 | Out-Null
}

$repourls = `
    "https://github.com/ahmedkhlief/APT-Hunter.git", `
    "https://github.com/AndrewRathbun/DFIRArtifactMuseum.git", `
    "https://github.com/ANSSI-FR/bmc-tools.git", `
    "https://github.com/avasero/psexposed.git", `
    "https://github.com/Bert-JanP/Incident-Response-Powershell.git", `
    "https://github.com/BSI-Bund/RdpCacheStitcher.git", `
    "https://github.com/crypto2011/IDR.git", `
    "https://github.com/cyberark/White-Phoenix.git", `
    "https://github.com/ExeinfoASL/ASL.git", `
    "https://github.com/fr0gger/jupyter-collection.git", `
    "https://github.com/fboldewin/reconstructer.org.git", `
    "https://github.com/gehaxelt/Python-dsstore.git", `
    "https://github.com/import-pandas-as-numpy/chainsaw-rules", `
    "https://github.com/JavierYuste/radare2-deep-graph.git", `
    "https://github.com/jklepsercyber/defender-detectionhistory-parser.git", `
    "https://github.com/joeavanzato/Trawler.git", `
    "https://github.com/JPCERTCC/ToolAnalysisResultSheet.git", `
    "https://github.com/KasperskyLab/iShutdown.git", `
    "https://github.com/keraattin/EmailAnalyzer.git", `
    "https://github.com/keydet89/Events-Ripper.git", `
    "https://github.com/keydet89/RegRipper4.0", `
    "https://github.com/khyrenz/parseusbs.git", `
    "https://github.com/last-byte/PersistenceSniper.git", `
    "https://github.com/last-byte/PersistenceSniper.wiki.git", `
    "https://github.com/LibreOffice/dictionaries.git", `
    "https://github.com/Malandrone/PowerDecode.git", `
    "https://github.com/mandiant/flare-floss.git", `
    "https://github.com/mandiant/gootloader.git", `
    "https://github.com/mkorman90/regipy.git", `
    "https://github.com/mandiant/GoReSym.git", `
    "https://github.com/mandiant/gostringungarbler.git", `
    "https://github.com/mari-mari/CapaExplorer.git", `
    "https://github.com/MarkBaggett/ese-analyst.git", `
    "https://github.com/mattifestation/CimSweep.git", `
    "https://github.com/montysecurity/malware-bazaar-advanced-search.git", `
    "https://github.com/Neo23x0/god-mode-rules.git", `
    "https://github.com/Neo23x0/signature-base.git", `
    "https://github.com/netspooky/scare.git", `
    "https://github.com/ninewayhandshake/capa-explorer.git", `
    "https://github.com/pan-unit42/dotnetfile.git", `
    "https://github.com/rabbitstack/fibratus.git", `
    "https://github.com/radareorg/r2ai.git", `
    "https://github.com/reuteras/ai-fs-proxy.git", `
    "https://github.com/reuteras/dfirws-sample-files.git", `
    "https://github.com/reuteras/MSRC.git", `
    "https://github.com/rizinorg/cutter-jupyter.git", `
    "https://github.com/Seabreg/Regshot.git", `
    "https://github.com/sbousseaden/EVTX-ATTACK-SAMPLES.git", `
    "https://github.com/SigmaHQ/legacy-sigmatools.git", `
    "https://github.com/SigmaHQ/sigma.git", `
    "https://github.com/StrangerealIntel/Shadow-Pulse.git", `
    "https://github.com/swisscom/PowerSponse.git", `
    "https://github.com/techchipnet/HiddenWave.git", `
    "https://github.com/thewhiteninja/deobshell.git", `
    "https://github.com/TrimarcJake/BlueTuxedo.git", `
    "https://github.com/ufrisk/LeechCore.wiki.git", `
    "https://github.com/ufrisk/MemProcFS.wiki.git", `
    "https://github.com/VirusTotal/gti-dev-kit.git", `
    "https://github.com/volexity/one-extract.git", `
    "https://github.com/volexity/threat-intel.git", `
    "https://github.com/wagga40/Zircolite.git", `
    "https://github.com/reuteras/PatchaPalooza.git", `
    "https://github.com/xaitax/TotalRecall.git", `
    "https://github.com/Yamato-Security/hayabusa-rules.git", `
    "https://github.com/securityjoes/MasterParser.git", `
    "https://github.com/yossizap/cutterref.git"

foreach ($repourl in $repourls) {
    $repo = Write-Output $repourl | ForEach-Object { $_ -replace "^.*/" } | ForEach-Object { $_ -replace "\.git$" }
    if ($null -ne $DFIRWS_EXCLUDE_GIT_REPOS -and $DFIRWS_EXCLUDE_GIT_REPOS.Count -gt 0 -and $DFIRWS_EXCLUDE_GIT_REPOS -contains $repo) {
        Write-SynchronizedLog "Skipping git repo ${repo} (excluded by profile)."
        continue
    }
    if ( Test-Path -Path "${repo}" ) {
        Set-Location "${repo}"
        ${result} = git pull 2>&1
        Write-SynchronizedLog "${result}"
        Set-Location ..
    } else {
        $result = git clone "${repourl}" 2>&1
        Write-SynchronizedLog "${result}"
    }
}

# Patch PatchaPalooza
Set-Location PatchaPalooza
(Get-Content .\PatchaPalooza.py -Raw) -replace "import termcolor","import termcolor`nimport colorama`ncolorama.init()" -replace '^#!/usr/bin/.*', '#!/usr/bin/env python' | Set-Content .\PatchaPalooza2.py
Copy-Item .\PatchaPalooza2.py .\PatchaPalooza.py -Force
Remove-Item .\PatchaPalooza2.py
Set-Location ..

# Copy parseUSBs.exe to bin directory
if (Test-Path -Path ".\parseusbs\parseusbs.exe") {
    Copy-Item ".\parseusbs\parseusbs.exe" "..\Tools\bin" -Force | Out-Null
}

# Extract OfficeMalScanner
if (Test-Path -Path ".\reconstructer.org\OfficeMalScanner.zip") {
    if (Test-Path -Path "${TOOLS}\OfficeMalScanner") {
        Remove-Item -Force -Recurse "${TOOLS}\OfficeMalScanner"
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\OfficeMalScanner.zip" -o"${TOOLS}" | Out-Null
}

& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "ASL\exeinfope.zip" -o"..\Tools" | Out-Null

Set-Location ..\..

$TOOL_DEFINITIONS += @{
    Name = "OfficeMalScanner"
    Homepage = "https://github.com/fboldewin/reconstructer.org"
    Vendor = "fboldewin"
    License = ""
    LicenseUrl = ""
    Category = "Files and apps\Office"
    Shortcuts = @(
         @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\OfficeMalScanner.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command `${TOOLS}\OfficeMalScanner\OfficeMalScanner.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${TOOLS}\OfficeMalScanner\OfficeMalScanner.exe"
            Expect = "PE32"
        }
    )
    Notes = "OfficeMalScanner can scan old office documents."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
    Tags = @("office", "macro", "vba", "malware-analysis")
    FileExtensions = @(".doc", ".ppt", ".xls")
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "RegShot"
    Homepage = "https://github.com/Seabreg/Regshot"
    Vendor = "Seabreg"
    License = "MIT License"
    LicenseUrl = "https://github.com/Seabreg/Regshot/blob/master/LICENSE"
    Category = "OS\Windows\Registry"
    Shortcuts = @(
         @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Registry\RegShot-x64-ANSI.lnk"
            Target   = "`${GIT_PATH}\RegShot\RegShot-x64-ANSI.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Registry\RegShot-x64-Unicode.lnk"
            Target   = "`${GIT_PATH}\RegShot\RegShot-x64-Unicode.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${GIT_PATH}\RegShot\RegShot-x64-ANSI.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${GIT_PATH}\RegShot\RegShot-x64-Unicode.exe"
            Expect = "PE32"
        }
    )
    Notes = "RegShot is a small, free and open-source registry compare utility."
    Tips = "Regshot is a small, free and open-source registry compare utility that allows you to quickly take a snapshot of your registry and then compare it with a second one - done after doing system changes or installing a new software product. The changes report can be produced in text or HTML format and contains a list of all modifications that have taken place between the two snapshots. In addition, you can also specify folders (with subfolders) to be scanned for changes as well."
    Usage = "RegShot is a registry compare utility made by Seabreg for Windows. It includes support for taking snapshots of the registry and comparing them."
    SampleCommands = @(
        "RegShot-x64-ANSI.exe"
        "RegShot-x64-Unicode.exe"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
    Tags = @()
    FileExtensions = @()
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "APT-Hunter"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("event-log", "threat-hunting")
    Notes = "APT-Hunter is Threat Hunting tool for windows event logs which made by purple team mindset to provide detect APT movements hidden in the sea of windows event logs to decrease the time to uncover suspicious activity."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "DFIRArtifactMuseum"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "artifacts", "reference")
    Notes = "The goal of this repo is to archive artifacts from all versions of various OS's and categorizing them by type. This will help with artifact validation processes as well as increase access to artifacts that may no longer be readily available anymore."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "bmc-tools"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "rdp")
    Notes = "RDP Bitmap Cache parser"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "psexposed"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".ps1")
    Tags = @("windows", "forensics", "psexec")
    Notes = "Community-driven PowerShell detection indicators"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://www.powershell.exposed"
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Incident-Response-Powershell"
    Category = "IR"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("incident-response", "powershell")
    Notes = "PowerShell Digital Forensics & Incident Response Scripts."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "RdpCacheStitcher"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "rdp", "image-reconstruction")
    Notes = "RdpCacheStitcher is a tool that supports forensic analysts in reconstructing useful images out of RDP cache bitmaps."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "IDR"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "delphi", "decompiler")
    Notes = "Interactive Delphi Reconstructor"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "White-Phoenix"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("ransomware", "decryption", "recovery")
    Notes = "A tool to recover content from files encrypted with intermittent encryption"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ASL"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe")
    Tags = @("pe-analysis", "packer-detection")
    Notes = "Detect packer , compiler , protector , .NET obfuscator , PUA application"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "jupyter-collection"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("jupyter", "notebook")
    Notes = "Collection of Jupyter Notebooks by @fr0gger_"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Python-dsstore"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".DS_Store")
    Tags = @("forensics", "macos", "data-extraction")
    Notes = "A library for parsing .DS_Store files and extracting file names"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "chainsaw-rules"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("sigma", "detection-rules")
    Notes = "A set of custom Chainsaw rules for event log threat hunting."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "radare2-deep-graph"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "visualization")
    Notes = "A Cutter plugin to generate radare2 graphs."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "r2ai"
    Homepage = "https://github.com/radareorg/r2ai"
    Vendor = "radareorg"
    License = "MIT License"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "path"
            Name = "`${HOME}\.local\share\radare2\plugins\r2ai.dll"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so")
    Tags = @("reverse-engineering", "ai", "radare2")
    Notes = "Native AI plugin for radare2. Compiled from source in the MSYS2 sandbox using gcc and pkg-config. Provides AI-assisted analysis using local and remote language models."
    Tips = ""
    Usage = "Load automatically as a radare2 core plugin. Use r2ai commands within the radare2 shell for AI-assisted binary analysis."
    SampleCommands = @(
        "r2ai -h"
    )
    SampleFiles = @()
    Dependencies = @("Radare2", "msys2")
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "decai"
    Homepage = "https://github.com/radareorg/r2ai"
    Vendor = "radareorg"
    License = "MIT License"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so")
    Tags = @("reverse-engineering", "ai", "decompilation", "radare2")
    Notes = "r2js plugin for radare2 with special focus on AI-assisted decompilation. Installed by copying decai.r2.js to the radare2 plugins directory."
    Tips = "Use within radare2 to get AI-powered decompilation output. Requires an LLM API key configured."
    Usage = "Use within radare2 shell for AI-assisted decompilation of binary code."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Radare2")
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "defender-detectionhistory-parser"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "defender", "forensics")
    Notes = "A parser of Windows Defender's DetectionHistory forensic artifact, containing substantial info about quarantined files and executables."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Trawler"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "persistence", "threat-hunting")
    Notes = "PowerShell script helping Incident Responders discover potential adversary persistence mechanisms."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ToolAnalysisResultSheet"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("forensics", "reference", "lateral-movement")
    Notes = "This repository summarizes the results of examining logs recorded in Windows upon execution of the 49 tools which are likely to be used by the attacker that has infiltrated a network."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "iShutdown"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("ios", "forensics", "mobile")
    Notes = "iShutdown scripts: extracts, analyzes, and parses Shutdown.log forensic artifact from iOS Sysdiagnose archives"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = "Kaspersky"
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "EmailAnalyzer"
    Category = "Files and apps\Email"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".eml")
    Tags = @("email", "forensics", "phishing")
    Notes = "With EmailAnalyzer you can analyze your suspicious emails. You can extract headers, links, and hashes from the .eml file and you can generate reports."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Events-Ripper"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("event-log", "forensics", "windows")
    Notes = "This project is based on RegRipper, to easily extract additional value/pivot points from a TLN events file."
    Tips = ""
    Usage = "Events-Ripper is based on the 5-field, pipe-delimited TLN `"intermediate`" events file format. This file is intermediate, as it the culmination or collection of normalized events from different data sources (i.e., Registry, WEVTX, MFT, etc.) that are then parsed into a deduped timeline.

The current iteration of Events-Ripper includes plugins that are written specifically for Windows Event Log (*.evtx) events.

This tool is intended to address a very specific problem set, one that leverages a limited data set to develop as much insight and situational awareness as possible from that data set.

"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "RegRipper4.0"
    Category = "OS\Windows\Registry"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("registry", "forensics", "windows")
    Notes = "RegRipper4.0 includes ISO 8601-ish time stamp formatting, MITRE ATT&CK mapping (for some, albeit not all, plugins), and Analysis Tips. Also, there are many new plugins since August, 2020."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "PersistenceSniper"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "persistence", "threat-hunting")
    Notes = "Powershell module that can be used by Blue Teams, Incident Responders and System Administrators to hunt persistences implanted in Windows machines."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "PersistenceSniper.wiki"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "persistence", "documentation")
    Notes = "GitHub wiki for PersistenceSniper."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dictionaries"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("dictionaries", "libreoffice")
    Notes = "Dictionaries and related code and data for Libreoffice."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "PowerDecode"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("powershell", "deobfuscation", "malware-analysis")
    Notes = "PowerDecode is a PowerShell-based tool that allows to deobfuscate PowerShell scripts obfuscated across multiple layers. The tool performs code dynamic analysis, extracting malware hosting URLs and checking http response.It can also detect if the malware attempts to inject shellcode into memory."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "flare-floss"
    Category = "Malware tools"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "string-extraction", "malware-analysis")
    Notes = "FLARE Obfuscated String Solver - Automatically extract obfuscated strings from malware."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = "Mandiant"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "gootloader"
    Category = "Malware tools"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("malware-analysis", "gootloader")
    Notes = "Collection of scripts used to deobfuscate GOOTLOADER malware samples."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = "Mandiant"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "GoReSym"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "golang", "symbol-recovery")
    Notes = "Go symbol recovery tool"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = "Mandiant"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "gostringungarbler"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "golang", "deobfuscation")
    Notes = "Python tool to resolve all strings in Go binaries obfuscated by garble."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = "Mandiant"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "CapaExplorer"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "capa", "visualization")
    Notes = "Capa analysis importer for Ghidra."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ese-analyst"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".dat")
    Tags = @("forensics", "ese", "database")
    Notes = "This is a set of tools for doing forensics analysis on Microsoft ESE databases."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "CimSweep"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "forensics", "wmi")
    Notes = "CimSweep is a suite of CIM/WMI-based tools that enable the ability to perform incident response and hunting operations remotely across all versions of Windows."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "malware-bazaar-advanced-search"
    Category = "Malware tools"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("malware-analysis", "threat-intelligence")
    Notes = "Script to chain search parameters for MalwareBazaar"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("online")
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "god-mode-rules"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("yara", "sigma", "detection-rules")
    Notes = "God Mode Detection Rules"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "signature-base"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yara")
    Tags = @("yara", "detection-rules", "ioc")
    Notes = "YARA signature and IOC database for my scanners and tools."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "scare"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("assembly", "emulation", "repl")
    Notes = "A multi-arch assembly REPL and emulator for your command line."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "capa-explorer"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "capa", "visualization")
    Notes = "capa explorer for Cutter."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Cutter")
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dotnetfile"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("pe-analysis", "dotnet")
    Notes = "dotnetfile is a Common Language Runtime (CLR) header parser library for Windows .NET files built in Python. The CLR header is present in every Windows .NET assembly beside the Portable Executable (PE) header. It stores a plethora of metadata information for the managed part of the file."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = "Unit42"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "fibratus"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "etw", "tracing")
    Notes = "Adversary tradecraft detection, protection, and hunting"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ai-fs-proxy"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("ai", "filesystem")
    Notes = "IP over filesystem."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dfirws-sample-files"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "samples", "testing")
    Notes = "Sample files to test forensics tools."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "MSRC"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vulnerability", "microsoft", "security-advisory")
    Notes = "Data from Microsoft patch tuesdays."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "cutter-jupyter"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "rizin")
    Notes = "Jupyter Plugin for Cutter."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "EVTX-ATTACK-SAMPLES"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("event-log", "mitre-attack", "samples")
    Notes = "Windows Events Attack Samples."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "legacy-sigmatools"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("sigma", "detection-rules")
    Notes = "Legacy Sigma Tools (sigmac etc.)"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "sigma"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("sigma", "detection-rules", "siem")
    Notes = "Main Sigma Rule Repository"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Shadow-Pulse"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("threat-intelligence", "ioc")
    Notes = "Information about ransomware groups (Ransomware Analysis Notes)"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "PowerSponse"
    Category = "IR"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("incident-response", "powershell", "containment")
    Notes = "PowerSponse is a PowerShell module focused on targeted containment and remediation during incident response."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "HiddenWave"
    Category = "Utilities\CTF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".waw")
    Tags = @("steganography", "audio", "CTF")
    Notes = "Hide Your Secret Message in any Wave Audio File."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "deobshell"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("powershell", "deobfuscation", "malware-analysis")
    Notes = "Powershell script deobfuscation using AST in Python."
    Tips = ""
    Usage = "DeobShell is PoC to deobfuscate Powershell using Abstract Syntax Tree (AST) manipulation in Python. The AST is extracted using a Powershell script by calling System.Management.Automation.Language.Parser and writing relevant nodes to an XML file."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "BlueTuxedo"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "active-directory", "dns")
    Notes = "A tiny tool built to find and fix common misconfigurations in Active Directory-integrated DNS"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "LeechCore.wiki"
    Category = "Memory"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("memory-forensics", "documentation")
    Notes = "GitHub wiki for LeechCore."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "MemProcFS.wiki"
    Category = "Memory"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("memory-forensics", "documentation")
    Notes = "GitHub wiki for MemProcFS"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "gti-dev-kit"
    Category = "Signatures and information\Online tools"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("virustotal", "threat-intelligence")
    Notes = "The Google Threat Intelligence dev kit is a collection of example code to quickly develop functional integrations with the GTI API, enabling a unified view of the threat landscape and reducing manual effort in threat analysis."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = "VirusTotal"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "one-extract"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "onenote", "data-extraction")
    Notes = "Python library for extracting objects from OneNote files."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "threat-intel"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("threat-intelligence", "ioc")
    Notes = "Signatures and IoCs from public Volexity blog posts."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = "Volexity"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Zircolite"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("event-log", "sigma", "detection")
    Notes = "A standalone SIGMA-based detection tool for EVTX, Auditd and Sysmon for Linux logs"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "PatchaPalooza"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vulnerability", "microsoft", "patch-analysis")
    Notes = "A comprehensive tool that provides an insightful analysis of Microsoft's monthly security updates."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "regipy"
    Homepage = "https://github.com/mkorman90/regipy"
    Vendor = "mkorman90"
    License = "MIT License"
    Category = "OS\\Windows\\Registry"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".reg", ".dat")
    Tags = @("registry", "windows", "forensics", "mcp")
    Notes = "regipy repository including regipy MCP server for AI-assisted registry analysis."
    Tips = "The regipy MCP server is at C:\\git\\regipy\\regipy_mcp_server\\server.py. It can be used with opencode-ai for AI-assisted registry hive analysis."
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "TotalRecall"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "recall", "forensics")
    Notes = "This tool extracts and displays data from the Recall feature in Windows 11, providing an easy way to access information about your PC's activity snapshots."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "hayabusa-rules"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("event-log", "detection-rules", "sigma")
    Notes = "Curated Windows event log Sigma rules used in Hayabusa and Velociraptor."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "MasterParser"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".log")
    Tags = @("log-analysis", "linux", "authentication")
    Notes = "MasterParser is a powerful DFIR tool designed for analyzing and parsing Linux logs"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "cutterref"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "rizin", "cheat-sheet")
    Notes = "Cutter Instruction Reference Plugin"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "git"
