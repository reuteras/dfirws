. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

# artemis
$status = Get-GitHubRelease -repo "puffyCid/artemis" -path "${SETUP_PATH}\artemis.zip" -match "x86_64-pc-windows-msvc.zip$" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\artemis.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\artemis") {
        Remove-Item "${TOOLS}\artemis" -Recurse -Force
    }
    Move-Item ${TOOLS}\artemis-* "${TOOLS}\artemis"
}

$TOOL_DEFINITIONS += @{
    Name = "artemis"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\artemis.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command artemis.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "artemis"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".evtx", ".reg")
    Tags = @("forensics", "artifact-extraction", "triage")
    Notes = "Artemis is a tool for extracting and analyzing Windows artifacts. It can be used for triage and forensic analysis of Windows systems, allowing investigators to quickly gather information about the system and its activity."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# godap
$status = Get-GitHubRelease -repo "Macmod/godap" -path "${SETUP_PATH}\godap.zip" -match "windows-amd64.zip$" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\godap") {
        Remove-Item "${TOOLS}\godap" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\godap.zip" -o"${TOOLS}\godap" | Out-Null
    Move-Item ${TOOLS}\godap-* "${TOOLS}\godap"
}

$TOOL_DEFINITIONS += @{
    Name = "godap"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\godap (LDAP tool).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command godap --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "godap"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("active-directory", "ldap")
    Notes = "godap is a tool for analyzing Active Directory LDAP data."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# BeaconHunter - copied to program files during startup
$status = Get-GitHubRelease -repo "3lp4tr0n/BeaconHunter" -path "${SETUP_PATH}\beaconhunter.zip" -match "BeaconHunter.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\beaconhunter.zip" -o"${TOOLS}\BeaconHunter" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "BeaconHunter"
    Category = "Malware tools\Cobalt Strike"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\BeaconHunter.lnk"
            Target   = "`${env:ProgramFiles}\BeaconHunter\BeaconHunter.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "${env:ProgramFiles}\BeaconHunter\BeaconHunter.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dmp", ".exe", ".dll")
    Tags = @("malware-analysis", "cobalt-strike", "memory-forensics")
    Notes = "Detect and respond to Cobalt Strike beacons using ETW."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# 4n4lDetector - installed in sandbox during startup
$status =  Get-GitHubRelease -repo "4n0nym0us/4n4lDetector" -path "${SETUP_PATH}\4n4lDetector.zip" -match "4n4lDetector" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "4n4lDetector"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\4n4lDetector.lnk"
            Target   = "`${env:ProgramFiles}\4n4lDetector\4N4LDetector.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "${env:ProgramFiles}\4N4LDetector\4N4LDetector.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll")
    Tags = @("malware-analysis", "pe-analysis", "detection")
    Notes = "Advanced static analysis tool"
    Tips = "4n4lDetector is a powerful static analysis tool focused on Microsoft Windows executables, libraries, drivers, and memory dumps, while its integrated modules can analyze virtually any file type with reliable performance and accurate detection.
    
    It performs deep inspection of Portable Executable (PE) structures, sections, headers, and resources to identify anomalies, obfuscation layers, and embedded malicious components. Beyond standard PE analysis, its specialized modules extract and classify strings, metadata, and embedded code from non-PE files, extending its scope to a wide range of binary formats."
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# aLEAPP
$status = Get-GitHubRelease -repo "abrignoni/aLEAPP" -path "${SETUP_PATH}\aleapp.zip" -match "aleapp-.*Windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\aleapp") {
        Remove-Item "${TOOLS}\aleapp" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\aleapp.zip" -o"${TOOLS}\aleapp" | Out-Null
    Copy-Item ${TOOLS}\aleapp\aleapp.exe ${TOOLS}\bin\
    Remove-Item "${TOOLS}\aleapp" -Recurse -Force
}
$status = Get-GitHubRelease -repo "abrignoni/aLEAPP" -path "${SETUP_PATH}\aleappGUI.zip" -match "aleappGUI-.*Windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\aleappGUI") {
        Remove-Item "${TOOLS}\aleappGUI" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\aleappGUI.zip" -o"${TOOLS}\aleappGUI" | Out-Null
    Copy-Item ${TOOLS}\aleappGUI\aleappGUI.exe ${TOOLS}\bin\
    Remove-Item "${TOOLS}\aleappGUI" -Recurse -Force
}

$TOOL_DEFINITIONS += @{
    Name = "aLEAPP"
    Category = "Files and apps\Phone"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Phone\aleapp (Android Logs, Events, and Protobuf Parser).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command aleapp.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Phone\aleappGUI.lnk"
            Target   = "`${TOOLS}\bin\aleappGUI.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "aleapp"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "aleappGUI"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".tar", ".zip")
    Tags = @("mobile-forensics", "android", "artifact-extraction")
    Notes = "ALEAPP is a tool for parsing and analyzing Android logs, events, and protobuf files. It can be used to extract artifacts from Android devices and analyze them in a structured way."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# iLEAPP
$status = Get-GitHubRelease -repo "abrignoni/iLEAPP" -path "${SETUP_PATH}\ileapp.zip" -match "ileapp-.*Windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ileapp") {
        Remove-Item "${TOOLS}\ileapp" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ileapp.zip" -o"${TOOLS}\ileapp" | Out-Null
    Copy-Item ${TOOLS}\ileapp\ileapp.exe ${TOOLS}\bin\
    Remove-Item "${TOOLS}\ileapp" -Recurse -Force
}
$status = Get-GitHubRelease -repo "abrignoni/iLEAPP" -path "${SETUP_PATH}\ileappGUI.zip" -match "ileappGUI-.*Windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ileappGUI") {
        Remove-Item "${TOOLS}\ileappGUI" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ileappGUI.zip" -o"${TOOLS}\ileappGUI" | Out-Null
    Copy-Item ${TOOLS}\ileappGUI\ileappGUI.exe ${TOOLS}\bin\
    Remove-Item "${TOOLS}\ileappGUI" -Recurse -Force
}

$TOOL_DEFINITIONS += @{
    Name = "iLEAPP"
    Category = "Files and apps\Phone"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Phone\ileapp (iOS Logs, Events, And Plists Parser).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ileapp.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Phone\iLEAPPGUI.lnk"
            Target   = "`${TOOLS}\bin\iLEAPPGUI.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "ileapp"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ileappGUI"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".tar", ".zip")
    Tags = @("mobile-forensics", "ios", "artifact-extraction")
    Notes = "iLEAPP is a tool for parsing and analyzing iOS logs, events, and plists. It can be used to extract artifacts from iOS devices and analyze them in a structured way."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# lessmsi
$status = Get-GitHubRelease -repo "activescott/lessmsi" -path "${SETUP_PATH}\lessmsi.zip" -match "lessmsi-v" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\lessmsi") {
        Remove-Item "${TOOLS}\lessmsi" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\lessmsi.zip" -o"${TOOLS}\lessmsi" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "lessmsi"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\lessmsi (A tool to view and extract the contents of a Windows Installer (.msi) file).lnk"
            Target   = "`${TOOLS}\lessmsi\lessmsi-gui.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "lessmsi"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".msi")
    Tags = @("windows", "installer")
    Notes = "lessmsi is a tool to view and extract the contents of a Windows Installer (.msi) file."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# fx
$status = Get-GitHubRelease -repo "antonmedv/fx" -path "${SETUP_PATH}\fx.exe" -match "fx_windows_amd64.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\fx.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "fx"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\fx (Terminal JSON viewer and processor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command fx -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "fx"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".json", ".jsonl")
    Tags = @("json", "data-processing", "visualization")
    Notes = "fx is a terminal JSON viewer and processor."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# CobaltStrikeScan
$status = Get-GitHubRelease -repo "Apr4h/CobaltStrikeScan" -path "${SETUP_PATH}\CobaltStrikeScan.exe" -match "CobaltStrikeScan" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\CobaltStrikeScan.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "CobaltStrikeScan"
    Category = "Malware tools\Cobalt Strike"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\CobaltStrikeScan.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command CobaltStrikeScan.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "CobaltStrikeScan"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".dmp", ".bin")
    Tags = @("malware-analysis", "cobalt-strike", "detection")
    Notes = "Scan files or process memory for CobaltStrike beacons and parse their configuration"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Audacity
$status = Get-GitHubRelease -repo "audacity/audacity" -path "${SETUP_PATH}\audacity.zip" -match "64bit.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\audacity") {
        Remove-Item "${TOOLS}\audacity" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\audacity.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\audacity-* "${TOOLS}\audacity"
}

$TOOL_DEFINITIONS += @{
    Name = "Audacity"
    Category = "Utilities\Media"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Media\Audacity.lnk"
            Target   = "`${TOOLS}\Audacity\audacity.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\Audacity\audacity.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".wav", ".mp3", ".flac", ".ogg", ".aiff")
    Tags = @("audio", "multimedia", "steganography")
    Notes = "Audacity is a free and open-source audio editing software."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Ares
$status = Get-GitHubRelease -repo "bee-san/Ares" -path "${SETUP_PATH}\ares.zip" -match "windows" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ares") {
        Remove-Item "${TOOLS}\ares" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ares.zip" -o"${TOOLS}\ares" | Out-Null
    Copy-Item "${TOOLS}\ares\ares.exe" "${TOOLS}\bin\" -Force
    Remove-Item "${TOOLS}\ares" -Force -Recurse
}

