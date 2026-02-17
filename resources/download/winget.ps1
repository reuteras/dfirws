. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

# Autopsy - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "Autopsy") {
    Write-SynchronizedLog "winget: Downloading Autopsy."
    $status = Get-WinGet "SleuthKit.Autopsy" "Autopsy*.msi" "autopsy.msi" -check "Composite Document File V2 Document"
}

$TOOL_DEFINITIONS += @{
    Name = "Autopsy"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\Autopsy (runs dfirws-install -Autopsy).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Autopsy"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Autopsy"
    Verify = @()
    FileExtensions = @(".dd", ".raw", ".E01", ".img", ".vmdk")
    Tags = @("disk-forensics", "forensics", "gui", "artifact-extraction")
    Notes = "Autopsy is a digital forensics platform that allows users to analyze disk images and extract artifacts from them. It provides a graphical user interface for examining file systems, recovering deleted files, and analyzing network traffic."
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

# Burp suite - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "Burp Suite") {
    Write-SynchronizedLog "winget: Downloading Burp Suite."
    $status = Get-WinGet "PortSwigger.BurpSuite.${BURP_SUITE_EDITION}" "Burp*.exe" "burp.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "Burp Suite"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Burp Suite (runs dfirws-install -BurpSuite).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -BurpSuite"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -BurpSuite"
    Verify = @()
    FileExtensions = @()
    Tags = @("web", "security-testing", "proxy")
    Notes = "Burp Suite is an integrated platform for performing security testing of web applications. It provides a wide range of tools for intercepting HTTP traffic, analyzing web applications, and automating security testing tasks."
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

# Chrome - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "Chrome") {
    Write-SynchronizedLog "winget: Downloading Chrome."
    $status = Get-WinGet "Google.Chrome" "Google*.msi" "chrome.msi" -check "Composite Document File V2 Document"
}

$TOOL_DEFINITIONS += @{
    Name = "Chrome"
    Category = "Utilities\Browsers"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Browsers\Chrome (runs dfirws-install -Chrome).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Chrome"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Chrome"
    Verify = @(
        @{
            Type = "command"
            Name = "chrome"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".html", ".htm", ".js", ".css")
    Tags = @("browser", "web")
    Notes = "Chrome is a widely used web browser developed by Google. It offers fast browsing, a user-friendly interface, and a wide range of extensions and developer tools, making it popular for both general web browsing and web development."
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

# DotNet 6 Desktop runtime - installed during startup
Write-SynchronizedLog "winget: Downloading DotNet 6 Desktop runtime."
$status = Get-WinGet "Microsoft.DotNet.DesktopRuntime.6" "Microsoft*.exe" "dotnet6desktop.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "DotNet 6 Desktop Runtime"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("dotnet", "runtime")
    Notes = "The .NET Desktop Runtime enables you to run existing Windows desktop applications. This release includes the .NET Runtime; you don't need to install it separately. Version 6.0."
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

# DotNet 8 Desktop runtime - installed during startup
Write-SynchronizedLog "winget: Downloading DotNet 8 Desktop runtime."
$status = Get-WinGet "Microsoft.DotNet.DesktopRuntime.8" "Microsoft*.exe" "dotnet8desktop.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "DotNet 8 Desktop Runtime"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("dotnet", "runtime")
    Notes = "The .NET Desktop Runtime enables you to run existing Windows desktop applications. This release includes the .NET Runtime; you don't need to install it separately. Version 8.0."
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

# IrfanView - installed during startup
Write-SynchronizedLog "winget: Downloading IrfanView."
$status = Get-WinGet "IrfanSkiljan.IrfanView" "IrfanView*.exe" "irfanview.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "IrfanView"
    Category = "Utilities\Media"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\IrfanView\i_view64.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".ico", ".webp")
    Tags = @("image-viewer", "multimedia")
    Notes = "IrfanView is a fast and compact image viewer and editor for Windows. It supports a wide range of image formats and provides basic editing features, making it useful for quickly viewing and manipulating images."
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

# Obsidian - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "Obsidian") {
    Write-SynchronizedLog "winget: Downloading Obsidian."
    $status = Get-WinGet "Obsidian.Obsidian" "Obsidian*.exe" "obsidian.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "Obsidian"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Obsidian (runs dfirws-install -Obsidian).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Obsidian"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Obsidian"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Users\WDAGUtilityAccount\AppData\Local\Programs\Obsidian\Obsidian.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".md", ".markdown")
    Tags = @("obsidian", "markdown")
    Notes = "Obsidian is a powerful knowledge management and note-taking application that allows you to create and link notes in a graph-based structure."
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

# oh-my-posh - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading oh-my-posh."
$status = Get-WinGet "JanDeDobbeleer.OhMyPosh" "Oh*.msi" "oh-my-posh.msi" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "oh-my-posh"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Oh-My-Posh (runs dfirws-install -OhMyPosh).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -OhMyPosh"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -OhMyPosh"
    Verify = @()
    FileExtensions = @()
    Tags = @("terminal", "shell", "theming")
    Notes = "Oh My Posh is a customizable prompt for PowerShell and other shells. It allows you to create beautiful and functional command-line prompts with themes and customizations."
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

# PowerShell 7 - installed during startup
Write-SynchronizedLog "winget: Downloading PowerShell 7."
$status = Get-WinGet "Microsoft.PowerShell" "PowerShell*.msi" "powershell.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "PowerShell 7"
    Category = "Programming\PowerShell"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".ps1", ".psm1", ".psd1")
    Tags = @("scripting", "shell", "automation")
    Notes = "PowerShell 7 is a cross-platform shell and scripting language that provides a powerful command-line interface and automation capabilities."
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

