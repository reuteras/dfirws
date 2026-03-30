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
    "https://github.com/mari-mari/CapaExplorer.git", `
    "https://github.com/MarkBaggett/ese-analyst.git", `
    "https://github.com/mattifestation/CimSweep.git", `
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
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\reconstructer.org\OfficeMalScanner.zip" -o"..\Tools\" | Out-Null
}

# Extract SmartDeblur
if (Test-Path -Path ".\SmartDeblur\dist\SmartDeblur-1.*-win.zip") {
    if (Test-Path -Path "..\Tools\SmartDeblur") {
        Remove-Item -Force -Recurse "..\Tools\SmartDeblur"
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\SmartDeblur\dist\SmartDeblur-1.*-win.zip" -o"..\Tools\" | Out-Null
    Move-Item ..\Tools\SmartDeblur-* ..\Tools\SmartDeblur
}

& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "ASL\exeinfope.zip" -o"..\Tools" | Out-Null

Set-Location ..\..

$TOOL_DEFINITIONS += @{
    Name = "SmartDeblur"
    Homepage = "https://github.com/y-vladimir/smartdeblur"
    Vendor = "Y. Vladimir"
    License = ""
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
            Expect = "SmartDeblur"
        }
    )
    Notes = "SmartDeblur is a tool for restoring defocused and blurred images. It can be used to recover details from images that are out of focus or have motion blur."
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
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
    Vendor = ""
    Category = "Files and apps\Mobile"
    Notes = "A Windows port of libimobiledevice, a cross-platform library to communicate with iOS devices. It includes tools for extracting data from iOS devices, such as lockdown, idevicebackup2, and more."
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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/ahmedkhlief/APT-Hunter"
    Vendor = "ahmedkhlief"
    License = "GPL-3.0 License"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/AndrewRathbun/DFIRArtifactMuseum"
    Vendor = "AndrewRathbun"
    License = "MIT License"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/ANSSI-FR/bmc-tools"
    Vendor = "ANSSI-FR"
    License = "CECILL-2.1 License"
    LicenseUrl = ""
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
    Category = "Incident Response"
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
    Homepage = "https://github.com/Bert-JanP/Incident-Response-Powershell"
    Vendor = ""
    License = "BSD 3-Clause License"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/crypto2011/IDR"
    Vendor = ""
    License = "MIT License"
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
    Tags = @("ransomware", "decryption", "data-recovery")
    Notes = "A tool to recover content from files encrypted with intermittent encryption"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/cyberark/White-Phoenix"
    Vendor = "CyberArk"
    License = "Apache License 2.0"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://jupyter.securitybreak.io/"
    Vendor = ""
    License = "Apache License 2.0"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/gehaxelt/Python-dsstore"
    Vendor = ""
    License = "MIT License"
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
    Homepage = "https://github.com/import-pandas-as-numpy/chainsaw-rules"
    Vendor = "import-pandas-as-numpy"
    License = "MIT License"
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
    Tags = @("reverse-engineering", "visualization", "plugins")
    Notes = "A Cutter plugin to generate radare2 graphs."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Cutter")
    Homepage = "https://github.com/JavierYuste/radare2-deep-graph"
    Vendor = ""
    License = "GPL-3.0 License"
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
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so")
    Tags = @("reverse-engineering", "ai")
    Notes = "Native AI plugin for radare2. Compiled from source in the MSYS2 sandbox using gcc and pkg-config. Provides AI-assisted analysis using local and remote language models."
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/jklepsercyber/defender-detectionhistory-parser"
    Vendor = ""
    License = "GPL-3.0 License"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/joeavanzato/Trawler"
    Vendor = ""
    License = "MIT License"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/keraattin/EmailAnalyzer"
    Vendor = ""
    License = "GPL-3.0 License"
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
    Tags = @("password-cracking", "office")
    Notes = "Dictionaries and related code and data for Libreoffice."
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/Malandrone/PowerDecode"
    Vendor = ""
    License = "GPL-3.0 License"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/mandiant/gootloader"
    Vendor = "Mandiant"
    License = "Apache License 2.0"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
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

# Speakeasy has its TOOL_DEFINITIONS in install_python_tools.ps1.

$TOOL_DEFINITIONS += @{
    Name = "CapaExplorer"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "malware-analysis", "visualization", "plugins")
    Notes = "Capa analysis importer for Ghidra."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/mari-mari/CapaExplorer"
    Vendor = "mari-mari"
    License = "MIT License"
    LicenseUrl = ""
    PythonVersion = ""
}

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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/mattifestation/CimSweep"
    Vendor = "mattifestation"
    License = "BSD 3-Clause License"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("online")
    Homepage = "https://github.com/montysecurity/malware-bazaar-advanced-search"
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
    Homepage = "https://github.com/Neo23x0/god-mode-rules"
    Vendor = "Neo23x0"
    License = "Apache 2.0 License"
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/netspooky/scare"
    Vendor = ""
    License = "GPL 2.0 License"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/pan-unit42/dotnetfile"
    Vendor = "Unit42"
    License = "MIT License"
    LicenseUrl = ""
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
    Tags = @("forensics")
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
    Tags = @("vulnerability", "windows")
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
    Tags = @("reverse-engineering")
    Notes = "Jupyter Plugin for Cutter."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/rizinorg/cutter-jupyter"
    Vendor = ""
    License = "GPL-3.0 License"
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
    Tags = @("event-log", "mitre-attack")
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
    Category = "Incident Response"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\IR\PowerSponse.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Import-Module ${GIT_PATH}\PowerSponse\PowerSponse.psd1 ; Get-Help -Name Invoke-PowerSponse"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("incident-response", "powershell")
    Notes = "PowerSponse is a PowerShell module focused on targeted containment and remediation during incident response."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/swisscom/PowerSponse"
    Vendor = ""
    License = "MIT License"
    LicenseUrl = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/techchipnet/HiddenWave"
    Vendor = ""
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
    Tips = ""
    Usage = "DeobShell is PoC to deobfuscate Powershell using Abstract Syntax Tree (AST) manipulation in Python. The AST is extracted using a Powershell script by calling System.Management.Automation.Language.Parser and writing relevant nodes to an XML file."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/thewhiteninja/deobshell"
    Vendor = ""
    License = "MIT License"
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
    Tags = @("windows", "network-analysis", "dns")
    Notes = "A tiny tool built to find and fix common misconfigurations in Active Directory-integrated DNS"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/jakehildreth/BlueTuxedo"
    Vendor = ""
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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/volexity/one-extract"
    Vendor = "Volexity"
    License = "BSD-3-Clause License"
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
    Homepage = "https://github.com/volexity/threat-intel"
    Vendor = "Volexity"
    License = "BSD-2-Clause License"
    LicenseUrl = ""
    PythonVersion = ""
}

# Zircolite has its TOOL_DEFINITIONS in release.ps1.

$TOOL_DEFINITIONS += @{
    Name = "PatchaPalooza"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vulnerability", "windows", "binary-diffing")
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
    Tags = @("windows", "forensics")
    Notes = "This tool extracts and displays data from the Recall feature in Windows 11, providing an easy way to access information about your PC's activity snapshots."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/xaitax/TotalRecall"
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/securityjoes/MasterParser"
    Vendor = ""
    License = "MIT"
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
    Tags = @("reverse-engineering", "documentation", "plugins")
    Notes = "Cutter Instruction Reference Plugin"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Cutter")
    Homepage = "https://github.com/yossizap/cutterref"
    Vendor = ""
    License = "GPL-2.0 License"
    LicenseUrl = ""
    PythonVersion = ""
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "git"