$TOOL_DEFINITIONS += @{
    Name = "Ares"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\ares.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "ares"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll")
    Tags = @("malware-analysis", "pe-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Brim/Zui (Zq) - installed during start
$status =  Get-GitHubRelease -repo "brimdata/zui" -path "${SETUP_PATH}\zui.exe" -match "exe$" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Zui"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Zui (runs dfirws-install -Zui).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Zui"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Zui"
    Verify = @(
        @{
            Type = "command"
            Name = "zui"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pcap", ".pcapng", ".zng")
    Tags = @("network-analysis", "pcap", "zeek")
    Notes = "Zui is a tool for analyzing network traffic. It can read pcap and zng files and provides a powerful query language for analyzing the data."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# RDPCacheStitcher
$status = Get-GitHubRelease -repo "BSI-Bund/RdpCacheStitcher" -path "${SETUP_PATH}\RdpCacheStitcher.zip" -match "win64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\RdpCacheStitcher.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\RdpCacheStitcher") {
        Remove-Item "${TOOLS}\RdpCacheStitcher" -Recurse -Force
    }
    Move-Item ${TOOLS}\RdpCacheStitcher_* "${TOOLS}\RdpCacheStitcher"
}

$TOOL_DEFINITIONS += @{
    Name = "RDPCacheStitcher"
    Category = "Files and apps\RDP"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\RDP\RdpCacheStitcher.lnk"
            Target   = "`${TOOLS}\RdpCacheStitcher\RdpCacheStitcher.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\RdpCacheStitcher\RdpCacheStitcher.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".bmc", ".bin")
    Tags = @("rdp", "forensics", "windows")
    Notes = "RdpCacheStitcher is a tool for analyzing RDP cache files."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# ffmpeg
$status = Get-GitHubRelease -repo "BtbN/FFmpeg-Builds" -path "${SETUP_PATH}\ffmpeg.zip" -match "win64-gpl-7" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ffmpeg") {
        Remove-Item "${TOOLS}\ffmpeg" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ffmpeg.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\ffmpeg-* "${TOOLS}\ffmpeg"
}

$TOOL_DEFINITIONS += @{
    Name = "ffmpeg"
    Category = "Utilities\Media"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Media\ffmpeg.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ffmpeg --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "ffmpeg"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".mp4", ".avi", ".mkv", ".mov", ".mp3", ".wav", ".flac")
    Tags = @("multimedia", "video", "audio", "conversion")
    Notes = "ffmpeg is a free and open-source multimedia framework for processing video and audio files. It can be used to convert between different formats, extract audio from video files, and perform various other multimedia processing tasks."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# ripgrep
$status = Get-GitHubRelease -repo "BurntSushi/ripgrep" -path "${SETUP_PATH}\ripgrep.zip" -match "x86_64-pc-windows-msvc.zip$" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ripgrep") {
        Remove-Item "${TOOLS}\ripgrep" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ripgrep.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\ripgrep-* "${TOOLS}\ripgrep"
}

$TOOL_DEFINITIONS += @{
    Name = "ripgrep"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\ripgrep (rg).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command rg -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "rg"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("search", "grep", "cli")
    Notes = "ripgrep is a fast, modern, and user-friendly command-line search tool."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# binlex
$status = Get-GitHubRelease -repo "c3rb3ru5d3d53c/binlex" -path "${SETUP_PATH}\binlex.zip" -match "windows" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\binlex.zip" -o"${TOOLS}\bin" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "binlex"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\binlex (A Binary Genetic Traits Lexer).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command binlex.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "binlex"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf", ".bin")
    Tags = @("malware-analysis", "binary-analysis", "similarity")
    Notes = "binlex is a binary genetic traits lexer for malware analysis."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# cmder - installed during start
$status =  Get-GitHubRelease -repo "cmderdev/cmder" -path "${SETUP_PATH}\cmder.7z" -match "cmder.7z" -check "7-zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "cmder"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -CMDer"
    Verify = @(
        @{
            Type = "command"
            Name = "Cmder"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("terminal", "shell")
    Notes = "Cmder is a console emulator for Windows."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Recaf
$status = Get-GitHubRelease -repo "Col-E/Recaf" -path "${SETUP_PATH}\recaf.jar" -match "jar-with-dependencies.jar" -check "Java archive data \(JAR\)"
if ($status) {
    Copy-Item ${SETUP_PATH}\recaf.jar ${TOOLS}\lib\recaf.jar
    Set-Content -Encoding Ascii -Path "${TOOLS}\bin\recaf.bat" "@echo off`njava --module-path ${SANDBOX_TOOLS}\javafx-sdk\lib --add-modules javafx.controls -jar C:\Tools\lib\recaf.jar"
}

$TOOL_DEFINITIONS += @{
    Name = "Recaf"
    Category = "Programming\Java"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Java\recaf (The modern Java bytecode editor).lnk"
            Target   = "`${TOOLS}\bin\recaf.bat"
            Args     = "`${CLI_TOOL_ARGS} -command recaf.bat"
            Icon     = "`${TOOLS}\lib\recaf.jar"
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".class", ".jar")
    Tags = @("reverse-engineering", "java", "decompiler", "deobfuscation")
    Notes = "Recaf is a modern Java bytecode editor."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# DBeaver
$status = Get-GitHubRelease -repo "dbeaver/dbeaver" -path "${SETUP_PATH}\dbeaver.zip" -match "win32.win32.x86_64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\dbeaver") {
        Remove-Item "${TOOLS}\dbeaver" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dbeaver.zip" -o"${TOOLS}" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "DBeaver"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\dbeaver (runs dfirws-install -DBeaver).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -DBeaver"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Dbeaver"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\dbeaver\dbeaver.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".db", ".sqlite", ".sqlite3", ".sql")
    Tags = @("database", "gui")
    Notes = "DBeaver is a database management tool."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Dumpbin from Visual Studio
$status = Get-GitHubRelease -repo "Delphier/dumpbin" -path "${SETUP_PATH}\dumpbin.zip" -match "dumpbin" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\dumpbin") {
        Remove-Item "${TOOLS}\dumpbin" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dumpbin.zip" -o"${TOOLS}\dumpbin" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Dumpbin"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\dumpbin (Microsoft COFF Binary File Dumper).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dumpbin.exe"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "dumpbin"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".obj", ".lib")
    Tags = @("pe-analysis", "reverse-engineering")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# dnSpy 32-bit and 64-bit
$status = Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "${SETUP_PATH}\dnSpy32.zip" -match "win32" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\dnSpy32") {
        Remove-Item "${TOOLS}\dnSpy32" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dnSpy32.zip" -o"${TOOLS}\dnSpy32" | Out-Null
}
$status = Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "${SETUP_PATH}\dnSpy64.zip" -match "win64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\dnSpy64") {
        Remove-Item "${TOOLS}\dnSpy64" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dnSpy64.zip" -o"${TOOLS}\dnSpy64" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "dnSpy"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy32.lnk"
            Target   = "`${TOOLS}\dnSpy32\dnSpy.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy64.lnk"
            Target   = "`${TOOLS}\dnSpy64\dnSpy.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\dnSpy64\bin\dnSpy.dll"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("dotnet", "debugging", "reverse-engineering")
    Notes = "dnSpy is a .NET debugger and decompiler. It can be used to analyze and debug .NET applications, including malware."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("dotnet6")
}

# Dokany - available for manual installation
$status =  Get-GitHubRelease -repo "dokan-dev/dokany" -path "${SETUP_PATH}\dokany.msi" -match "Dokan_x64.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "Dokany"
    Category = "Memory"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Memory\Dokany (runs dfirws-install -Dokany).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Dokany"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Dokany"
    Verify = @()
    FileExtensions = @()
    Tags = @("filesystem", "mounting")
    Notes = "User mode file system library for windows with FUSE Wrapper"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# mboxviewer
$status = Get-GitHubRelease -repo "eneam/mboxviewer" -path "${SETUP_PATH}\mboxviewer.zip" -match "mbox-viewer.exe" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\mboxviewer") {
        Remove-Item "${TOOLS}\mboxviewer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mboxviewer.zip" -o"${TOOLS}\mboxviewer" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "mboxviewer"
    Category = "Files and apps\Email"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Email\Mbox Viewer.lnk"
            Target   = "`${TOOLS}\mboxviewer\mboxview64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\mboxviewer\mboxview64.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".mbox", ".eml")
    Tags = @("email", "forensics")
    Notes = "A small but powerful app for viewing MBOX files."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# zstd
$status = Get-GitHubRelease -repo "facebook/zstd" -path "${SETUP_PATH}\zstd.zip" -match "win64.zip$" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\downloads\zstd.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\zstd") {
        Remove-Item "${TOOLS}\zstd" -Recurse -Force
    }
    Move-Item ${TOOLS}\zstd-* "${TOOLS}\zstd" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "zstd"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\zstd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command zstd -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "zstd"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".zst")
    Tags = @("compression", "decompression", "cli")
    Notes = "Zstandard is a fast lossless compression algorithm."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# CyberChef
$status = Get-GitHubRelease -repo "gchq/CyberChef" -path "${SETUP_PATH}\CyberChef.zip" -match "CyberChef" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\CyberChef") {
        Remove-Item "${TOOLS}\CyberChef" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\CyberChef.zip" -o"${TOOLS}\CyberChef" | Out-Null
    if (Test-Path "${TOOLS}\CyberChef\CyberChef.html") {
        Remove-Item "${TOOLS}\CyberChef\CyberChef.html" -Force
    }
    Move-Item "${TOOLS}\CyberChef\CyberChef_*" "${TOOLS}\CyberChef\CyberChef.html"

    Add-Type -AssemblyName System.Drawing
    ConvertTo-Icon -bitmapPath "${PWD}\${TOOLS}\CyberChef\images\cyberchef-128x128.png" -iconPath "${PWD}\${TOOLS}\CyberChef\CyberChef.ico"
}

$TOOL_DEFINITIONS += @{
    Name = "CyberChef"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\CyberChef.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".bin", ".txt", ".json", ".hex")
    Tags = @("data-processing", "encoding", "decoding", "deobfuscation", "encryption", "hashing")
    Notes = "CyberChef is a web app for data processing and analysis. It provides a wide range of operations for encoding, decoding, encrypting, decrypting, and analyzing data."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# redress
$status = Get-GitHubRelease -repo "goretk/redress" -path "${SETUP_PATH}\redress.zip" -match "windows.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\redress.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\redress") {
        Remove-Item "${TOOLS}\redress" -Recurse -Force
    }
    Move-Item ${TOOLS}\redress-* ${TOOLS}\redress
}

$TOOL_DEFINITIONS += @{
    Name = "redress"
    Category = "Programming\Go"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Go\Redress.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Redress.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "redress"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".elf")
    Tags = @("reverse-engineering", "golang")
    Notes = "Redress - A tool for analyzing stripped Go binaries."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# h2database - available for manual installation
