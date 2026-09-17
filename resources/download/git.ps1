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
    "https://github.com/iFred09/libimobiledevice-windows.git", `
    "https://github.com/import-pandas-as-numpy/chainsaw-rules", `
    "https://github.com/JavierYuste/radare2-deep-graph.git", `
    "https://github.com/jklepsercyber/defender-detectionhistory-parser.git", `
    "https://github.com/joeavanzato/Trawler.git", `
    "https://github.com/JPCERTCC/ToolAnalysisResultSheet.git", `
    "https://github.com/KasperskyLab/iShutdown.git", `
    "https://github.com/keraattin/EmailAnalyzer.git", `
    "https://github.com/khyrenz/parseusbs.git", `
    "https://github.com/LibreOffice/dictionaries.git", `
    "https://github.com/Malandrone/PowerDecode.git", `
    "https://github.com/mandiant/flare-floss.git", `
    "https://github.com/mandiant/gootloader.git", `
    "https://github.com/mkorman90/regipy.git", `
    "https://github.com/mandiant/capa-rules.git", `
    "https://github.com/mandiant/GoReSym.git", `
    "https://github.com/mandiant/gostringungarbler.git", `
    "https://github.com/mandiant/speakeasy.git", `
    "https://github.com/MarkBaggett/ese-analyst.git", `
    "https://github.com/mattifestation/CimSweep.git", `
    "https://github.com/Mihir-Choudhary/EventHawk.git", `
    "https://github.com/montysecurity/malware-bazaar-advanced-search.git", `
    "https://github.com/Neo23x0/god-mode-rules.git", `
    "https://github.com/Neo23x0/signature-base.git", `
    "https://github.com/netspooky/scare.git", `
    "https://github.com/netwho/PacketCircle.git", `
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
    "https://github.com/sleuthkit/autopsy_addon_modules.git", `
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
    "https://github.com/Y-Vladimir/SmartDeblur.git", `
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
    if (Test-Path -Path "..\Tools\OfficeMalScanner") {
        Remove-Item -Force -Recurse "..\Tools\OfficeMalScanner"
    }
    & $SEVENZIP x -aoa ".\reconstructer.org\OfficeMalScanner.zip" -o"..\Tools\" | Out-Null
}

# Extract SmartDeblur
if (Test-Path -Path ".\SmartDeblur\dist\SmartDeblur-1.*-win.zip") {
    if (Test-Path -Path "..\Tools\SmartDeblur") {
        Remove-Item -Force -Recurse "..\Tools\SmartDeblur"
    }
    & $SEVENZIP x -aoa ".\SmartDeblur\dist\SmartDeblur-1.*-win.zip" -o"..\Tools\" | Out-Null
    Move-Item ..\Tools\SmartDeblur-* ..\Tools\SmartDeblur
}

& $SEVENZIP x -aoa "ASL\exeinfope.zip" -o"..\Tools" | Out-Null

Set-Location ..\..

$TOOL_DEFINITIONS += @{
    Name = "SmartDeblur"
    Homepage = "https://github.com/y-vladimir/smartdeblur"
    Vendor = "Y. Vladimir"
    License = "GPL-3"
    LicenseUrl = ""
    Category = "Utilities\Media"
    Shortcuts = @(
         @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Media\SmartDeblur.lnk"
            Target   = "`${TOOLS}\SmartDeblur\SmartDeblur.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${TOOLS}\SmartDeblur\SmartDeblur.exe"
            Expect = "PE32"
        }
    )
    Notes = "SmartDeblur is a tool for restoring unfocused and blurred images. It can be used to recover details from images that are out of focus or have motion blur."
    Tips = "Try the Out of Focus preset first and increase the radius slowly; use the Motion Blur mode only when the blur has a clear direction. Useful for recovering text from blurred screenshots and photos."
    Usage = "GUI: start from the desktop shortcut and open a blurred image."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Tags = @("image-restoration", "forensics")
}

$TOOL_DEFINITIONS += @{
    Name = "autopsy_addon_modules"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "disk-forensics", "plugins", "documentation")
    Notes = "Collection of third-party add-on modules for Autopsy — ingest modules, content viewers, report modules, and data source processors."
    Tips = "Autopsy must be installed first with dfirws-install.ps1 -Autopsy. In Autopsy use Tools -> Python Plugins to open the plugin directory, copy the module there and restart Autopsy."
    Usage = "Copy the wanted module folder from C:\git\autopsy_addon_modules into the Autopsy python_modules directory."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/sleuthkit/autopsy_addon_modules"
    Vendor = "Sleuth Kit"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "libimobiledevice-windows"
    Homepage = "https://github.com/iFred09/libimobiledevice-windows"
    Vendor = "iFred09"
    Category = "Files and apps\Mobile"
    Notes = "A Windows port of libimobiledevice, a cross-platform library to communicate with iOS devices. It includes tools for extracting data from iOS devices, such as lockdown, idevicebackup2, and more."
    Tips = "Needed by ULogViewer to read logs from an iOS device. The binaries are under C:\git\libimobiledevice-windows; the sandbox cannot see USB devices, so in practice you work with backups and logs copied into the readwrite folder."
    Usage = "idevice_id -l"
    Tags = @("mobile-forensics", "forensics")
}

