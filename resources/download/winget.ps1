. "${PSScriptRoot}\common.ps1"

# Autopsy - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Autopsy."
Get-WinGet "SleuthKit.Autopsy" "Autopsy*.msi" "autopsy.msi"

# Burp suite - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Burp Suite."
Get-WinGet "PortSwigger.BurpSuite.${BURP_SUITE_EDITION}" "Burp*.exe" "burp.exe"

# Chrome - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Chrome."
Get-WinGet "Google.Chrome" "Google*.msi" "chrome.msi"

# Docker Desktop - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Docker Desktop."
Get-WinGet "Docker.DockerDesktop" "Docker*.exe" "docker.exe"

# DotNet 6 runtime - installed during startup
Write-SynchronizedLog "winget: Downloading DotNet 6 runtime."
Get-WinGet "Microsoft.DotNet.Runtime.6" Microsoft*.exe "dotnet6.exe"

# DotNet 6 Desktop runtime - installed during startup
Get-WinGet "Microsoft.DotNet.DesktopRuntime.6" "Microsoft*.exe" "dotnet6desktop.exe"

# IrfanView - installed during startup
Write-SynchronizedLog "winget: Downloading IrfanView."
Get-WinGet "IrfanSkiljan.IrfanView" "IrfanView*.exe" "irfanview.exe"

# Obsidian - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Obsidian."
Get-WinGet "Obsidian.Obsidian" "Obsidian*.exe" "obsidian.exe"

# oh-my-posh - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading oh-my-posh."
Get-WinGet "JanDeDobbeleer.OhMyPosh" "Oh*.exe" "oh-my-posh.exe"

# PowerShell 7 - installed during startup
Write-SynchronizedLog "winget: Downloading PowerShell 7."
Get-WinGet "Microsoft.PowerShell" "PowerShell*.msi" "powershell.msi"

# Putty - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Putty."
Get-WinGet "PuTTY.PuTTY" "PuTTY*.msi" "putty.msi"

# Qemu - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Qemu."
Get-WinGet "SoftwareFreedomConservancy.QEMU" "QEMU*.exe" "qemu.exe"

# Ruby - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Ruby."
Get-WinGet "RubyInstallerTeam.Ruby.3.2" "Ruby*.exe" "ruby.exe"

# VideoLAN VLC - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading VLC."
Get-WinGet "VideoLAN.VLC" "VLC*.exe" "vlc_installer.exe"

# VirusTotal CLI
Write-SynchronizedLog "winget: Downloading VirusTotal CLI."
Get-WinGet "VirusTotal.vt-cli" "vt-cli*.zip" "vt.zip"
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\downloads\vt.zip" -o"${TOOLS}\bin" | Out-Null

# WinMerge - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading WinMerge."
Get-WinGet "WinMerge.WinMerge" "WinMerge*.exe" "winmerge.exe"

# OpenVPN - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading OpenVPN."
Get-WinGet "OpenVPNTechnologies.OpenVPNConnect" "OpenVPN*.msi" "openvpn.msi"

# Google Earth Pro - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Google Earth Pro."
Get-WinGet "Google.EarthPro" "Google*.exe" "googleearth.exe"

# Passmark OSFMount - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading OSFMount."
Get-WinGet "PassmarkSoftware.OSFMount" "OSFMount*.exe" "osfmount.exe"

# WireGuard.WireGuard - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading WireGuard."
Get-WinGet "WireGuard.WireGuard" "wireguard*.msi" "wireguard.msi"

# tailscale - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Tailscale."
Get-WinGet "tailscale.tailscale" "tailscale*.exe" "tailscale.exe"

# Rclone
Write-SynchronizedLog "winget: Downloading Rclone."
Get-WinGet "Rclone.Rclone" "rclone*.zip" "rclone.zip"
if (Test-Path "${TOOLS}\rclone") {
    Remove-Item -Recurse -Force "${TOOLS}\rclone" | Out-Null
}
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\downloads\rclone.zip" -o"${TOOLS}\" | Out-Null
Move-Item "${TOOLS}\rclone-*" "${TOOLS}\rclone" -Force

Write-SynchronizedLog "winget: Download complete."