$status = Get-GitHubRelease -repo "h2database/h2database" -path "${SETUP_PATH}\h2database.zip" -match "bundle.jar" -check "Java archive data"
if ($status) {
    if (Test-Path "${TOOLS}\h2database") {
        Remove-Item "${TOOLS}\h2database" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\h2database.zip" -o"${TOOLS}\h2database" | Out-Null
}
$status = Get-GitHubRelease -repo "h2database/h2database" -path "${SETUP_PATH}\h2.pdf" -match "h2.pdf"
if ($status) {
    Copy-Item ${SETUP_PATH}\h2.pdf ${TOOLS}\h2database
}

$TOOL_DEFINITIONS += @{
    Name = "h2database"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\h2 database.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${TOOLS}\h2database"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".h2.db")
    Tags = @("database", "java")
    Notes = "H2 Database is an open source Java SQL database."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# INDXRipper
$status = Get-GitHubRelease -repo "harelsegev/INDXRipper" -path "${SETUP_PATH}\indxripper.zip" -match "amd64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\INDXRipper") {
        Remove-Item "${TOOLS}\INDXRipper" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\indxripper.zip" -o"${TOOLS}\INDXRipper" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "INDXRipper"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\INDXRipper.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command INDXRipper.exe -h"
            Icon     = "`${TOOLS}\INDXRipper\INDXRipper.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "INDXRipper"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".bin")
    Tags = @("ntfs", "filesystem", "forensics", "metadata")
    Notes = "Carve file metadata from NTFS index (`$I30) attributes"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# dll_to_exe
$status = Get-GitHubRelease -repo "hasherezade/dll_to_exe" -path "${SETUP_PATH}\dll_to_exe.exe" -match "dll_to_exe.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\dll_to_exe.exe ${TOOLS}\bin
}

$TOOL_DEFINITIONS += @{
    Name = "dll_to_exe"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "dll_to_exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dll", ".exe")
    Tags = @("pe-analysis", "conversion")
    Notes = "Converts a DLL into EXE"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# HollowsHunter
$status = Get-GitHubRelease -repo "hasherezade/hollows_hunter" -path "${SETUP_PATH}\hollows_hunter.exe" -match "hollows_hunter64.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\hollows_hunter.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "HollowsHunter"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\hollows_hunter (Scans running processes. Recognizes and dumps a variety of in-memory implants).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command hollows_hunter.exe /help"
            Icon     = "`${TOOLS}\bin\hollows_hunter.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "hollows_hunter"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".dmp")
    Tags = @("malware-analysis", "pe-analysis", "process-injection")
    Notes = "Scans running processes. Recognizes and dumps a variety of in-memory implants"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# PE-bear
$status = Get-GitHubRelease -repo "hasherezade/pe-bear" -path "${SETUP_PATH}\pebear.zip" -match "x64_win_vs19.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\pebear") {
        Remove-Item "${TOOLS}\pebear" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pebear.zip" -o"${TOOLS}\pebear" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "PE-bear"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\PE-bear.lnk"
            Target   = "`${TOOLS}\pebear\PE-bear.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "PE-bear"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".sys")
    Tags = @("pe-analysis", "reverse-engineering")
    Notes = "A tool for analyzing PE files"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# PE-sieve
$status = Get-GitHubRelease -repo "hasherezade/pe-sieve" -path "${SETUP_PATH}\pe-sieve.exe" -match "pe-sieve64.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\pe-sieve.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "PE-sieve"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\PE-sieve (Scans a given process, recognizes and dumps a variety of in-memory implants).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pe-sieve.exe /help"
            Icon     = "`${TOOLS}\bin\pe-sieve.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "pe-sieve"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll")
    Tags = @("pe-analysis", "malware-analysis", "process-injection")
    Notes = "Scans a given process. Recognizes and dumps a variety of potentially malicious implants (replaced/injected PEs, shellcodes, hooks, in-memory patches)."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# PE-utils
$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\dll_load32.exe" -match "dll_load32.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\dll_load32.exe ${TOOLS}\bin\
}
$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\dll_load64.exe" -match "dll_load64.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\dll_load64.exe ${TOOLS}\bin\
}
$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\kdb_check.exe" -match "kdb_check.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\kdb_check.exe ${TOOLS}\bin\
}
$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\pe_check.exe" -match "pe_check.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\pe_check.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "PE-utils"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "pescan"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".sys")
    Tags = @("pe-analysis", "reverse-engineering")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# WinObjEx64
$status = Get-GitHubRelease -repo "hfiref0x/WinObjEx64" -path "${SETUP_PATH}\WinObjEx64.zip" -match "WinobjEx64.*[0-9].zip" -check "Zip archive data"
$plugin_status = Get-GitHubRelease -repo "hfiref0x/WinObjEx64" -path "${SETUP_PATH}\WinObjEx64_plugins.zip" -match "WinobjEx64.*plugins.zip" -check "Zip archive data"
if ($status -or $plugin_status) {
    if (Test-Path "${TOOLS}\WinObjEx64") {
        Remove-Item "${TOOLS}\WinObjEx64" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\WinObjEx64.zip" -o"${TOOLS}\WinObjEx64" | Out-Null
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\WinObjEx64_plugins.zip" -o"${TOOLS}\WinObjEx64" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "WinObjEx64"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\WinObjEx64.lnk"
            Target   = "`${TOOLS}\WinObjEx64\WinObjEx64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "WinObjEx64"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("windows", "kernel", "debugging")
    Notes = "WinObjEx64 is an advanced utility that lets you explore the Windows Object Manager namespace."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Detect It Easy
$status = Get-GitHubRelease -repo "horsicq/DIE-engine" -path "${SETUP_PATH}\die.zip" -match "die_win64_portable" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\die") {
        Remove-Item "${TOOLS}\die" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\die.zip" -o"${TOOLS}\die" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Detect It Easy"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Detect It Easy (determining types of files).lnk"
            Target   = "`${TOOLS}\die\die.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "die"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "diec"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf", ".mach-o", ".bin")
    Tags = @("pe-analysis", "file-identification", "packer-detection")
    Notes = "Detect It Easy is a tool for identifying file types and detecting packers."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# XELFViewer
$status = Get-GitHubRelease -repo "horsicq/XELFViewer" -path "${SETUP_PATH}\XELFViewer.zip" -match "win64_portable" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\XELFViewer") {
        Remove-Item "${TOOLS}\XELFViewer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\XELFViewer.zip" -o"${TOOLS}\XELFViewer" | Out-Null
    if (Test-Path "${CONFIGURATION_FILES}\xelfviewer.ini") {
        Copy-Item "${CONFIGURATION_FILES}\xelfviewer.ini" "${TOOLS}\XELFViewer\xelfviewer.ini"
    } else {
        Copy-Item "${CONFIGURATION_FILES}\defaults\xelfviewer.ini" "${TOOLS}\XELFViewer\xelfviewer.ini"
    }
}

$TOOL_DEFINITIONS += @{
    Name = "XELFViewer"
    Category = "OS\Linux"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Linux\xelfviewer.lnk"
            Target   = "`${TOOLS}\XELFViewer\xelfviewer.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\XELFViewer\xelfviewer.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".elf", ".mach-o")
    Tags = @("reverse-engineering", "elf-analysis")
    Notes = "ELF file viewer/editor for Windows, Linux and MacOS."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# jd-gui
$status = Get-GitHubRelease -repo "java-decompiler/jd-gui" -path "${SETUP_PATH}\jd-gui.zip" -match "jd-gui-windows" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\jd-gui.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\jd-gui") {
        Remove-Item "${TOOLS}\jd-gui" -Recurse -Force
    }
    Move-Item ${TOOLS}\jd-gui* "${TOOLS}\jd-gui"
}

$TOOL_DEFINITIONS += @{
    Name = "jd-gui"
    Category = "Programming\Java"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Java\jd-gui.lnk"
            Target   = "`${TOOLS}\jd-gui\jd-gui.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "jd-gui"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".class", ".jar")
    Tags = @("reverse-engineering", "java", "decompiler")
    Notes = "A standalone Java Decompiler GUI"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# LogBoost
$status = Get-GitHubRelease -repo "joeavanzato/logboost" -path "${SETUP_PATH}\logboost.rar" -match "logboost_release" -check "RAR archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\logboost.rar" -o"${TOOLS}\logboost" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "LogBoost"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\logboost (runs dfirws-install -LogBoost).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -LogBoost"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -LogBoost"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\LogBoost\LogBoost.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".evtx", ".csv", ".json")
    Tags = @("log-analysis", "event-log")
    Notes = "Convert a variety of log formats to CSV while enriching detected IPs with Geolocation, ASN, DNS, WhoIs, Shodan InternetDB and Threat Indicator matches."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# jq
$status = Get-GitHubRelease -repo "jqlang/jq" -path "${SETUP_PATH}\jq.exe" -match "win64" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\jq.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "jq"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\jq ( commandline JSON processor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command jq -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "jq"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".json", ".ndjson", ".jsonl")
    Tags = @("json", "data-processing", "cli")
    Notes = "jq is a powerful command-line JSON processor that allows you to parse, filter, and manipulate JSON data with ease. It supports a wide range of operations, including selecting specific fields, transforming data, and performing complex queries. With its simple syntax and extensive functionality, jq is an essential tool for anyone working with JSON data in the command line."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Jumplist Browser
$status = Get-GitHubRelease -repo "kacos2000/Jumplist-Browser" -path "${SETUP_PATH}\JumplistBrowser.exe" -match "JumplistBrowser.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\JumplistBrowser.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "Jumplist Browser"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Jumplist-Browser.lnk"
            Target   = "`${TOOLS}\bin\JumplistBrowser.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "JumplistBrowser"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".automaticDestinations-ms", ".customDestinations-ms", ".lnk")
    Tags = @("windows", "forensics", "artifact-extraction")
    Notes = "Automatic/Custom Destinations & LNK (MS-SHLLINK) Browser"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# MFTBrowser
$status = Get-GitHubRelease -repo "kacos2000/MFT_Browser" -path "${SETUP_PATH}\MFTBrowser.exe" -match "MFTBrowser.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\MFTBrowser.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "MFTBrowser"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\MFTBrowser.lnk"
            Target   = "`${TOOLS}\bin\MFTBrowser.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "MFTBrowser"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".mft")
    Tags = @("ntfs", "filesystem", "forensics")
    Notes = "`$MFT directory tree reconstruction & FILE record info"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Prefetch Browser
$status = Get-GitHubRelease -repo "kacos2000/Prefetch-Browser" -path "${SETUP_PATH}\PrefetchBrowser.exe" -match "PrefetchBrowser.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\PrefetchBrowser.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "Prefetch Browser"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Prefetch-Browser.lnk"
            Target   = "`${TOOLS}\bin\PrefetchBrowser.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "PrefetchBrowser"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pf")
    Tags = @("windows", "forensics", "prefetch")
    Notes = "Prefetch Browser is a tool for analyzing Windows Prefetch files, which can provide valuable information about program execution and system activity."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# bytecode-viewer