$TOOL_DEFINITIONS += @{
    Name = "PacketCircle"
    Homepage = "https://github.com/netwho/PacketCircle"
    Vendor = "netwho"
    License = "GPL-2.0"
    LicenseUrl = "https://github.com/netwho/PacketCircle?tab=GPL-2.0-1-ov-file"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = "Wireshark Plugin for traffic-matrix visualization."
    Tips = "Wireshark must be installed first with dfirws-install.ps1 -Wireshark. Once loaded, the traffic matrix visualisation is available in the Wireshark Tools menu."
    Usage = "Copy the Lua plugin into the Wireshark plugins directory and reload Lua plugins (Analyze -> Reload Lua Plugins)."
    SampleCommands = @()
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @("Wireshark")
    Tags = @("network", "plugins", "visualization")
    FileExtensions = @(".pcap", ".pcapng")
    PythonVersion = ""
}

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
    Tips = "Use 'info' to dump VBA macros from legacy .doc and .xls files and 'scan brute debug' to find shellcode, encrypted PE files and embedded OLE objects. For OOXML files (docx, xlsm) use olevba or oledump instead."
    Usage = "OfficeMalScanner.exe <file> scan brute"
    SampleCommands = @()
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
    Tags = @("office", "vba", "malware-analysis")
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
    Tips = "Feed it a folder of exported EVTX files (Security, System, PowerShell, Sysmon, TerminalServices and others). Output is CSV and Excel with detections plus a timeline; combine with hayabusa or chainsaw for broader Sigma coverage."
    Usage = "python C:\git\APT-Hunter\APT-Hunter.py -p <folder with evtx files> -o <output name> -allreport"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/ahmedkhlief/APT-Hunter"
    Vendor = "ahmedkhlief"
    License = "GPL-3.0 License"
    LicenseUrl = "https://github.com/ahmedkhlief/APT-Hunter/blob/main/LICENSE"
    PythonVersion = "3.11"
}

$TOOL_DEFINITIONS += @{
    Name = "DFIRArtifactMuseum"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "artifact-extraction", "documentation")
    Notes = "The goal of this repo is to archive artifacts from all versions of various OS's and categorizing them by type. This will help with artifact validation processes as well as increase access to artifacts that may no longer be readily available anymore."
    Tips = "Sample artifacts (registry hives, event logs, prefetch, LNK and more) from many OS versions. Use them to validate parsers or to compare a suspect artifact with a known clean one from the same version."
    Usage = "Browse C:\git\DFIRArtifactMuseum."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/AndrewRathbun/DFIRArtifactMuseum"
    Vendor = "AndrewRathbun"
    License = "MIT License"
    LicenseUrl = "https://github.com/AndrewRathbun/DFIRArtifactMuseum/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "bmc-tools"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\RDP\bmc-tools.py (RDP Bitmap Cache parser).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command bmc-tools.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "network", "windows")
    Notes = "RDP Bitmap Cache parser"
    Tips = "Parse RDP bitmap cache files from Users\<user>\AppData\Local\Microsoft\Terminal Server Client\Cache. The -b option writes a collage; feed the individual tiles into RdpCacheStitcher to reconstruct what was seen on screen."
    Usage = "bmc-tools.py -s <bcache or cache file or folder> -d <output dir> -b"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/ANSSI-FR/bmc-tools"
    Vendor = "ANSSI-FR"
    License = "CECILL-2.1 License"
    LicenseUrl = "https://github.com/ANSSI-FR/bmc-tools/blob/master/LICENCE.txt"
    PythonVersion = "3.11"
}

