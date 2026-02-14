. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

New-Item -ItemType Directory -Force -Path mount\git | Out-Null
Set-Location mount\git
if (Test-Path .\PatchaPalooza) {
    # Remove PatchaPalooza directory if it exists since we do a local patch
    Remove-Item -Recurse -Force .\PatchaPalooza 2>&1 | Out-Null
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
    "https://github.com/YosfanEilay/AuthLogParser.git", `
    "https://github.com/yossizap/cutterref.git"

foreach ($repourl in $repourls) {
    $repo = Write-Output $repourl | ForEach-Object { $_ -replace "^.*/" } | ForEach-Object { $_ -replace "\.git$" }
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

& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "ASL\exeinfope.zip" -o"..\Tools" | Out-Null

Set-Location ..\..

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
}

$TOOL_DEFINITIONS += @{
    Name = "APT-Hunter"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("event-log", "threat-hunting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "DFIRArtifactMuseum"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "artifacts", "reference")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "bmc-tools"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "rdp")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "psexposed"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "forensics", "psexec")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Incident-Response-Powershell"
    Category = "IR"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("incident-response", "powershell")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "RdpCacheStitcher"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "rdp", "image-reconstruction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "IDR"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "delphi", "decompiler")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "White-Phoenix"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("ransomware", "decryption", "recovery")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ASL"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("pe-analysis", "packer-detection")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jupyter-collection"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("jupyter", "notebook")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Python-dsstore"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "macos", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "chainsaw-rules"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("sigma", "detection-rules")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "radare2-deep-graph"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "visualization")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "defender-detectionhistory-parser"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "defender", "forensics")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Trawler"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "persistence", "threat-hunting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ToolAnalysisResultSheet"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "reference", "lateral-movement")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "iShutdown"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("ios", "forensics", "mobile")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "EmailAnalyzer"
    Category = "Files and apps\Email"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("email", "forensics", "phishing")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Events-Ripper"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("event-log", "forensics", "windows")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "RegRipper4.0"
    Category = "OS\Windows\Registry"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("registry", "forensics", "windows")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PersistenceSniper"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "persistence", "threat-hunting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PersistenceSniper.wiki"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "persistence", "documentation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dictionaries"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("dictionaries", "libreoffice")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PowerDecode"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("powershell", "deobfuscation", "malware-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "flare-floss"
    Category = "Malware tools"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "string-extraction", "malware-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "gootloader"
    Category = "Malware tools"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("malware-analysis", "gootloader")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "GoReSym"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "golang", "symbol-recovery")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "gostringungarbler"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "golang", "deobfuscation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "CapaExplorer"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "capa", "visualization")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ese-analyst"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "ese", "database")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "CimSweep"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "forensics", "wmi")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "malware-bazaar-advanced-search"
    Category = "Malware tools"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("malware-analysis", "threat-intelligence")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "god-mode-rules"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("yara", "sigma", "detection-rules")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "signature-base"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("yara", "detection-rules", "ioc")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "scare"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("assembly", "emulation", "repl")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "capa-explorer"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "capa", "visualization")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dotnetfile"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("pe-analysis", "dotnet")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "fibratus"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "etw", "tracing")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ai-fs-proxy"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("ai", "filesystem")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dfirws-sample-files"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "samples", "testing")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "MSRC"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vulnerability", "microsoft", "security-advisory")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "cutter-jupyter"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "rizin")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "EVTX-ATTACK-SAMPLES"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("event-log", "mitre-attack", "samples")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "legacy-sigmatools"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("sigma", "detection-rules")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "sigma"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("sigma", "detection-rules", "siem")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Shadow-Pulse"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("threat-intelligence", "ioc")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PowerSponse"
    Category = "IR"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("incident-response", "powershell", "containment")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "HiddenWave"
    Category = "Utilities\CTF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("steganography", "audio")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "deobshell"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("powershell", "deobfuscation", "malware-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "BlueTuxedo"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "active-directory", "dns")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "LeechCore.wiki"
    Category = "Memory"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("memory-forensics", "documentation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "MemProcFS.wiki"
    Category = "Memory"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("memory-forensics", "documentation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "gti-dev-kit"
    Category = "Signatures and information\Online tools"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("virustotal", "threat-intelligence")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "one-extract"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "onenote", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "threat-intel"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("threat-intelligence", "ioc")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Zircolite"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("event-log", "sigma", "detection")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PatchaPalooza"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vulnerability", "microsoft", "patch-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "TotalRecall"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("windows", "recall", "forensics")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "hayabusa-rules"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("event-log", "detection-rules", "sigma")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "AuthLogParser"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("log-analysis", "linux", "authentication")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "cutterref"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "rizin", "cheatsheet")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "git"