$status = Get-GitHubRelease -repo "Konloch/bytecode-viewer" -path "${SETUP_PATH}\BCV.jar" -match "Bytecode" -check "Java archive data"
if ($status) {
    Copy-Item ${SETUP_PATH}\BCV.jar ${TOOLS}\lib
    Write-Output "java -Xmx3G -jar C:\Tools\lib\BCV.jar" | Out-File -Encoding "ascii" ${TOOLS}\bin\bcv.bat
}

$TOOL_DEFINITIONS += @{
    Name = "bytecode-viewer"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Bytecode Viewer.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${POWERSHELL_EXE} -w hidden -command `${TOOLS}\bin\bcv.bat"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".class", ".jar", ".apk", ".dex")
    Tags = @("reverse-engineering", "java", "decompiler", "deobfuscation")
    Notes = "A Java 8+ Jar & Android APK Reverse Engineering Suite (Decompiler, Editor, Debugger & More)"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# gftrace
$status = Get-GitHubRelease -repo "leandrofroes/gftrace" -path "${SETUP_PATH}\gftrace.zip" -match "gftrace64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\gftrace64") {
        Remove-Item "${TOOLS}\gftrace64" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\gftrace.zip" -o"${TOOLS}" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "gftrace"
    Category = "Programming\Go"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Go\gftrace.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command gftrace"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\gftrace64\gftrace.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe")
    Tags = @("reverse-engineering", "api-tracing", "golang")
    Notes = "A command line Windows API tracing tool for Golang binaries."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# adalanche
$status = Get-GitHubRelease -repo "lkarlslund/adalanche" -path "${SETUP_PATH}\adalanche.exe" -match "adalanche-windows-x64" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\adalanche.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "adalanche"
    Category = "OS\Windows\Active Directory (AD)"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\adalanche (Active Directory ACL Visualizer and Explorer).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command adalanche.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "adalanche"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("active-directory", "attack-path", "visualization")
    Notes = "Attack Graph Visualizer and Explorer (Active Directory) ...Who's *really* Domain Admin?"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# MsgViewer
$status = Get-GitHubRelease -repo "lolo101/MsgViewer" -path "${SETUP_PATH}\msgviewer.jar" -match "msgviewer.jar" -check "Java archive data"
if ($status) {
    Copy-Item ${SETUP_PATH}\msgviewer.jar ${TOOLS}\lib
}

$TOOL_DEFINITIONS += @{
    Name = "MsgViewer"
    Category = "Files and apps\Email"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Email\msgviewer.lnk"
            Target   = "`${TOOLS}\lib\msgviewer.jar"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".msg")
    Tags = @("email", "forensics", "outlook")
    Notes = "A tool for viewing and analyzing Outlook MSG files."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# capa
$status = Get-GitHubRelease -repo "mandiant/capa" -path "${SETUP_PATH}\capa-windows.zip" -match "windows" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\capa") {
        Remove-Item "${TOOLS}\capa" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\capa-windows.zip" -o"${TOOLS}\capa" | Out-Null
}
# Temporary get Capa version 6.0.0 until the issue with the latest version not working with
# capaexplorer for Ghidra is fixed.
$status = Get-FileFromUri -uri "https://github.com/mandiant/capa/releases/download/v6.0.0/capa-v6.0.0-windows.zip" -FilePath "${SETUP_PATH}\capa-ghidra.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\capa-ghidra") {
        Remove-Item "${TOOLS}\capa-ghidra" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\capa-ghidra.zip" -o"${TOOLS}\capa-ghidra" | Out-Null
    if (Test-Path "${TOOLS}\capa-ghidra\capa-ghidra.exe") {
        Remove-Item "${TOOLS}\capa-ghidra\capa-ghidra.exe" -Force
    }
    Move-Item ${TOOLS}\capa-ghidra\capa.exe ${TOOLS}\capa-ghidra\capa-ghidra.exe
}

$TOOL_DEFINITIONS += @{
    Name = "capa"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\capa.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command capa.exe -h"
            Icon     = "`${TOOLS}\capa\capa.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "capa"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "`${TOOLS}\capa\capa.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe")
    Tags = @("malware-analysis", "capability-discovery", "pe-analysis", "reverse-engineering", "mitre-att&ck")
    Notes = "capa rules for identifying capabilities in binaries."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# capa-rules
$status = Get-GitHubRelease -repo "mandiant/capa-rules" -path "${SETUP_PATH}\capa-rules.zip" -match "Source" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\capa-rules.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\capa-rules") {
        Remove-Item "${TOOLS}\capa-rules" -Recurse -Force
    }
    Move-Item ${TOOLS}\mandiant-capa-rules-* "${TOOLS}\capa-rules"
}

$TOOL_DEFINITIONS += @{
    Name = "capa-rules"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Folder for Ghidra extensions
if (! (Test-Path "${TOOLS}\ghidra_extensions")) {
    New-Item -Path "${TOOLS}\ghidra_extensions" -ItemType Directory | Out-Null
}

# GolangAnalyzerExtension for latest installed Ghidra version
$GHIDRA_DIR_NAME = (Get-ChildItem "${TOOLS}\ghidra\").Name | findstr.exe PUBLIC | Select-Object -Last 1
if ($GHIDRA_DIR_NAME -match 'ghidra_(.+?)_PUBLIC') {
    $GHIDRA_VERSION = $Matches[1]
    $status = Get-GitHubRelease -repo "mooncat-greenpy/Ghidra_GolangAnalyzerExtension" -path "${SETUP_PATH}\GolangAnalyzerExtension_${GHIDRA_VERSION}.zip" -match "${GHIDRA_VERSION}_" -check "Zip archive data"
    if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_${GHIDRA_VERSION}.zip")) {
        Copy-Item "${SETUP_PATH}\GolangAnalyzerExtension_${GHIDRA_VERSION}.zip" "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_${GHIDRA_VERSION}.zip"
    }
}

$TOOL_DEFINITIONS += @{
    Name = "Ghidra GolangAnalyzerExtension"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".elf")
    Tags = @("reverse-engineering", "golang")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Ghidra")
}

# Microsoft PowerShell
$status = Get-GitHubRelease -repo "PowerShell/PowerShell" -path "${SETUP_PATH}\pwsh.zip" -match "win-x64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\pwsh") {
        Remove-Item "${TOOLS}\pwsh" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pwsh.zip" -o"${TOOLS}\pwsh" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "PowerShell"
    Category = "Programming\PowerShell"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".ps1", ".psm1", ".psd1")
    Tags = @("scripting", "shell", "automation")
    Notes = "PowerShell is a task automation and configuration management framework from Microsoft."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Ghidra btighidra
$status = Get-GitHubRelease -repo "trailofbits/BTIGhidra" -path "${SETUP_PATH}\btighidra.zip" -match "ghidra" -check "Zip archive data"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\btighidra.zip")) {
    Copy-Item "${SETUP_PATH}\btighidra.zip" "${TOOLS}\ghidra_extensions\btighidra.zip"
}

$TOOL_DEFINITIONS += @{
    Name = "Ghidra BTIGhidra"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so")
    Tags = @("reverse-engineering", "disassembler", "decompiler")
    Notes = "Binary Type Inference Ghidra Plugin"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Ghidra")
}

# Ghidra Cartographer plugin
$status = Get-GitHubRelease -repo "nccgroup/Cartographer" -path "${SETUP_PATH}\Cartographer.zip" -match "Cartographer.zip" -check "Zip archive data"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\Cartographer.zip")) {
    Copy-Item "${SETUP_PATH}\Cartographer.zip" "${TOOLS}\ghidra_extensions\Cartographer.zip"
}

$TOOL_DEFINITIONS += @{
    Name = "Ghidra Cartographer"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so")
    Tags = @("reverse-engineering", "disassembler", "visualization")
    Notes = "Code Coverage Exploration Plugin for Ghidra."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Ghidra")
}

# GhidrAssistMCP - MCP server extension for Ghidra
$status = Get-GitHubRelease -repo "jtang613/GhidrAssistMCP" -path "${SETUP_PATH}\GhidrAssistMCP.zip" -match "\.zip$" -check "Zip archive data"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\GhidrAssistMCP.zip")) {
    Copy-Item "${SETUP_PATH}\GhidrAssistMCP.zip" "${TOOLS}\ghidra_extensions\GhidrAssistMCP.zip"
}

$TOOL_DEFINITIONS += @{
    Name = "Ghidra GhidrAssistMCP"
    Homepage = "https://github.com/jtang613/GhidrAssistMCP"
    Vendor = "jtang613"
    License = "MIT License"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so")
    Tags = @("reverse-engineering", "mcp", "ai", "ghidra")
    Notes = "Ghidra extension implementing MCP server for AI-assisted reverse engineering. Enable in Ghidra via File > Configure > Configure Plugins. Server runs on localhost:8080 by default."
    Tips = "Start the MCP server from Window > GhidrAssistMCP in Ghidra. Connect opencode-ai or other MCP clients to http://localhost:8080/sse."
    Usage = "Install extension in Ghidra, enable plugin, start MCP server, then connect AI tools."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Ghidra")
}

# Flare-Floss
$status = Get-GitHubRelease -repo "mandiant/flare-floss" -path "${SETUP_PATH}\floss.zip" -match "windows" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\floss") {
        Remove-Item "${TOOLS}\floss" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\floss.zip" -o"${TOOLS}\floss" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Flare-Floss"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\floss.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command venv.ps1 -floss ; floss --help"
            Icon     = "`${TOOLS}\floss\floss.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "floss"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".bin")
    Tags = @("malware-analysis", "string-extraction", "deobfuscation")
    Notes = "Flare-Floss is a tool for extracting strings from malware samples."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Flare-Fakenet-NG
$status = Get-GitHubRelease -repo "mandiant/flare-fakenet-ng" -path "${SETUP_PATH}\fakenet.zip" -match "fakenet" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fakenet.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\fakenet") {
        Remove-Item "${TOOLS}\fakenet" -Recurse -Force
    }
    Move-Item ${TOOLS}\fakenet* "${TOOLS}\fakenet"
}