$TOOL_DEFINITIONS += @{
    Name = "psexposed"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".ps1")
    Tags = @("windows", "forensics")
    Notes = "Community-driven PowerShell detection indicators"
    Tips = "Community PowerShell detection indicators. Use them as reference when reviewing script block logs (Event ID 4104) or when writing Sigma and YARA rules for PowerShell tradecraft."
    Usage = "Browse C:\git\psexposed for detection indicators."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://www.powershell.exposed"
    Vendor = "avasero"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Incident-Response-Powershell"
    Category = "Incident Response"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("incident-response", "powershell")
    Notes = "PowerShell Digital Forensics & Incident Response Scripts."
    Tips = "Scripts for live collection and triage on Windows hosts. In the sandbox they are mainly useful for review and for parsing collected output; run the collection scripts on the target system, not in the sandbox."
    Usage = "Review the scripts in C:\git\Incident-Response-Powershell and run them on the target host."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/Bert-JanP/Incident-Response-Powershell"
    Vendor = "Bert-JanP"
    License = "BSD 3-Clause License"
    LicenseUrl = "https://github.com/Bert-JanP/Incident-Response-Powershell/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "RdpCacheStitcher"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\RDP\RdpCacheStitcher.lnk"
            Target   = "`${TOOLS}\RdpCacheStitcher\RdpCacheStitcher.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "network", "windows", "disk-forensics")
    Notes = "RdpCacheStitcher is a tool that supports forensic analysts in reconstructing useful images out of RDP cache bitmaps."
    Tips = "Extract tiles with bmc-tools first, then drag tiles into the workspace to reconstruct the screens an attacker saw over RDP. Save the project regularly since large caches take time to work through."
    Usage = "GUI: start from the desktop shortcut and open the tiles extracted with bmc-tools."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/BSI-Bund/RdpCacheStitcher"
    Vendor = "BSI-Bund"
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
    Tags = @("reverse-engineering", "decompiler")
    Notes = "Interactive Delphi Reconstructor"
    Tips = "Load the knowledge base (.kb) matching the Delphi version to recover class names, forms and event handlers. Export the map file and import it into Ghidra or IDA to name functions."
    Usage = "GUI: run C:\git\IDR\bin\Idr.exe and open a Delphi executable."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/crypto2011/IDR"
    Vendor = "crypto2011"
    License = "MIT License"
    LicenseUrl = "https://github.com/crypto2011/IDR/blob/master/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "White-Phoenix"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("ransomware", "decryption", "data-recovery")
    Notes = "A tool to recover content from files encrypted with intermittent encryption"
    Tips = "Works on files hit by intermittent encryption (BlackCat, Play, Qilin, BianLian and similar). Supports PDF, Office, zip based formats and some media; recovery is partial, so triage the most valuable files first."
    Usage = "venv.ps1 -whitephoenix ; White-Phoenix.py -f <encrypted file> -o <output dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/cyberark/White-Phoenix"
    Vendor = "CyberArk"
    License = "Apache License 2.0"
    LicenseUrl = "https://github.com/cyberark/White-Phoenix/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ASL"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\ExeinfoPE.lnk"
            Target   = "`${TOOLS}\exeinfope\exeinfope.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe")
    Tags = @("pe-analysis", "packer-detection")
    Notes = "Detect packer, compiler, protector, .NET obfuscator, PUA application"
    Tips = "Exeinfo PE identifies packers, compilers, protectors and .NET obfuscators and suggests unpacking tools. Compare results with Detect It Easy when the signatures disagree."
    Usage = "GUI: start Exeinfo PE from the desktop shortcut and open an executable."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/ExeinfoASL/ASL"
    Vendor = "A.S.L Soft"
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
    Tags = @("python")
    Notes = "Collection of Jupyter Notebooks by @fr0gger_"
    Tips = "Start JupyterLab from the desktop shortcut and browse to the notebook you want. The notebooks cover malware analysis, threat intelligence and reverse engineering workflows and can be copied to the readwrite folder for editing."
    Usage = "Open the notebooks under C:\git\jupyter-collection in JupyterLab."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://jupyter.securitybreak.io/"
    Vendor = "fr0gger"
    License = "Apache License 2.0"
    LicenseUrl = "https://github.com/fr0gger/jupyter-collection/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Python-dsstore"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\dsstore_parser.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command python `${GIT_PATH}\Python-dsstore\main.py"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".DS_Store")
    Tags = @("forensics", "macos", "data-extraction")
    Notes = "A library for parsing .DS_Store files and extracting file names"
    Tips = "Lists the file names recorded in macOS .DS_Store files, which often reveal directory contents on web servers or in archives created on a Mac."
    Usage = "python C:\git\Python-dsstore\main.py <.DS_Store file>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/gehaxelt/Python-dsstore"
    Vendor = "gehaxelt"
    License = "MIT License"
    LicenseUrl = "https://github.com/gehaxelt/Python-dsstore/blob/master/LICENSE.md"
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
    Tips = "Extra community rules for chainsaw. Use them together with the Sigma rules shipped with chainsaw and review false positives before reporting a hit."
    Usage = "chainsaw hunt <evtx dir> -r C:\git\chainsaw-rules"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/import-pandas-as-numpy/chainsaw-rules"
    Vendor = "import-pandas-as-numpy"
    License = "MIT License"
    LicenseUrl = "https://github.com/import-pandas-as-numpy/chainsaw-rules/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "radare2-deep-graph"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "visualization", "plugins")
    Notes = "A Cutter plugin to generate radare2 graphs."
    Tips = "Copy the plugin into the Cutter plugins directory (Edit -> Preferences -> Plugins shows the path) and restart Cutter to get the deep graph view of function relationships."
    Usage = "Install as a Cutter plugin from C:\git\radare2-deep-graph."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Cutter")
    Homepage = "https://github.com/JavierYuste/radare2-deep-graph"
    Vendor = "JavierYuste"
    License = "GPL-3.0 License"
    LicenseUrl = "https://github.com/JavierYuste/radare2-deep-graph/blob/master/LICENSE"
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
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so")
    Tags = @("reverse-engineering", "ai")
    Notes = "Native AI plugin for radare2. Compiled from source in the MSYS2 sandbox using gcc and pkg-config. Provides AI-assisted analysis using local and remote language models."
    Tips = "Configure an API key or a local model before use. The analysis sandbox is offline, so remote models only work in the network enabled sandbox. See decai for AI assisted decompilation inside radare2."
    Usage = "r2ai -h (inside radare2: r2ai -m to choose a model)"
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
    Tags = @("reverse-engineering", "ai", "decompiler")
    Notes = "r2js plugin for radare2 with special focus on AI-assisted decompilation. Installed by copying decai.r2.js to the radare2 plugins directory."
    Tips = "decai is copied into the radare2 plugins directory at sandbox start. Use 'decai -e api=<provider>' to select the backend and 'decai -d' to decompile the current function; remote backends need the network sandbox."
    Usage = "Inside radare2: decai -h"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Radare2")
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "defender-detectionhistory-parser"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\defender-detectionhistory-parser (dhparser).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dhparser -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "malware-detection", "forensics")
    Notes = "A parser of Windows Defender's DetectionHistory forensic artifact, containing substantial info about quarantined files and executables."
    Tips = "DetectionHistory files live under ProgramData\Microsoft\Windows Defender\Scans\History\Service\DetectionHistory. Use -d for a whole directory and -o to write JSON. maldump extracts the quarantined files themselves."
    Usage = "dhparser -f <DetectionHistory file>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/jklepsercyber/defender-detectionhistory-parser"
    Vendor = "jklepsercyber"
    License = "GPL-3.0 License"
    LicenseUrl = "https://github.com/jklepsercyber/defender-detectionhistory-parser/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Trawler"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\IR\Trawler.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Get-Help trawler"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "malware-analysis", "threat-hunting")
    Notes = "PowerShell script helping Incident Responders discover potential adversary persistence mechanisms."
    Tips = "Trawler hunts persistence on a live system. In the sandbox point it at a mounted image or a KAPE collection with -drivetarget and the hive parameters to review persistence offline; PyrsistenceSniper is the Python alternative."
    Usage = "Get-Help trawler ; trawler -scanoptions All"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/joeavanzato/Trawler"
    Vendor = "joeavanzato"
    License = "MIT License"
    LicenseUrl = "https://github.com/joeavanzato/Trawler/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ToolAnalysisResultSheet"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\ToolAnalysisResultSheet (Summarizes the results of examining logs recorded in Windows upon execution common tools used by attackers that has infiltrated a network).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ToolAnalysisResultSheet.ps1"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("forensics", "documentation", "security-testing")
    Notes = "This repository summarizes the results of examining logs recorded in Windows upon execution of the 49 tools which are likely to be used by the attacker that has infiltrated a network."
    Tips = "Reference material from JPCERT describing the event log, registry and file system traces left by 49 common attacker tools (PsExec, mimikatz, wmic and others). Use it to know which artifacts to look for when a tool is suspected."
    Usage = "ToolAnalysisResultSheet.ps1"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/JPCERTCC/ToolAnalysisResultSheet"
    Vendor = "JPCERTCC"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "iShutdown"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Mobile\iShutdown_detect.py (sysdiagnose_file.tar.gz).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command `${GIT_PATH}\iShutdown\iShutdown_detect.py"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Mobile\iShutdown_parse.py (A tool to extract and parse iOS shutdown logs from a .tar.gz archive).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command `${GIT_PATH}\iShutdown\iShutdown_parse.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Mobile\iShutdown_stats.py (Process an iOS shutdown.log file to create stats on reboots).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command `${GIT_PATH}\iShutdown\iShutdown_stats.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("mobile-forensics", "forensics")
    Notes = "iShutdown scripts: extracts, analyzes, and parses Shutdown.log forensic artifact from iOS Sysdiagnose archives"
    Tips = "Looks for Pegasus style anomalies in the iOS shutdown.log. Run iShutdown_parse.py to extract the log from a sysdiagnose archive and iShutdown_stats.py for reboot statistics."
    Usage = "python C:\git\iShutdown\iShutdown_detect.py <sysdiagnose archive>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/KasperskyLab/iShutdown"
    Vendor = "KasperskyLab"
    License = "Kaspersky"
    LicenseUrl = "https://github.com/KasperskyLab/iShutdown/blob/master/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "EmailAnalyzer"
    Category = "Files and apps\Email"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Email\email-analyzer.py.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command .\email-analyzer.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".eml")
    Tags = @("email", "forensics", "phishing")
    Notes = "With EmailAnalyzer you can analyze your suspicious emails. You can extract headers, links, and hashes from the .eml file and you can generate reports."
    Tips = "Extracts headers, links, attachments and hashes from EML files and can write an HTML report with -o. Pair it with emldump.py from the Didier Stevens suite for deeper MIME inspection."
    Usage = "python C:\git\EmailAnalyzer\email-analyzer.py -f <file.eml> -H -d -l -a"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/keraattin/EmailAnalyzer"
    Vendor = "keraattin"
    License = "GPL-3.0 License"
    LicenseUrl = "https://github.com/keraattin/EmailAnalyzer/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dictionaries"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("password-cracking", "office")
    Notes = "Dictionaries and related code and data for Libreoffice."
    Tips = "LibreOffice dictionaries used by the Notepad++ and VS Code spell checkers. Nothing to run."
    Usage = "Reference data only; used by the spell checkers."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/LibreOffice/dictionaries"
    Vendor = "LibreOffice"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "PowerDecode"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\PowerShell\PowerDecode.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command .\GUI.ps1"
            Icon     = ""
            WorkDir  = "`${GIT_PATH}\PowerDecode"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("powershell", "deobfuscation", "malware-analysis")
    Notes = "PowerDecode is a PowerShell-based tool that allows to deobfuscate PowerShell scripts obfuscated across multiple layers. The tool performs code dynamic analysis, extracting malware hosting URLs and checking http response.It can also detect if the malware attempts to inject shellcode into memory."
    Tips = "Deobfuscates layered PowerShell and extracts URLs and shellcode. Run it in the offline sandbox so URL checks fail safely, or in the network sandbox if you want live HTTP responses; deobshell is the AST based alternative."
    Usage = ".\GUI.ps1 (run from C:\git\PowerDecode)"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/Malandrone/PowerDecode"
    Vendor = "Malandrone"
    License = "GPL-3.0 License"
    LicenseUrl = "https://github.com/Malandrone/PowerDecode/blob/v2.7.2/LICENSE.txt"
    PythonVersion = ""
}