# Putty - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "PuTTY") {
    Write-SynchronizedLog "winget: Downloading Putty."
    $status = Get-WinGet "PuTTY.PuTTY" "PuTTY*.msi" "putty.msi" -check "Composite Document File V2 Document"
}

$TOOL_DEFINITIONS += @{
    Name = "PuTTY"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\PuTTY (runs dfirws-install -PuTTY).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -PuTTY"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -PuTTY"
    Verify = @(
        @{
            Type = "command"
            Name = "putty"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("ssh", "network", "terminal")
    Notes = "PuTTY is a free and open-source terminal emulator and SSH client for Windows. It is used to connect to remote systems via SSH, Telnet, and other protocols."
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

# Qemu - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "QEMU") {
    Write-SynchronizedLog "winget: Downloading Qemu."
    $status = Get-WinGet "SoftwareFreedomConservancy.QEMU" "QEMU*.exe" "qemu.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "QEMU"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Qemu"
    Verify = @(
        @{
            Type = "command"
            Name = "qemu-img"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".qcow2", ".vmdk", ".vdi", ".img", ".iso")
    Tags = @("virtualization", "emulation")
    Notes = "QEMU is a generic and open-source machine emulator and virtualizer. It can be used to run operating systems and applications for different architectures on a host system, making it useful for testing, development, and analysis."
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

# Ruby - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "Ruby") {
    Write-SynchronizedLog "winget: Downloading Ruby."
    $status = Get-WinGet "RubyInstallerTeam.Ruby.3.4" "Ruby*.exe" "ruby.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "Ruby"
    Category = "Programming\Ruby"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Ruby"
    Verify = @(
        @{
            Type = "command"
            Name = "ruby"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".rb")
    Tags = @("scripting", "ruby")
    Notes = "Ruby is a dynamic, open-source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write."
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

# VideoLAN VLC - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "VLC") {
    Write-SynchronizedLog "winget: Downloading VLC."
    $status = Get-WinGet "VideoLAN.VLC" "VLC*.exe" "vlc_installer.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "VLC"
    Category = "Utilities\Media"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Media\VLC (runs dfirws-install -VLC).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -VLC"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -VLC"
    Verify = @(
        @{
            Type = "command"
            Name = "vlc"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".mp4", ".avi", ".mkv", ".mov", ".mp3", ".wav", ".flac")
    Tags = @("multimedia", "video", "audio")
    Notes = "VLC is a versatile media player that supports a wide range of audio and video formats. It can be used for playing media files, streaming content, and even basic media conversion tasks."
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

# VirusTotal CLI
if (Test-ToolIncluded -ToolName "VirusTotal CLI") {
    Write-SynchronizedLog "winget: Downloading VirusTotal CLI."
    $status = Get-WinGet "VirusTotal.vt-cli" "vt-cli*.zip" "vt.zip" -check "Zip archive data"
    if ($status) {
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\downloads\vt.zip" -o"${TOOLS}\bin" | Out-Null
    }
}

$TOOL_DEFINITIONS += @{
    Name = "VirusTotal CLI"
    Category = "Signatures and information\Online tools"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\Online tools\vt (A command-line tool for interacting with VirusTotal).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command vt help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "vt"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("malware-analysis", "threat-intelligence", "ioc-scanner")
    Notes = "VirusTotal CLI is a command-line tool for interacting with VirusTotal, allowing you to analyze files and URLs for malware and other threats."
    Tips = ""
    Usage = ""
    SampleCommands = @(
        "vt file sample.exe",
        "vt url http://example.com",
        "vt ip 8.8.8.8"
    )
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

# WinMerge - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading WinMerge."
$status = Get-WinGet "WinMerge.WinMerge" "WinMerge*.exe" "winmerge.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "WinMerge"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\WinMerge (runs dfirws-install -WinMerge).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -WinMerge"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -WinMerge"
    Verify = @(
        @{
            Type = "command"
            Name = "WinMergeU"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("diff", "file-comparison")
    Notes = "WinMerge is a visual file and directory comparison tool that helps you compare files and directories. It is useful for identifying differences between files, merging changes, and synchronizing directories."
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

# OpenVPN - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "OpenVPN") {
    Write-SynchronizedLog "winget: Downloading OpenVPN."
    $status = Get-WinGet "OpenVPNTechnologies.OpenVPNConnect" "OpenVPN*.msi" "openvpn.msi" -check "Composite Document File V2 Document"
}

$TOOL_DEFINITIONS += @{
    Name = "OpenVPN"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".ovpn")
    Tags = @("vpn", "network")
    Notes = "OpenVPN is a widely used open-source VPN solution that allows you to create secure connections over the internet. It is designed to be flexible and secure, supporting various authentication methods and encryption protocols."
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

# Google Earth Pro - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "Google Earth Pro") {
    Write-SynchronizedLog "winget: Downloading Google Earth Pro."
    $status = Get-WinGet "Google.EarthPro" "Google*.exe" "googleearth.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "Google Earth Pro"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Google Earth (runs dfirws-install -GoogleEarth).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -GoogleEarth"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -GoogleEarth"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\Google\Google Earth Pro\client\googleearth.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".kml", ".kmz")
    Tags = @("geolocation", "osint", "visualization")
    Notes = "Google Earth Pro is a tool for viewing satellite imagery, maps, and geographic information. It can be used for geolocation analysis, visualizing data, and exploring geographic features."
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

# Passmark OSFMount - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading OSFMount."
$status = Get-WinGet "PassmarkSoftware.OSFMount" "OSFMount*.exe" "osfmount.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "OSFMount"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\OSFMount (runs dfirws-install -OSFMount).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -OSFMount"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\osfmount.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dd", ".raw", ".E01", ".img", ".vmdk", ".iso")
    Tags = @("disk-forensics", "mounting", "filesystem")
    Notes = "OSFMount is a tool for mounting disk images and virtual hard disks as virtual drives. It can be used for analyzing disk images, accessing files within them, and performing forensic analysis on the mounted images."
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

# WireGuard.WireGuard - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "WireGuard") {
    Write-SynchronizedLog "winget: Downloading WireGuard."
    $status = Get-WinGet "WireGuard.WireGuard" "wireguard*.msi" "wireguard.msi" -check "Composite Document File V2 Document"
}

$TOOL_DEFINITIONS += @{
    Name = "WireGuard"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vpn", "network")
    Notes = "WireGuard is a modern and efficient VPN protocol that provides secure and fast connections. It is designed to be simple to configure and use, making it a popular choice for both personal and enterprise VPN solutions."
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

# Wireshark - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Wireshark."
$status = Get-WinGet "WiresharkFoundation.Wireshark" "Wireshark*.exe" "wireshark.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Wireshark"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Wireshark (runs dfirws-install -Wireshark).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Wireshark"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Wireshark"
    Verify = @(
        @{
            Type = "command"
            Name = "Wireshark"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pcap", ".pcapng", ".cap")
    Tags = @("network-analysis", "pcap", "protocol-analysis")
    Notes = "Wireshark is a widely used network protocol analyzer that allows you to capture and analyze network traffic. It can be used for troubleshooting network issues, analyzing security incidents, and learning about network protocols. Wireshark provides a graphical interface for viewing and filtering captured packets, making it easier to analyze complex network traffic."
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

# tailscale - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "Tailscale") {
    Write-SynchronizedLog "winget: Downloading Tailscale."
    $status = Get-WinGet "Tailscale.Tailscale" "Tailscale*.exe" "tailscale.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "Tailscale"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\tailscale.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("vpn", "network")
    Notes = "Tailscale is a modern VPN solution that allows you to create secure, private networks between your devices. It is designed to be easy to use and can be used for remote access, secure file sharing, and connecting devices across different networks."
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

# Firefox - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "Firefox") {
    Write-SynchronizedLog "winget: Downloading Firefox."
    $status = Get-WinGet "Mozilla.Firefox" "Firefox*.exe" "firefox.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "Firefox"
    Category = "Utilities\Browsers"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Browsers\Firefox (runs dfirws-install -Firefox).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Firefox"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Firefox"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\Mozilla Firefox\firefox.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".html", ".htm", ".js", ".css")
    Tags = @("browser", "web")
    Notes = "Firefox is a fast and secure web browser that can be used to browse the internet, view websites, and manage bookmarks and passwords."
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

# Foxit PDF Reader - available for installation via dfirws-install.ps1
if (Test-ToolIncluded -ToolName "Foxit PDF Reader") {
    Write-SynchronizedLog "winget: Downloading Foxit PDF Reader."
    $status = Get-WinGet "Foxit.FoxitReader" "Foxit*.exe" "foxitreader.exe" -check "PE32"
}

$TOOL_DEFINITIONS += @{
    Name = "Foxit PDF Reader"
    Category = "Files and apps\PDF"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PDF\Foxit Reader for pdf files (runs dfirws-install -FoxitReader).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -FoxitReader"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -FoxitReader"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pdf")
    Tags = @("pdf", "viewer")
    Notes = "Foxit PDF Reader is a lightweight and fast PDF viewer that can be used to open and view PDF files. It is an alternative to Adobe Acrobat Reader and offers features such as annotation, form filling, and digital signatures."
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

# Windbg - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Windbg."
$status = Get-WinGet "Microsoft.WinDbg" "WinDbg*.msi" "windbg.msi" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "WinDbg"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Windbg"
    Verify = @()
    FileExtensions = @(".dmp", ".exe", ".dll", ".sys")
    Tags = @("debugging", "memory-forensics", "kernel")
    Notes = "WinDbg is a powerful debugger from Microsoft that can be used for analyzing crash dumps, debugging applications, and performing memory forensics. It is commonly used in incident response and malware analysis to investigate system crashes and analyze the behavior of malicious software."
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

# Neovim - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Neovim."
$status = Get-WinGet "Neovim.Neovim" "nvim*.msi" "nvim.msi"
if ($status) {
    Copy-Item -Path ".\downloads\nvim.msi\Neovim*.msi" -Destination ".\downloads\neovim.msi" -Force
    Remove-Item -Path ".\downloads\nvim.msi" -Force -Recurse
}
$null = Get-FileFromUri "https://github.com/vim/vim/raw/refs/heads/master/runtime/spell/en.utf-8.spl" -FilePath ".\downloads\en.utf-8.spl"
$null = Get-FileFromUri "https://github.com/vim/vim/raw/refs/heads/master/runtime/spell/en.utf-8.sug" -FilePath ".\downloads\en.utf-8.sug"

$TOOL_DEFINITIONS += @{
    Name = "Neovim"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Neovim (runs dfirws-install -Neovim).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Neovim"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Neovim"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\Neovim\bin\nvim.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".txt", ".md", ".log", ".ps1", ".py", ".rb", ".js")
    Tags = @("text-editor", "code-editor", "terminal")
    Notes = "Neovim is a terminal-based text editor that can be used for editing scripts, notes, and other text files. It is a fork of Vim with additional features and improvements."
    Tips = ""
    Usage = ""
    SampleCommands = @(
        "nvim notes.md"
    )
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

Write-SynchronizedLog "winget: Download complete."

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "winget"