$TOOL_DEFINITIONS += @{
    Name = "Flare-Fakenet-NG"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Fakenet.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command fakenet.exe -h"
            Icon     = "`${TOOLS}\fakenet\fakenet.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "fakenet"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pcap")
    Tags = @("malware-analysis", "network-simulation", "dynamic-analysis")
    Notes = "FakeNet-NG - Next Generation Dynamic Network Analysis Tool"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# GoReSym
$status = Get-GitHubRelease -repo "mandiant/GoReSym" -path "${SETUP_PATH}\GoReSym.zip" -match "windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\GoReSym") {
        Remove-Item "${TOOLS}\GoReSym" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\GoReSym.zip" -o"${TOOLS}\GoReSym" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "GoReSym"
    Category = "Programming\Go"
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
    Verify = @(
        @{
            Type = "command"
            Name = "GoReSym"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".elf")
    Tags = @("reverse-engineering", "golang", "symbol-recovery")
    Notes = "Go symbol recovery tool."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# mmdbinspect
$status = Get-GitHubRelease -repo "maxmind/mmdbinspect" -path "${SETUP_PATH}\mmdbinspect.zip" -match "windows_amd64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\mmdbinspect") {
        Remove-Item "${TOOLS}\mmdbinspect" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mmdbinspect.zip" -o"${TOOLS}" | Out-Null
    Move-Item "${TOOLS}\mmdbinspect_*" "${TOOLS}\mmdbinspect"
}

$TOOL_DEFINITIONS += @{
    Name = "mmdbinspect"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\mmdbinspect (Tool for GeoIP lookup).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command mmdbinspect --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "mmdbinspect"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".mmdb")
    Tags = @("geolocation", "maxmind")
    Notes = "Tool for inspecting MaxMind GeoIP2 databases."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Elfparser-ng
$status = Get-GitHubRelease -repo "mentebinaria/elfparser-ng" -path "${SETUP_PATH}\elfparser-ng.zip" -match "win64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\elfparser-ng.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\elfparser-ng") {
        Remove-Item "${TOOLS}\elfparser-ng" -Recurse -Force
    }
    Move-Item ${TOOLS}\elfparser-ng* "${TOOLS}\elfparser-ng"
}

$TOOL_DEFINITIONS += @{
    Name = "Elfparser-ng"
    Category = "OS\Linux"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Linux\elfparser-ng.lnk"
            Target   = "`${TOOLS}\elfparser-ng\Release\elfparser-ng.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\elfparser-ng\Release\elfparser-ng.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".elf", ".so")
    Tags = @("reverse-engineering", "elf-analysis", "linux")
    Notes = "Multiplatform CLI and GUI tool to show information about ELF files."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# readpe
$status = Get-GitHubRelease -repo "mentebinaria/readpe" -path "${SETUP_PATH}\readpe.zip" -match "win.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\readpe.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\pev") {
        Remove-Item "${TOOLS}\pev" -Recurse -Force
    }
    Move-Item ${TOOLS}\pev* ${TOOLS}\pev
}

$TOOL_DEFINITIONS += @{
    Name = "readpe"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "pescan"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".sys")
    Tags = @("pe-analysis", "reverse-engineering")
    Notes = "The PE file analysis toolkit"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Dit explorer
$status = Get-GitHubRelease -repo "trustedsec/DitExplorer" -path "${SETUP_PATH}\DitExplorer.zip" -match "win64-release.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\DitExplorer") {
        Remove-Item "${TOOLS}\DitExplorer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\DitExplorer.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\DitExplorer-* "${TOOLS}\DitExplorer"
}

$TOOL_DEFINITIONS += @{
    Name = "DitExplorer"
    Category = "OS\Windows\Active Directory (AD)"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\DitExplorer (Active Directory Database Explorer).lnk"
            Target   = "`${TOOLS}\DitExplorer\DitExplorer.UI.WpfApp.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".dit")
    Tags = @("active-directory", "forensics")
    Notes = "Tool for viewing NTDS.dit Active Directory database files."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# srum_dump binary
$status = Get-GitHubRelease -repo "MarkBaggett/srum-dump" -path "${SETUP_PATH}\srum_dump.exe" -match "srum_dump.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\srum_dump.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "srum_dump"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\srum-dump (Parses Windows System Resource Usage Monitor (SRUM) database).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command srum_dump.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "srum_dump"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dat")
    Tags = @("windows", "forensics", "srum")
    Notes = "A forensics tool to convert the data in the Windows srum (System Resource Usage Monitor) database to an xlsx spreadsheet."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# forensic-timeliner
$status = Get-GitHubRelease -repo "acquiredsecurity/forensic-timeliner" -path "${SETUP_PATH}\ForensicTimeliner.zip" -match "ForensicTimeliner" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "forensic-timeliner"
    Category = "IR"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -ForensicTimeliner"
    Verify = @()
    FileExtensions = @(".evtx", ".csv", ".json")
    Tags = @("forensics", "timeline")
    Notes = "A high-speed forensic timeline engine for Windows forensic artifact CSV output built for DFIR investigators. Quickly consolidate CSV output from processed triage evidence for Eric Zimmerman (EZ Tools) Kape, Axiom, Hayabusa, Chainsaw and Nirsoft into a unified timeline."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# jwt-cli
$status = Get-GitHubRelease -repo "mike-engel/jwt-cli" -path "${SETUP_PATH}\jwt-cli.tar.gz" -match "jwt-windows.tar.gz"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\jwt-cli.tar.gz" -o"${TOOLS}\bin" | Out-Null
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${TOOLS}\bin\jwt-cli.tar" -o"${TOOLS}\bin" | Out-Null
    if (Test-Path "${TOOLS}\bin\jwt-cli.tar") {
        Remove-Item "${TOOLS}\bin\jwt-cli.tar" -Force
    }
}

$TOOL_DEFINITIONS += @{
    Name = "jwt-cli"
    Category = "Programming\Java"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("web", "authentication", "jwt")
    Notes = "A super fast CLI tool to decode and encode JWTs built in Rust"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# dsq
$status = Get-GitHubRelease -repo "multiprocessio/dsq" -path "${SETUP_PATH}\dsq.zip" -match "dsq-win" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dsq.zip" -o"${TOOLS}\bin" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "dsq"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\dsq (commandline SQL engine for data files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dsq -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "dsq"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".json", ".csv", ".tsv", ".parquet")
    Tags = @("data-processing", "sql", "json", "csv")
    Notes = "Commandline tool for running SQL queries against JSON, CSV, Excel, Parquet, and more."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# MetadataPlus
$status = Get-GitHubRelease -repo "nccgroup/MetadataPlus" -path "${SETUP_PATH}\MetadataPlus.exe" -match "MetadataPlus" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\MetadataPlus.exe ${TOOLS}\bin\
}

$TOOL_DEFINITIONS += @{
    Name = "MetadataPlus"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\MetadataPlus.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command MetadataPlus.exe -h"
            Icon     = "`${TOOLS}\bin\MetadataPlus.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "MetadataPlus"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".doc", ".docx", ".xls", ".xlsx", ".pdf", ".jpg", ".png")
    Tags = @("metadata", "file-analysis")
    Notes = "A tool to use novel locations to extract metadata from Office documents."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Loki - installed during start
$status =  Get-GitHubRelease -repo "Neo23x0/Loki" -path "${SETUP_PATH}\loki.zip" -match "loki" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "Loki"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\loki (runs dfirws-install -Loki).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Loki"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Loki"
    Verify = @(
        @{
            Type = "command"
            Name = "loki"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".bin")
    Tags = @("malware-analysis", "ioc-scanner", "yara", "detection")
    Notes = "Loki - Simple IOC and YARA Scanner"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Notepad++ - installed during start
$status =  Get-GitHubRelease -repo "notepad-plus-plus/notepad-plus-plus" -path "${SETUP_PATH}\notepad++.exe" -match "Installer.x64.exe$" -check "PE32"
#Plugins for Notepad++ - installed during start
# ComparePlus plugin for Notepad++ - installed during start
$status =  Get-GitHubRelease -repo "pnedev/comparePlus" -path "${SETUP_PATH}\comparePlus.zip" -match "x64.zip" -check "Zip archive data"
# DSpellCheck plugin for Notepad++ - installed during start
$status =  Get-GitHubRelease -repo "Predelnik/DSpellCheck" -path "${SETUP_PATH}\DSpellCheck.zip" -match "x64.zip" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "Notepad++"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Notepad++.lnk"
            Target   = "`${env:ProgramFiles}\Notepad++\notepad++.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "notepad++"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".txt", ".log", ".xml", ".json", ".csv", ".ps1", ".py", ".js")
    Tags = @("text-editor", "syntax-highlighting")
    Notes = "Notepad++ is a free source code editor and Notepad replacement that supports several programming languages."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ComparePlus"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\comparePlus.zip"
            Expect = "Zip archive data"
        }
    )
    FileExtensions = @()
    Tags = @("text-editor", "diff", "plugins")
    Notes = "A diff plugin for Notepad++."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "DSpellCheck"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\DSpellCheck.zip"
            Expect = "Zip archive data"
        }
    )
    FileExtensions = @()
    Tags = @("text-editor", "spell-checker", "plugins")
    Notes = "A spell-checker plugin for Notepad++."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# HindSight
$status = Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "${SETUP_PATH}\hindsight.exe" -match "hindsight.exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\hindsight.exe" "${TOOLS}\bin"
}
# Hindsight GUI
$status = Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "${SETUP_PATH}\hindsight_gui.exe" -match "hindsight_gui.exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\hindsight_gui.exe" "${TOOLS}\bin"
}

$TOOL_DEFINITIONS += @{
    Name = "HindSight"
    Category = "Files and apps\Browser"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight (Internet history forensics for Google Chrome and Chromium).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command hindsight.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight_gui.lnk"
            Target   = "`${TOOLS}\bin\hindsight_gui.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "hindsight"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".db", ".sqlite")
    Tags = @("browser-forensics", "chrome", "artifact-extraction")
    Notes = "Browser forensics tool for Google Chrome (and other Chromium-based browsers)."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# evtx_dump
$status = Get-GitHubRelease -repo "omerbenamram/evtx" -path "${SETUP_PATH}\evtx_dump.exe" -match "exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\evtx_dump.exe" "${TOOLS}\bin"
}