# Flare floss (flare-floss) has its TOOL_DEFINITIONS in release.ps1.

$TOOL_DEFINITIONS += @{
    Name = "gootloader"
    Category = "Malware Analysis"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\Gootloader\Gootloader (Mandiant).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dir"
            Icon     = ""
            WorkDir  = "`${GIT_PATH}\gootloader"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("malware-analysis")
    Notes = "Collection of scripts used to deobfuscate GOOTLOADER malware samples."
    Tips = "The scripts are specific to Gootloader JavaScript loader generations; pick the decoder matching the sample version and follow the README for the extraction workflow."
    Usage = "python C:\git\gootloader\<decoder script>.py <sample.js>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/mandiant/gootloader"
    Vendor = "Mandiant"
    License = "Apache License 2.0"
    LicenseUrl = "https://github.com/mandiant/gootloader/blob/main/LICENSE.txt"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "GoReSym"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Go\GoReSym.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command GoReSym.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "golang")
    Notes = "Go symbol recovery tool"
    Tips = "Recovers Go function names, types, file paths and build info from stripped binaries. Import the JSON into Ghidra with the bundled script or into IDA to rename functions."
    Usage = "GoReSym.exe -t -d -p <go binary> > symbols.json"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/mandiant/GoReSym"
    Vendor = "Mandiant"
    License = "MIT License"
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "gostringungarbler"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Go\gostringungarbler.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command gostringungarbler.py -h"
            Icon     = ""
            WorkDir  = "`${GIT_PATH}\gostringungarbler"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "golang", "deobfuscation")
    Notes = "Python tool to resolve all strings in Go binaries obfuscated by garble."
    Tips = "Recovers strings from Go binaries obfuscated with garble by emulating the decryption routines. Run it from its own venv with venv.ps1 -gostringungarbler if the wrapper fails."
    Usage = "gostringungarbler.py <garbled go binary>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/mandiant/gostringungarbler"
    Vendor = "Mandiant"
    License = "Apache-2.0"
    LicenseUrl = "https://github.com/mandiant/gostringungarbler/blob/main/LICENSE"
    PythonVersion = ""
}

