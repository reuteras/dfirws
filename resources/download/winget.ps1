. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

# Autopsy - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Autopsy."
$status = Get-WinGet "SleuthKit.Autopsy" "Autopsy*.msi" "autopsy.msi" -check "Composite Document File V2 Document"

# Burp suite - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Burp Suite."
$status = Get-WinGet "PortSwigger.BurpSuite.${BURP_SUITE_EDITION}" "Burp*.exe" "burp.exe" -check "PE32"

# Chrome - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Chrome."
$status = Get-WinGet "Google.Chrome" "Google*.msi" "chrome.msi" -check "Composite Document File V2 Document"

# Docker Desktop - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Docker Desktop."
$status = Get-WinGet "Docker.DockerDesktop" "Docker*.exe" "docker.exe" -check "PE32"

# DotNet 6 Desktop runtime - installed during startup
Write-SynchronizedLog "winget: Downloading DotNet 6 Desktop runtime."
$status = Get-WinGet "Microsoft.DotNet.DesktopRuntime.6" "Microsoft*.exe" "dotnet6desktop.exe" -check "PE32"

# DotNet 8 Desktop runtime - installed during startup
Write-SynchronizedLog "winget: Downloading DotNet 8 Desktop runtime."
$status = Get-WinGet "Microsoft.DotNet.DesktopRuntime.8" "Microsoft*.exe" "dotnet8desktop.exe" -check "PE32"

# IrfanView - installed during startup
Write-SynchronizedLog "winget: Downloading IrfanView."
$status = Get-WinGet "IrfanSkiljan.IrfanView" "IrfanView*.exe" "irfanview.exe" -check "PE32"

# Obsidian - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Obsidian."
$status = Get-WinGet "Obsidian.Obsidian" "Obsidian*.exe" "obsidian.exe" -check "PE32"

# oh-my-posh - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading oh-my-posh."
$status = Get-WinGet "JanDeDobbeleer.OhMyPosh" "Oh*.msi" "oh-my-posh.msi" -check "Zip archive data"

# PowerShell 7 - installed during startup
Write-SynchronizedLog "winget: Downloading PowerShell 7."
$status = Get-WinGet "Microsoft.PowerShell" "PowerShell*.msi" "powershell.msi" -check "Composite Document File V2 Document"

# Putty - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Putty."
$status = Get-WinGet "PuTTY.PuTTY" "PuTTY*.msi" "putty.msi" -check "Composite Document File V2 Document"

# Qemu - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Qemu."
$status = Get-WinGet "SoftwareFreedomConservancy.QEMU" "QEMU*.exe" "qemu.exe" -check "PE32"

# Ruby - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Ruby."
$status = Get-WinGet "RubyInstallerTeam.Ruby.3.4" "Ruby*.exe" "ruby.exe" -check "PE32"

# VideoLAN VLC - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading VLC."
$status = Get-WinGet "VideoLAN.VLC" "VLC*.exe" "vlc_installer.exe" -check "PE32"

# VirusTotal CLI
Write-SynchronizedLog "winget: Downloading VirusTotal CLI."
$status = Get-WinGet "VirusTotal.vt-cli" "vt-cli*.zip" "vt.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\downloads\vt.zip" -o"${TOOLS}\bin" | Out-Null
}

# WinMerge - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading WinMerge."
$status = Get-WinGet "WinMerge.WinMerge" "WinMerge*.exe" "winmerge.exe" -check "PE32"

# OpenVPN - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading OpenVPN."
$status = Get-WinGet "OpenVPNTechnologies.OpenVPNConnect" "OpenVPN*.msi" "openvpn.msi" -check "Composite Document File V2 Document"

# Google Earth Pro - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Google Earth Pro."
$status = Get-WinGet "Google.EarthPro" "Google*.exe" "googleearth.exe" -check "PE32"

# Passmark OSFMount - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading OSFMount."
$status = Get-WinGet "PassmarkSoftware.OSFMount" "OSFMount*.exe" "osfmount.exe" -check "PE32"

# WireGuard.WireGuard - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading WireGuard."
$status = Get-WinGet "WireGuard.WireGuard" "wireguard*.msi" "wireguard.msi" -check "Composite Document File V2 Document"

# Wireshark - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Wireshark."
$status = Get-WinGet "WiresharkFoundation.Wireshark" "Wireshark*.exe" "wireshark.exe" -check "PE32"

# tailscale - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Tailscale."
$status = Get-WinGet "Tailscale.Tailscale" "Tailscale*.exe" "tailscale.exe" -check "PE32"

# Firefox - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Firefox."
$status = Get-WinGet "Mozilla.Firefox" "Firefox*.exe" "firefox.exe" -check "PE32"

# Foxit PDF Reader - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Foxit PDF Reader."
$status = Get-WinGet "Foxit.FoxitReader" "Foxit*.exe" "foxitreader.exe" -check "PE32"

# uv - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading uv."
$status = Get-WinGet "astral-sh.uv" "uv*.zip" "uv" -check "data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\downloads\uv\uv*.zip" -o"${TOOLS}\bin" | Out-Null
}