$TOOL_DEFINITIONS += @{
    Name = "evtx_dump"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\evtx_dump (Utility to parse EVTX files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command evtx_dump.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "evtx_dump"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\uv\regipy\Scripts\evtx_dump.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".evtx")
    Tags = @("log-analysis", "event-log", "windows")
    Notes = "A Fast (and safe) parser for the Windows XML Event Log (EVTX) format"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Visual Studio Code powershell extension - installed during start
$status =  Get-GitHubRelease -repo "PowerShell/vscode-powershell" -path "${SETUP_PATH}\vscode\vscode-powershell.vsix" -match "vsix" -check "Zip archive data"
# vscode-shellcheck
$status =  Get-GitHubRelease -repo "vscode-shellcheck/vscode-shellcheck" -path "${SETUP_PATH}\vscode\vscode-shellcheck.vsix" -match "vsix" -check "Zip archive data"
# Visual Studio Code spell checker extension - installed during start
$status =  Get-GitHubRelease -repo "streetsidesoftware/vscode-spell-checker" -path "${SETUP_PATH}\vscode\vscode-spell-checker.vsix" -match "vsix" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "VS Code PowerShell Extension"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".ps1", ".psm1", ".psd1")
    Tags = @("text-editor", "powershell", "plugins")
    Notes = "Visual Studio Code PowerShell extension."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "vscode-shellcheck"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("text-editor", "shellcheck", "linting", "bash", "sh", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "VS Code Spell Checker"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("text-editor", "spell-checker", "plugins")
    Notes = "Visual Studio Code Spell Checker extension."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# qpdf
$status = Get-GitHubRelease -repo "qpdf/qpdf" -path "${SETUP_PATH}\qpdf.zip" -match "msvc64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\qpdf.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\qpdf") {
        Remove-Item "${TOOLS}\qpdf" -Recurse -Force
    }
    Move-Item ${TOOLS}\qpdf-* "${TOOLS}\qpdf"
}

$TOOL_DEFINITIONS += @{
    Name = "qpdf"
    Category = "Files and apps\PDF"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PDF\qpdf.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command qpdf.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "qpdf"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pdf")
    Tags = @("pdf", "data-processing")
    Notes = "qpdf: A content-preserving PDF document transformer"
    Tips = ""
    Usage = "qpdf is a command-line tool and C++ library that performs content-preserving transformations on PDF files. It supports linearization, encryption, and numerous other features. It can also be used for splitting and merging files, creating PDF files (but you have to supply all the content yourself), and inspecting files for study or analysis. qpdf does not render PDFs or perform text extraction, and it does not contain higher-level interfaces for working with page contents. It is a low-level tool for working with the structure of PDF files and can be a valuable tool for anyone who wants to do programmatic or command-line-based manipulation of PDF files."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Fibratus
$status = Get-GitHubRelease -repo "rabbitstack/fibratus" -path "${SETUP_PATH}\fibratus.msi" -match "fibratus-[.0-9]+-amd64.msi$" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "Fibratus"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\fibratus (runs dfirws-install -Fibratus).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Fibratus"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Fibratus"
    Verify = @(
        @{
            Type = "command"
            Name = "fibratus"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".etl")
    Tags = @("etw", "windows", "monitoring")
    Notes = "Adversary tradecraft detection, protection, and hunting"
    Tips = ""
    Usage = "Fibratus detects, protects, and eradicates advanced adversary tradecraft by scrutinizing and asserting a wide spectrum of system events against a behavior-driven rule engine and YARA memory scanner."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Radare2
$status = Get-GitHubRelease -repo "radareorg/radare2" -path "${SETUP_PATH}\radare2.zip" -match "w64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\radare2.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\radare2") {
        Remove-Item "${TOOLS}\radare2" -Recurse -Force
    }
    Move-Item ${TOOLS}\radare2-* ${TOOLS}\radare2
}

$TOOL_DEFINITIONS += @{
    Name = "Radare2"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\radare2.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command radare2 -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "radare2"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so", ".mach-o")
    Tags = @("reverse-engineering", "disassembler", "debugging")
    Notes = "UNIX-like reverse engineering framework and command-line toolset"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# radare2-mcp - MCP server for radare2
$status = Get-GitHubRelease -repo "radareorg/radare2-mcp" -path "${SETUP_PATH}\r2mcp.zip" -match "w64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\r2mcp.zip" -o"${TOOLS}\radare2\bin" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "radare2-mcp"
    Homepage = "https://github.com/radareorg/radare2-mcp"
    Vendor = "radareorg"
    License = "MIT License"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so")
    Tags = @("reverse-engineering", "mcp", "ai", "radare2")
    Notes = "MCP stdio server for radare2. Enables AI assistants to interact with radare2 for binary analysis. Known issue: Windows binary may crash with stack overflow (GitHub issue #24)."
    Tips = "Configure in opencode.json with command: r2mcp. The server communicates via stdio."
    Usage = "Used as a local MCP server with opencode-ai or other MCP clients."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Radare2")
}

# r2ai and decai are installed via r2pm in start_sandbox.ps1

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
    Tags = @("reverse-engineering", "ai", "radare2")
    Notes = "AI plugin for radare2. Provides AI-assisted analysis using local and remote language models (Anthropic, OpenAI, Ollama, etc.). Installed via r2pm during sandbox startup."
    Tips = "Set API keys via environment variables (ANTHROPIC_API_KEY, OPENAI_API_KEY) or edit ~/.config/r2ai/apikeys.txt with r2ai -K."
    Usage = "Use within radare2 shell. Run r2pm -r r2ai for standalone mode."
    SampleCommands = @(
        "r2pm -r r2ai"
    )
    SampleFiles = @()
    Dependencies = @("Radare2")
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
    Notes = "r2js plugin for radare2 with special focus on AI-assisted decompilation. Installed via r2pm during sandbox startup."
    Tips = "Use within radare2 to get AI-powered decompilation output."
    Usage = "Use within radare2 shell for AI-assisted decompilation of binary code."
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Radare2")
}

# Iaito by Radareorg
$status = Get-GitHubRelease -repo "radareorg/iaito" -path "${SETUP_PATH}\iaito.zip" -match "iaito.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\iaito") {
        Remove-Item "${TOOLS}\iaito" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\iaito.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\__MACOSX") {
        Remove-Item "${TOOLS}\__MACOSX" -Recurse -Force
    }
}

$TOOL_DEFINITIONS += @{
    Name = "Iaito"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\iaito.lnk"
            Target   = "`${TOOLS}\iaito\iaito.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\iaito\iaito.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so")
    Tags = @("reverse-engineering", "disassembler", "gui")
    Notes = "iaito is the official graphical interface for radare2, a libre reverse engineering framework."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# hfs
$status = Get-GitHubRelease -repo "rejetto/hfs" -path "${SETUP_PATH}\hfs.zip" -match "hfs-windows-x64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\hfs") {
        Remove-Item "${TOOLS}\hfs" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hfs.zip" -o"${TOOLS}\hfs" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "hfs"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\hfs.exe.lnk"
            Target   = "`${TOOLS}\hfs\hfs.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\hfs\hfs.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("http", "file-server", "network")
    Notes = "hfs is a simple HTTP file server for Windows."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# obsidian-mitre-attack
$status = Get-GitHubRelease -repo "reuteras/obsidian-mitre-attack" -path "${SETUP_PATH}\obsidian-mitre-attack.zip" -match "release.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\obsidian-mitre-attack") {
        Remove-Item "${TOOLS}\obsidian-mitre-attack" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\obsidian-mitre-attack.zip" -o"${TOOLS}" | Out-Null
    Move-Item "${TOOLS}\MITRE" "${TOOLS}\obsidian-mitre-attack"
    Remove-Item "${TOOLS}\README.md" -Force
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-mitre-attack"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "mitre-attack", "threat-intelligence")
    Notes = "A vault for Obsidian.md containing the MITRE ATT&CK framework in markdown format."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Cutter
$status = Get-GitHubRelease -repo "rizinorg/cutter" -path "${SETUP_PATH}\cutter.zip" -match "Windows-x86_64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\cutter.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\cutter") {
        Remove-Item "${TOOLS}\cutter" -Recurse -Force
    }
    Move-Item ${TOOLS}\Cutter-* ${TOOLS}\cutter
}

$TOOL_DEFINITIONS += @{
    Name = "Cutter"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\Cutter.lnk"
            Target   = "`${TOOLS}\cutter\cutter.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "cutter"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "rizin"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf", ".bin", ".so", ".dylib")
    Tags = @("reverse-engineering", "disassembler", "decompiler", "gui")
    Notes = "Cutter is a Qt and C++ GUI powered by Rizin that provides an intuitive interface for reverse engineering and analyzing binaries across multiple platforms."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Nerd fonts - installed during start
# Add some example fonts
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\JetBrainsMono.zip" -match "JetBrainsMono.zip" -check "Zip archive data"
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\LiberationMono.zip" -match "LiberationMono.zip" -check "Zip archive data"
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\Meslo.zip" -match "Meslo.zip" -check "Zip archive data"
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\Terminus.zip" -match "Terminus.zip" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "Nerd Fonts"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".ttf", ".otf")
    Tags = @("fonts", "terminal")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Perl by Strawberry
$status = Get-GitHubRelease -repo "StrawberryPerl/Perl-Dist-Strawberry" -path "${SETUP_PATH}\perl.zip" -match "portable.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\perl") {
        Remove-Item "${TOOLS}\perl" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\perl.zip" -o"${TOOLS}\perl" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Strawberry Perl"
    Category = "Programming"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".pl", ".pm")
    Tags = @("scripting", "perl")
    Notes = "Strawberry Perl is a Perl distribution for Windows that includes a complete Perl environment."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# sidr
$status = Get-GitHubRelease -repo "strozfriedberg/sidr" -path "${SETUP_PATH}\sidr.exe" -match "sidr.exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\sidr.exe" "${TOOLS}\bin"
}

$TOOL_DEFINITIONS += @{
    Name = "sidr"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\sidr (Search Index DB Reporter - handles both ESE (.edb) and SQLite).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sidr --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "sidr"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".db", ".sqlite")
    Tags = @("browser-forensics", "forensics")
    Notes = "Search Index Database Reporter"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# jadx - installed during start