# Speakeasy has its TOOL_DEFINITIONS in install_python_tools.ps1.

$TOOL_DEFINITIONS += @{
    Name = "ese-analyst"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\ese-analyst.lnk"
            Target   = "`${GIT_PATH}\ese-analyst\ese2csv.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${DESKTOP}"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".dat")
    Tags = @("forensics", "windows", "database", "csv")
    Notes = "This is a set of tools for doing forensics analysis on Microsoft ESE databases."
    Tips = "Parses ESE databases such as SRUM (SRUDB.dat), Windows Search (Windows.edb) and WebCacheV01.dat to CSV. Copy the database out of the image first, because ESE files must be writable and may need a repair with esentutl."
    Usage = "GUI: start ese2csv from the desktop shortcut and open an ESE database."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/MarkBaggett/ese-analyst"
    Vendor = "MarkBaggett"
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
    Tags = @("windows", "forensics")
    Notes = "CimSweep is a suite of CIM/WMI-based tools that enable the ability to perform incident response and hunting operations remotely across all versions of Windows."
    Tips = "CIM and WMI based remote collection and hunting. Most useful from the network sandbox against lab hosts or run directly on the target; offline it serves as a reference for the collection functions."
    Usage = "Import-Module C:\git\CimSweep\CimSweep.psd1 ; Get-Command -Module CimSweep"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/mattifestation/CimSweep"
    Vendor = "mattifestation"
    License = "BSD 3-Clause License"
    LicenseUrl = "https://github.com/mattifestation/CimSweep/blob/master/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "malware-bazaar-advanced-search"
    Category = "Malware Analysis"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\Online tools\malware-bazaar-advanced-search (search.py).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command `${GIT_PATH}\malware-bazaar-advanced-search\search.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("malware-analysis", "threat-intelligence")
    Notes = "Script to chain search parameters for MalwareBazaar"
    Tips = "Needs the network sandbox and an abuse.ch auth key. Chains tags, signatures, file types and dates into a single MalwareBazaar query; the malwarebazaar package offers a simpler CLI."
    Usage = "python C:\git\malware-bazaar-advanced-search\search.py -h"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("online")
    Homepage = "https://github.com/montysecurity/malware-bazaar-advanced-search"
    Vendor = "montysecurity"
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
    Tips = "A single broad YARA rule set from Florian Roth designed for quick triage. Expect some false positives and follow up with signature-base for specific detections."
    Usage = "yara C:\git\god-mode-rules\godmode.yar <file or dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/Neo23x0/god-mode-rules"
    Vendor = "Neo23x0"
    License = "Apache 2.0 License"
    LicenseUrl = "https://github.com/Neo23x0/god-mode-rules/blob/master/LICENSE"
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
    Tips = "The YARA rules and IOCs used by Loki and THOR. Some rules need external variables (filename, filepath, extension, filetype); Loki sets them for you, with plain yara pass -d filename=x or exclude those rules."
    Usage = "yara -r C:\git\signature-base\yara <dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/Neo23x0/signature-base"
    Vendor = "Neo23x0"
    License = "Detection Rule License (DRL) 1.1"
    LicenseUrl = "https://github.com/Neo23x0/signature-base?tab=License-1-ov-file"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "scare"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\scare.ps1.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command scare.ps1 -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "emulation", "scripting")
    Notes = "A multi-arch assembly REPL and emulator for your command line."
    Tips = "Interactive assembly REPL with emulation for x86, x64, ARM and other architectures. Ideal for testing shellcode snippets; type /help inside the REPL for the command list."
    Usage = "scare.ps1 -a x64"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/netspooky/scare"
    Vendor = "netspooky"
    License = "GPL 2.0 License"
    LicenseUrl = "https://github.com/netspooky/scare/blob/main/LICENSE.md"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dotnetfile"
    Category = "Programming\dotNET"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\dotNET\dotnetfile_dump.py.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command `${GIT_PATH}\dotnetfile\dotnetfile_dump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("pe-analysis", "dotnet")
    Notes = "dotnetfile is a Common Language Runtime (CLR) header parser library for Windows .NET files built in Python. The CLR header is present in every Windows .NET assembly beside the Portable Executable (PE) header. It stores a plethora of metadata information for the managed part of the file."
    Tips = "Dumps CLR header metadata, streams and metadata tables from .NET assemblies without loading them. Use it to compare against dnSpy or ILSpy when a file refuses to decompile."
    Usage = "python C:\git\dotnetfile\dotnetfile_dump.py <assembly.exe>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/pan-unit42/dotnetfile"
    Vendor = "Unit42"
    License = "MIT License"
    LicenseUrl = "https://github.com/pan-unit42/dotnetfile/blob/main/LICENSE"
    PythonVersion = ""
}