# Windbg - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Windbg."
$status = Get-WinGet "Microsoft.WinDbg" "WinDbg*.msi" "windbg.msi" -check "Zip archive data"

Write-SynchronizedLog "winget: Download complete."

#
# Tool definitions for documentation generation.
# Fill in the dfirws-specific fields below. Auto-extracted metadata (Homepage,
# Vendor, License) comes from the winget cache via extract-tool-metadata.py.
#

$TOOL_DEFINITIONS += @{
    Name = "Autopsy"
    Category = "Forensics"
    Shortcuts = @("Forensics\Autopsy (runs dfirws-install -Autopsy)")
    InstallVerifyCommand = "dfirws-install.ps1 -Autopsy"
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Burp Suite"
    Category = "Network"
    Shortcuts = @("Network\Burp Suite (runs dfirws-install -BurpSuite)")
    InstallVerifyCommand = "dfirws-install.ps1 -BurpSuite"
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Chrome"
    Category = "Utilities\Browsers"
    Shortcuts = @("Utilities\Browsers\Chrome (runs dfirws-install -Chrome)")
    InstallVerifyCommand = "dfirws-install.ps1 -Chrome"
    Verify = @("chrome PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Docker Desktop"
    Category = "Utilities"
    Shortcuts = @("Utilities\Docker (runs dfirws-install.ps1 -Docker)")
    InstallVerifyCommand = "dfirws-install.ps1 -Docker"
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "DotNet 6 Desktop Runtime"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "DotNet 8 Desktop Runtime"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "IrfanView"
    Category = "Utilities\Media"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(""C:\Program Files\IrfanView\i_view64.exe" PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Obsidian"
    Category = "Editors"
    Shortcuts = @("Editors\Obsidian (runs dfirws-install -Obsidian)")
    InstallVerifyCommand = "dfirws-install.ps1 -Obsidian"
    Verify = @(""C:\Users\WDAGUtilityAccount\AppData\Local\Programs\Obsidian\Obsidian.exe" PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "oh-my-posh"
    Category = "Utilities"
    Shortcuts = @("Utilities\Oh-My-Posh (runs dfirws-install -OhMyPosh)")
    InstallVerifyCommand = "dfirws-install.ps1 -OhMyPosh"
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PowerShell 7"
    Category = "Programming\PowerShell"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PuTTY"
    Category = "Network"
    Shortcuts = @("Network\PuTTY (runs dfirws-install -PuTTY)")
    InstallVerifyCommand = "dfirws-install.ps1 -PuTTY"
    Verify = @("putty PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "QEMU"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Qemu"
    Verify = @("qemu-img PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Ruby"
    Category = "Programming\Ruby"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Ruby"
    Verify = @("ruby PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "VLC"
    Category = "Utilities\Media"
    Shortcuts = @("Utilities\Media\VLC (runs dfirws-install -VLC)")
    InstallVerifyCommand = "dfirws-install.ps1 -VLC"
    Verify = @("vlc PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "VirusTotal CLI"
    Category = "Signatures and information\Online tools"
    Shortcuts = @("Signatures and information\Online tools\vt (A command-line tool for interacting with VirusTotal)")
    InstallVerifyCommand = ""
    Verify = @("vt PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "WinMerge"
    Category = "Files and apps"
    Shortcuts = @("Files and apps\WinMerge (runs dfirws-install -WinMerge)")
    InstallVerifyCommand = "dfirws-install.ps1 -WinMerge"
    Verify = @("WinMergeU PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "OpenVPN"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Google Earth Pro"
    Category = "Utilities"
    Shortcuts = @("Utilities\Google Earth (runs dfirws-install -GoogleEarth)")
    InstallVerifyCommand = "dfirws-install.ps1 -GoogleEarth"
    Verify = @(""C:\Program Files\Google\Google Earth Pro\client\googleearth.exe" PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "OSFMount"
    Category = "Files and apps\Disk"
    Shortcuts = @("Files and apps\Disk\OSFMount (runs dfirws-install -OSFMount)")
    InstallVerifyCommand = "dfirws-install.ps1 -OSFMount"
    Verify = @(""C:\downloads\osfmount.exe" PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "WireGuard"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Wireshark"
    Category = "Network"
    Shortcuts = @("Network\Wireshark (runs dfirws-install -Wireshark)")
    InstallVerifyCommand = "dfirws-install.ps1 -Wireshark"
    Verify = @("Wireshark PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Tailscale"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(""C:\downloads\tailscale.exe" PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Firefox"
    Category = "Utilities\Browsers"
    Shortcuts = @("Utilities\Browsers\Firefox (runs dfirws-install -Firefox)")
    InstallVerifyCommand = "dfirws-install.ps1 -Firefox"
    Verify = @(""C:\Program Files\Mozilla Firefox\firefox.exe" PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Foxit PDF Reader"
    Category = "Files and apps\PDF"
    Shortcuts = @("Files and apps\PDF\Foxit Reader for pdf files (runs dfirws-install -FoxitReader)")
    InstallVerifyCommand = "dfirws-install.ps1 -FoxitReader"
    Verify = @(""C:\Program Files\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe" PE32")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "uv"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "WinDbg"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Windbg"
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "winget"