$status =  Get-GitHubRelease -repo "skylot/jadx" -path "${SETUP_PATH}\jadx.zip" -match "jadx-1" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "jadx"
    Category = "Programming\Java"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Java\Jadx (runs dfirws-install -Jadx).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Jadx"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Jadx"
    Verify = @()
    FileExtensions = @(".apk", ".dex", ".jar", ".class", ".zip")
    Tags = @("reverse-engineering", "android", "decompiler", "java", "deobfuscation")
    Notes = "Dex to Java decompiler"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Sleuthkit
$status = Get-GitHubRelease -repo "sleuthkit/sleuthkit" -path "${SETUP_PATH}\sleuthkit.zip" -match "win32.zip$" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sleuthkit.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\sleuthkit") {
        Remove-Item "${TOOLS}\sleuthkit" -Recurse -Force
    }
    Move-Item ${TOOLS}\sleuthkit-* "${TOOLS}\sleuthkit"
}

$TOOL_DEFINITIONS += @{
    Name = "Sleuthkit"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\blkcalc (Calculates where data in the unallocated space image).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "blkcalc"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dd", ".raw", ".E01", ".img", ".vmdk")
    Tags = @("disk-forensics", "filesystem", "forensics")
    Notes = "The Sleuth Kit® (TSK) is a library and collection of command line digital forensics tools that allow you to investigate volume and file system data. The library can be incorporated into larger digital forensics tools and the command line tools can be directly used to find evidence."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# qrtool
$status = Get-GitHubRelease -repo "sorairolake/qrtool" -path "${SETUP_PATH}\qrtool.zip" -match "x86_64-pc-windows-msvc" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\qrtool.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\qrtool") {
        Remove-Item "${TOOLS}\qrtool" -Recurse -Force
    }
    Move-Item ${TOOLS}\qrtool-* "${TOOLS}\qrtool"
}

$TOOL_DEFINITIONS += @{
    Name = "qrtool"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "qrtool"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".png", ".svg")
    Tags = @("qr-code", "encoding", "decoding")
    Notes = "Tool for decoding QR codes from images"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# debloat
$status = Get-GitHubRelease -repo "Squiblydoo/debloat" -path "${SETUP_PATH}\debloat.zip" -match "Windows" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\debloat.zip" -o"${TOOLS}\bin" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "debloat"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\Debloat.lnk"
            Target   = "`${TOOLS}\bin\debloat.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "debloat"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll")
    Tags = @("malware-analysis", "pe-analysis", "deobfuscation")
    Notes = "A GUI and CLI tool for removing bloat from executables"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Thumbcacheviewer
$status = Get-GitHubRelease -repo "thumbcacheviewer/thumbcacheviewer" -path "${SETUP_PATH}\thumbcacheviewer.zip" -match "viewer_64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\thumbcacheviewer") {
        Remove-Item "${TOOLS}\thumbcacheviewer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\thumbcacheviewer.zip" -o"${TOOLS}\thumbcacheviewer" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Thumbcacheviewer"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Thumbcache Viewer.lnk"
            Target   = "`${TOOLS}\thumbcacheviewer\thumbcache_viewer.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "thumbcache_viewer"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".db")
    Tags = @("windows", "forensics", "thumbnails")
    Notes = "Thumbcache Viewer - Extract Windows Vista, Windows 7, Windows 8, Windows 8.1, and Windows 10 thumbcache database files."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# gron
$status = Get-GitHubRelease -repo "tomnomnom/gron" -path "${SETUP_PATH}\gron.zip" -match "gron-windows-amd64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\gron.zip" -o"${TOOLS}\bin" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "gron"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\gron (Make JSON greppable).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command gron -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "gron"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".json")
    Tags = @("json", "data-processing", "grep")
    Notes = "gron makes JSON greppable by transforming it into discrete assignments that can be easily searched and filtered using standard command-line tools."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# MemProcFS
$status = Get-GitHubRelease -repo "ufrisk/MemProcFS" -path "${SETUP_PATH}\memprocfs.zip" -match "win_x64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\MemProcFS") {
        Remove-Item "${TOOLS}\MemProcFS" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\memprocfs.zip" -o"${TOOLS}\MemProcFS" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "MemProcFS"
    Category = "Memory"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Memory\MemProcFS.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command MemProcFS.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "MemProcFS"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dmp", ".raw", ".vmem", ".img")
    Tags = @("memory-forensics", "filesystem")
    Notes = "MemProcFS is an easy and convenient way of viewing physical memory as files in a virtual file system."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# upx
$status = Get-GitHubRelease -repo "upx/upx" -path "${SETUP_PATH}\upx.zip" -match "win64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\upx.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\upx") {
        Remove-Item "${TOOLS}\upx" -Recurse -Force
    }
    Move-Item ${TOOLS}\upx-* "${TOOLS}\upx"
}

$TOOL_DEFINITIONS += @{
    Name = "upx"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\upx.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command upx"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "upx"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf")
    Tags = @("packing", "pe-analysis", "compression")
    Notes = "UPX is a free, portable, extendable, high-performance executable packer."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Velociraptor
$status = Get-GitHubRelease -repo "velocidex/velociraptor" -path "${SETUP_PATH}\velociraptor.exe" -match "windows-amd64.exe$" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\velociraptor.exe" "${TOOLS}\bin\" -Force
}

$TOOL_DEFINITIONS += @{
    Name = "Velociraptor"
    Category = "IR"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\IR\velociraptor.exe (Velociraptor is an advanced digital forensic and incident response tool that enhances your visibility into your endpoints).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command velociraptor.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "velociraptor"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".json", ".csv")
    Tags = @("incident-response", "forensics", "endpoint-detection")
    Notes = "Velociraptor is an advanced digital forensic and incident response tool that enhances your visibility into your endpoints."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Witr
$status = Get-GitHubRelease -repo "pranshuparmar/witr" -path "${SETUP_PATH}\witr.zip" -match "witr-windows-amd64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\witr.zip" "witr.exe" -o"${TOOLS}\bin" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "Witr"
    Category = "IR"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "triage")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# fq
$status = Get-GitHubRelease -repo "wader/fq" -path "${SETUP_PATH}\fq.zip" -match "windows_amd64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fq.zip" -o"${TOOLS}\bin" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "fq"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\fq (jq for binary formats).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command fq -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "fq"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pcap", ".pcapng", ".mp4", ".mp3", ".flac", ".zip", ".tar", ".gif", ".png")
    Tags = @("data-processing", "binary-analysis", "file-format")
    Notes = "jq for binary formats - tool, language and decoders for working with binary and text formats"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# fqlite
$status = Get-GitHubRelease -repo "pawlaszczyk/fqlite" -path "${SETUP_PATH}\fqlite.exe" -match "windows.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "fqlite"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\fqlite (runs dfirws-install -FQLite).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -FQLite"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -FQLite"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Users\WDAGUtilityAccount\AppData\Local\fqlite\fqlite.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".db", ".sqlite", ".sqlite3")
    Tags = @("database", "sqlite", "forensics")
    Notes = "FQLite - SQLite Forensic Toolkit. FQLite is a tool to find and restore deleted records in SQlite databases. It therefore examines the database for entries marked as deleted."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Zircolite
$status = Get-GitHubRelease -repo "wagga40/zircolite" -path "${SETUP_PATH}\zircolite.7z" -match "zircolite" -check "7-zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\zircolite") {
        Remove-Item "${TOOLS}\zircolite" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\zircolite.7z" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\zircolite_* ${TOOLS}\zircolite
    Move-Item ${TOOLS}\zircolite\zircolite_*.exe ${TOOLS}\zircolite\zircolite.exe
}

$TOOL_DEFINITIONS += @{
    Name = "Zircolite"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\zircolite (Standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command zircolite.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "zircolite"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".evtx", ".json")
    Tags = @("log-analysis", "sigma", "detection", "incident-response")
    Notes = "Zircolite is a standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# imhex
$status = Get-GitHubRelease -repo "WerWolv/ImHex" -path "${SETUP_PATH}\imhex.zip" -match "Portable-NoGPU-x86_64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\imhex") {
        Remove-Item "${TOOLS}\imhex" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\imhex.zip" -o"${TOOLS}\imhex" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "ImHex"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\ImHex.lnk"
            Target   = "`${TOOLS}\imhex\imhex-gui.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "imhex-gui"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "imhex"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".bin", ".hex", ".elf")
    Tags = @("hex-editor", "binary-analysis", "pattern-language")
    Notes = "ImHex is a hex editor for binary analysis and pattern language."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# chainsaw
$status = Get-GitHubRelease -repo "WithSecureLabs/chainsaw" -path "${SETUP_PATH}\chainsaw.zip" -match "x86_64-pc-windows-msvc" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\chainsaw") {
        Remove-Item "${TOOLS}\chainsaw" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\chainsaw.zip" -o"${TOOLS}" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "chainsaw"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\chainsaw (Rapidly work with Forensic Artefacts).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command chainsaw.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "chainsaw"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".evtx")
    Tags = @("log-analysis", "incident-response", "sigma", "detection")
    Notes = "Rapidly Search and Hunt through Windows Forensic Artefacts"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# yara
$status = Get-GitHubRelease -repo "VirusTotal/yara" -path "${SETUP_PATH}\yara.zip" -match "win64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\yara.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\bin\yara.exe") {
        Remove-Item "${TOOLS}\bin\yara.exe" -Force
    }
    if (Test-Path "${TOOLS}\bin\yarac.exe") {
        Remove-Item "${TOOLS}\bin\yarac.exe" -Force
    }
    Move-Item ${TOOLS}\yara64.exe ${TOOLS}\bin\yara.exe
    Move-Item ${TOOLS}\yarac64.exe ${TOOLS}\bin\yarac.exe
}

$TOOL_DEFINITIONS += @{
    Name = "YARA"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\yara.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command yara.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\yarac.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command yarac.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "yara"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "yarac"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".yar", ".yara", ".exe", ".dll", ".bin")
    Tags = @("yara", "malware-analysis", "detection", "signatures")
    Notes = "YARA is a tool for identifying and classifying malware."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# yara-x
$status = Get-GitHubRelease -repo "VirusTotal/yara-x" -path "${SETUP_PATH}\yara-x.zip" -match "x86_64-pc-windows-msvc" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\bin\yr.exe") {
        Remove-Item "${TOOLS}\bin\yr.exe" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\yara-x.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\yr.exe ${TOOLS}\bin\yr.exe
}