# Fibratus has its TOOL_DEFINITIONS in release.ps1.

$TOOL_DEFINITIONS += @{
    Name = "ai-fs-proxy"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("ai", "filesystem")
    Notes = "IP over filesystem."
    Tips = "Experimental IP over filesystem proxy for moving traffic through the shared readwrite folder. Read the README before use."
    Usage = "See C:\git\ai-fs-proxy\README.md"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/reuteras/ai-fs-proxy"
    Vendor = "reuteras"
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
    Tags = @("forensics")
    Notes = "Sample files to test forensics tools."
    Tips = "Safe sample files for testing parsers and tools in the sandbox; use them to confirm a tool works before pointing it at evidence."
    Usage = "Browse C:\git\dfirws-sample-files."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/reuteras/dfirws-sample-files"
    Vendor = "reuteras"
    License = "MIT"
    LicenseUrl = "https://github.com/reuteras/dfirws-sample-files/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "MSRC"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vulnerability", "windows")
    Notes = "Data from Microsoft patch tuesdays."
    Tips = "Snapshots of Microsoft patch Tuesday data. Used by PatchaPalooza for offline lookups of CVEs and affected products."
    Usage = "Browse C:\git\MSRC."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/reuteras/MSRC"
    Vendor = "reuteras"
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
    Tags = @("reverse-engineering")
    Notes = "Jupyter Plugin for Cutter."
    Tips = "Copy the plugin into the Cutter plugins directory to get a Jupyter console inside Cutter. Requires JupyterLab from the Python tools."
    Usage = "Install as a Cutter plugin from C:\git\cutter-jupyter."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/rizinorg/cutter-jupyter"
    Vendor = "rizinorg"
    License = "GPL-3.0 License"
    LicenseUrl = "https://github.com/rizinorg/cutter-jupyter/blob/master/COPYING"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "EVTX-ATTACK-SAMPLES"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("event-log", "mitre-attack")
    Notes = "Windows Events Attack Samples."
    Tips = "Event log samples for many ATT&CK techniques. Ideal for testing Sigma rules with hayabusa, chainsaw or Zircolite and for learning what an attack looks like in the logs."
    Usage = "hayabusa.exe csv-timeline -d C:\git\EVTX-ATTACK-SAMPLES -o samples.csv"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/sbousseaden/EVTX-ATTACK-SAMPLES"
    Vendor = "sbousseaden"
    License = "GPL-3.0"
    LicenseUrl = "https://github.com/sbousseaden/EVTX-ATTACK-SAMPLES/blob/master/LICENSE.GPL"
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
    Tips = "The old sigmac converter, kept for backends not yet ported to pySigma. Prefer sigma-cli for current rule conversion."
    Usage = "python C:\git\legacy-sigmatools\tools\sigmac -t <backend> <rule.yml>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/SigmaHQ/legacy-sigmatools"
    Vendor = "SigmaHQ"
    License = "LGPL-3.0"
    LicenseUrl = "https://github.com/SigmaHQ/legacy-sigmatools/blob/master/LICENSE.txt"
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
    Tips = "Main Sigma rule repository. Convert rules with sigma-cli using the installed backends (elasticsearch, loki, splunk, sqlite) and pipelines (sysmon, windows), or point hayabusa and chainsaw at the rules directory."
    Usage = "sigma convert -t <backend> -p <pipeline> C:\git\sigma\rules"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://sigmahq.io/"
    Vendor = "SigmaHQ"
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
    Tips = "Ransomware group analysis notes with TTPs, tooling and IOCs. Useful reference when attributing an incident to a known group."
    Usage = "Browse C:\git\Shadow-Pulse."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/StrangerealIntel/Shadow-Pulse"
    Vendor = "StrangerealIntel"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "PowerSponse"
    Category = "Incident Response"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\IR\PowerSponse.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Import-Module `${GIT_PATH}\PowerSponse\PowerSponse.psd1 ; Get-Help -Name Invoke-PowerSponse"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("incident-response", "powershell")
    Notes = "PowerSponse is a PowerShell module focused on targeted containment and remediation during incident response."
    Tips = "Containment and remediation module for remote Windows hosts. It needs network access to the targets, so run it from the network sandbox or from the target environment."
    Usage = "Import-Module C:\git\PowerSponse\PowerSponse.psd1 ; Get-Help Invoke-PowerSponse"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/swisscom/PowerSponse"
    Vendor = "swisscom"
    License = "MIT License"
    LicenseUrl = "https://github.com/swisscom/PowerSponse/blob/master/LICENSE.md"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "HiddenWave"
    Category = "Utilities\CTF"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\CTF\HiddenWave (and ExWave).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dir"
            Icon     = ""
            WorkDir  = "`${GIT_PATH}\HiddenWave"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".waw")
    Tags = @("steganography", "audio", "ctf")
    Notes = "Hide Your Secret Message in any Wave Audio File."
    Tips = "Hides or extracts messages in WAV files. Try ExHiddenWave.py on suspicious audio in CTF style cases; stego-lsb covers the same for PNG and WAV via LSB."
    Usage = "python C:\git\HiddenWave\HiddenWave.py -h"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/techchipnet/HiddenWave"
    Vendor = "techchipnet"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "deobshell"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\PowerShell\deobshell (main.py).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command .\main.py -h"
            Icon     = ""
            WorkDir  = "`${GIT_PATH}\deobshell"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("powershell", "deobfuscation", "malware-analysis")
    Notes = "Powershell script deobfuscation using AST in Python."
    Tips = "Rebuilds obfuscated PowerShell from its AST. Use it after PowerDecode when a script relies on string concatenation and format operators; output goes to stdout so redirect it to a file."
    Usage = "DeobShell is PoC to deobfuscate Powershell using Abstract Syntax Tree (AST) manipulation in Python. The AST is extracted using a Powershell script by calling System.Management.Automation.Language.Parser and writing relevant nodes to an XML file."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/thewhiteninja/deobshell"
    Vendor = "thewhiteninja"
    License = "MIT License"
    LicenseUrl = "https://github.com/thewhiteninja/deobshell/blob/master/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "BlueTuxedo"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "network-analysis", "dns")
    Notes = "A tiny tool built to find and fix common misconfigurations in Active Directory-integrated DNS"
    Tips = "Finds and fixes Active Directory integrated DNS misconfigurations. It needs a domain joined session, so in the sandbox it is mainly for reviewing the checks."
    Usage = "Import-Module C:\git\BlueTuxedo\BlueTuxedo.psd1 ; Invoke-BlueTuxedo"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/jakehildreth/BlueTuxedo"
    Vendor = "jakehildreth"
    License = ""
    LicenseUrl = "https://github.com/jakehildreth/BlueTuxedo/blob/main/LICENSE"
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
    Tips = "Offline copy of the LeechCore wiki describing the memory acquisition devices and file formats supported by MemProcFS."
    Usage = "Browse C:\git\LeechCore.wiki for documentation."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/ufrisk/LeechCore/wiki"
    Vendor = "Ulf Frisk"
    License = "GPL-3.0 License"
    LicenseUrl = ""
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
    Tips = "Offline copy of the MemProcFS wiki. Read the pages on the virtual file system layout and forensic mode before analysing a memory image."
    Usage = "Browse C:\git\MemProcFS.wiki for documentation."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/ufrisk/MemProcFS/wiki"
    Vendor = "Ulf Frisk"
    License = "AGPL-3.0 License"
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
    Tags = @("malware-detection", "threat-intelligence")
    Notes = "The Google Threat Intelligence dev kit is a collection of example code to quickly develop functional integrations with the GTI API, enabling a unified view of the threat landscape and reducing manual effort in threat analysis."
    Tips = "Example integrations for the Google Threat Intelligence API. Requires an API key and the network sandbox."
    Usage = "See the examples in C:\git\gti-dev-kit."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/VirusTotal/gti-dev-kit"
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
    Tags = @("forensics", "office", "data-extraction")
    Notes = "Python library for extracting objects from OneNote files."
    Tips = "Extracts embedded files and images from OneNote notebooks. Compare with pyOneNote and onedump.py when one parser fails on a malformed file."
    Usage = "python -m one_extract <file.one> -o <output dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/volexity/one-extract"
    Vendor = "Volexity"
    License = "BSD-3-Clause License"
    LicenseUrl = "https://github.com/volexity/one-extract/blob/main/LICENSE.md"
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
    Tips = "YARA rules and IOCs from Volexity blog posts, organised by year. Check the matching post for context on a hit."
    Usage = "yara -r C:\git\threat-intel <dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/volexity/threat-intel"
    Vendor = "Volexity"
    License = "BSD-2-Clause License"
    LicenseUrl = ""
    PythonVersion = ""
}