$TOOL_DEFINITIONS += @{
    Name = "yara-x"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\yr (yara-x).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command yr.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "yr"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".yar", ".yara", ".exe", ".dll", ".bin")
    Tags = @("yara", "malware-analysis", "detection", "signatures")
    Notes = "yara-x is a faster and more flexible version of YARA."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# yq
$status = Get-GitHubRelease -repo "mikefarah/yq" -path "${SETUP_PATH}\yq.exe" -match "yq_windows_amd64.exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\yq.exe" "${TOOLS}\bin"
}

$TOOL_DEFINITIONS += @{
    Name = "yq"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\yq (is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command yq.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "yq"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".yaml", ".yml", ".json", ".xml", ".toml")
    Tags = @("yaml", "data-processing", "cli")
    Notes = "yq is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# Get x64dbg - installed during start
$status =  Get-GitHubRelease -repo "x64dbg/x64dbg" -path "${SETUP_PATH}\x64dbg.zip" -match "snapshot/snapshot" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "x64dbg"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\X64dbg (runs dfirws-install -X64dbg).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -X64dbg"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -X64Dbg"
    Verify = @(
        @{
            Type = "command"
            Name = "x64dbg"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll")
    Tags = @("reverse-engineering", "debugging", "dynamic-analysis")
    Notes = "An open-source user mode debugger for Windows. Optimized for reverse engineering and malware analysis."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# hayabusa
$status = Get-GitHubRelease -repo "Yamato-Security/hayabusa" -path "${SETUP_PATH}\hayabusa.zip" -match "win-x64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\hayabusa") {
        Remove-Item "${TOOLS}\hayabusa" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hayabusa.zip" -o"${TOOLS}\hayabusa" | Out-Null
    Move-Item ${TOOLS}\hayabusa\hayabusa-* ${TOOLS}\hayabusa\hayabusa.exe
}

$TOOL_DEFINITIONS += @{
    Name = "hayabusa"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\hayabusa (is a sigma-based threat hunting and fast forensics timeline generator for Windows event logs).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command hayabusa.exe help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "hayabusa"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".evtx")
    Tags = @("log-analysis", "event-log", "sigma", "detection", "timeline", "incident-response")
    Notes = "Hayabusa (隼) is a sigma-based threat hunting and fast forensics timeline generator for Windows event logs."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# takajo
$status = Get-GitHubRelease -repo "Yamato-Security/takajo" -path "${SETUP_PATH}\takajo.zip" -match "win-x64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\takajo") {
        Remove-Item "${TOOLS}\takajo" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\takajo.zip" -o"${TOOLS}\takajo" | Out-Null
    Move-Item ${TOOLS}\takajo\takajo-* "${TOOLS}\takajo\takajo.exe"
}

$TOOL_DEFINITIONS += @{
    Name = "takajo"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\takajo (is a tool to analyze Windows event logs - hayabusa).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command takajo.exe -h"
            Icon     = ""
            WorkDir  = "`${TOOLS}\takajo"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\takajo\takajo.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".json")
    Tags = @("log-analysis", "hayabusa", "timeline")
    Notes = "Takajō (鷹匠) is a Hayabusa results analyzer."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# zaproxy - available for installation with dfirws-install.ps1
$status = Get-GitHubRelease -repo "zaproxy/zaproxy" -path "${SETUP_PATH}\zaproxy.exe" -match "windows.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "zaproxy"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Zaproxy (runs dfirws-install -Zaproxy).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Zaproxy"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -ZAProxy"
    Verify = @(
        @{
            Type = "command"
            Name = "zap"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("web", "security-testing", "proxy")
    Notes = "The Zed Attack Proxy (ZAP) by Checkmarx is the world’s most widely used web app scanner. Free and open source. A community based GitHub Top 1000 project that anyone can contribute to."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# edit
$status = Get-GitHubRelease -repo "microsoft/edit" -path "${SETUP_PATH}\edit.zip" -match "windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\edit") {
        Remove-Item "${TOOLS}\edit" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\edit.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\edit-* ${TOOLS}\edit
    Copy-Item "${TOOLS}\edit\edit.exe" "${TOOLS}\bin\edit.exe"
}

$TOOL_DEFINITIONS += @{
    Name = "edit"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("text-editor")
    Notes = "Edit is a simple text editor for Windows made by Microsoft."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# https://download.sqlitebrowser.org/ - DB Browser for SQLite
$status = Get-GitHubRelease -repo "sqlitebrowser/sqlitebrowser" -path "${SETUP_PATH}\sqlitebrowser.zip" -match "win64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\DB Browser for SQLite") {
        Remove-Item -Recurse -Force "${TOOLS}\DB Browser for SQLite" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sqlitebrowser.zip" -o"${TOOLS}\sqlitebrowser" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "DB Browser for SQLite"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\DB Browser for SQLite.lnk"
            Target   = "`${TOOLS}\sqlitebrowser\DB Browser for SQLite.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\sqlitebrowser\DB Browser for SQLite.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".db", ".sqlite", ".sqlite3")
    Tags = @("database", "sqlite", "gui")
    Notes = "DB Browser for SQLite is a high quality, visual, open source tool for creating, designing, and editing database files compatible with SQLite."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# NetExt
$status = Get-GitHubRelease -repo "rodneyviana/netext" -path "${SETUP_PATH}\netext.zip" -match "NetExt-.*.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\NetExt") {
        Remove-Item "${TOOLS}\NetExt" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\netext.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\NetExt-* "${TOOLS}\NetExt"
}

$TOOL_DEFINITIONS += @{
    Name = "NetExt"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".dmp")
    Tags = @("debugging", "memory-forensics", "dotnet", "winDbg", "extension")
    Notes = "WinDbg extension for data mining managed heap. It also includes commands to list http request, wcf services, WIF tokens among others"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

# YAMAGoya
$status = Get-GitHubRelease -repo "JPCERTCC/YAMAGoya" -path "${SETUP_PATH}\YAMAGoya.zip" -match "YAMAGoya.*.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\YAMAGoya") {
        Remove-Item "${TOOLS}\YAMAGoya" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\YAMAGoya.zip" -o"${TOOLS}\YAMAGoya" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "YAMAGoya"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\YAMAGoya (Yet Another Memory Analyzer for malware detection and Guarding Operations with YARA and SIGMA).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command YAMAGoya.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yar", ".yara")
    Tags = @("yara", "rule-generation")
    Notes = "Yet Another Memory Analyzer for malware detection and Guarding Operations with YARA and SIGMA"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

#
# Obsidian plugins
#

# obsidian-dataview
$status = Get-GitHubRelease -repo "blacksmithgu/obsidian-dataview" -path "${SETUP_PATH}\obsidian-plugins\obsidian-dataview\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "blacksmithgu/obsidian-dataview" -path "${SETUP_PATH}\obsidian-plugins\obsidian-dataview\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "blacksmithgu/obsidian-dataview" -path "${SETUP_PATH}\obsidian-plugins\obsidian-dataview\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-kanban
$status = Get-GitHubRelease -repo "mgmeyers/obsidian-kanban" -path "${SETUP_PATH}\obsidian-plugins\obsidian-kanban\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "mgmeyers/obsidian-kanban" -path "${SETUP_PATH}\obsidian-plugins\obsidian-kanban\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "mgmeyers/obsidian-kanban" -path "${SETUP_PATH}\obsidian-plugins\obsidian-kanban\styles.css" -match "styles.css" -check "ASCII text"

# quickadd
$status = Get-GitHubRelease -repo "chhoumann/quickadd" -path "${SETUP_PATH}\obsidian-plugins\quickadd\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "chhoumann/quickadd" -path "${SETUP_PATH}\obsidian-plugins\quickadd\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "chhoumann/quickadd" -path "${SETUP_PATH}\obsidian-plugins\quickadd\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-calendar-plugin
$status = Get-GitHubRelease -repo "liamcain/obsidian-calendar-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-calendar-plugin\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "liamcain/obsidian-calendar-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-calendar-plugin\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "liamcain/obsidian-calendar-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-calendar-plugin\styles.css" -match "styles.css" -check "ASCII text"

# Templater
$status = Get-GitHubRelease -repo "SilentVoid13/Templater" -path "${SETUP_PATH}\obsidian-plugins\Templater\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "SilentVoid13/Templater" -path "${SETUP_PATH}\obsidian-plugins\Templater\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "SilentVoid13/Templater" -path "${SETUP_PATH}\obsidian-plugins\Templater\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-tasks
$status = Get-GitHubRelease -repo "obsidian-tasks-group/obsidian-tasks" -path "${SETUP_PATH}\obsidian-plugins\obsidian-tasks\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "obsidian-tasks-group/obsidian-tasks" -path "${SETUP_PATH}\obsidian-plugins\obsidian-tasks\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "obsidian-tasks-group/obsidian-tasks" -path "${SETUP_PATH}\obsidian-plugins\obsidian-tasks\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-excalidraw-plugin
$status = Get-GitHubRelease -repo "zsviczian/obsidian-excalidraw-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-excalidraw-plugin\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "zsviczian/obsidian-excalidraw-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-excalidraw-plugin\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "zsviczian/obsidian-excalidraw-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-excalidraw-plugin\styles.css" -match "styles.css" -check "text"

# admonitions
$status = Get-GitHubRelease -repo "javalent/admonitions" -path "${SETUP_PATH}\obsidian-plugins\admonitions\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "javalent/admonitions" -path "${SETUP_PATH}\obsidian-plugins\admonitions\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "javalent/admonitions" -path "${SETUP_PATH}\obsidian-plugins\admonitions\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-timeline
$status = Get-GitHubRelease -repo "George-debug/obsidian-timeline" -path "${SETUP_PATH}\obsidian-plugins\obsidian-timeline\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "George-debug/obsidian-timeline" -path "${SETUP_PATH}\obsidian-plugins\obsidian-timeline\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "George-debug/obsidian-timeline" -path "${SETUP_PATH}\obsidian-plugins\obsidian-timeline\styles.css" -match "styles.css" -check "ASCII text"


$TOOL_DEFINITIONS += @{
    Name = "obsidian-dataview"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "data-processing", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-kanban"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "project-management", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "quickadd"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "automation", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-calendar-plugin"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "calendar", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Templater"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "automation", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-tasks"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "task-management", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-excalidraw-plugin"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "drawing", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "admonitions"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-timeline"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("obsidian", "timeline", "plugins")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "release"