# Zircolite has its TOOL_DEFINITIONS in install_python_tools.ps1.

$TOOL_DEFINITIONS += @{
    Name = "PatchaPalooza"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vulnerability", "windows", "binary-diffing")
    Notes = "A comprehensive tool that provides an insightful analysis of Microsoft's monthly security updates."
    Tips = "Analyses Microsoft security updates by month or CVE. Works offline against the data in C:\git\MSRC, or fetches live data when run in the network sandbox."
    Usage = "python C:\git\PatchaPalooza\PatchaPalooza.py --help"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/reuteras/PatchaPalooza"
    Vendor = "reuteras"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "regipy-mcp-server"
    Homepage = "https://github.com/mkorman90/regipy"
    Vendor = "mkorman90"
    License = "MIT License"
    Category = "OS\Windows\Registry"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".reg", ".dat")
    Tags = @("registry", "windows", "forensics", "mcp")
    Notes = "regipy repository including regipy MCP server for AI-assisted registry analysis."
    Tips = "The regipy MCP server is at C:\\git\\regipy\\regipy_mcp_server\\server.py. It can be used with opencode-ai for AI-assisted registry hive analysis."
    Usage = "Enable the regipy MCP server in opencode.json (see local\defaults\opencode.json)."
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
    Tags = @("windows", "forensics")
    Notes = "This tool extracts and displays data from the Recall feature in Windows 11, providing an easy way to access information about your PC's activity snapshots."
    Tips = "Extracts Windows Recall screenshots and the ukg.db database from a user profile. Copy the CoreAIPlatform.00 folder out of the image and point the script at it with --from_folder."
    Usage = "python C:\git\TotalRecall\totalrecall.py --from_folder <copied CoreAIPlatform.00 folder>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/xaitax/TotalRecall"
    Vendor = "xaitax"
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
    Tips = "The curated Sigma rules used by hayabusa, also usable with other Sigma tools. Keep the checkout current since detections change often."
    Usage = "hayabusa.exe csv-timeline -d <evtx dir> -r C:\git\hayabusa-rules -o timeline.csv"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/Yamato-Security/hayabusa-rules"
    Vendor = "Yamato-Security"
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "MasterParser"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\MasterParser.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command .\MasterParser.ps1 -o Menu"
            Icon     = ""
            WorkDir  = "`${GIT_PATH}\MasterParser"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".log")
    Tags = @("log-analysis", "linux", "security-testing")
    Notes = "MasterParser is a powerful DFIR tool designed for analyzing and parsing Linux logs"
    Tips = "Parses Linux auth, secure, syslog, journal and other logs into CSV and shows a menu of investigation options. Copy the log files out of the Linux image first."
    Usage = ".\MasterParser.ps1 -o Menu (run from C:\git\MasterParser)"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/securityjoes/MasterParser"
    Vendor = "securityjoes"
    License = "MIT"
    LicenseUrl = "https://github.com/securityjoes/MasterParser/blob/main/LICENSE"
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "cutterref"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "documentation", "plugins")
    Notes = "Cutter Instruction Reference Plugin"
    Tips = "Shows the instruction reference documentation for the selected instruction inside Cutter. Copy it into the Cutter plugins directory and restart."
    Usage = "Install as a Cutter plugin from C:\git\cutterref."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Cutter")
    Homepage = "https://github.com/yossizap/cutterref"
    Vendor = "yossizap"
    License = "GPL-2.0 License"
    LicenseUrl = "https://github.com/yossizap/cutterref/blob/master/LICENSE.md"
    PythonVersion = ""
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "git"
