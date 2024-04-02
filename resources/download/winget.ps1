. "${PSScriptRoot}\common.ps1"

# Autopsy - available for installation via dfirws-install.ps1
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading Autopsy."
Get-WinGet "SleuthKit.Autopsy"
if (Test-Path .\tmp\winget\Autopsy*.msi) {
    Copy-Item .\tmp\winget\Autopsy*.msi ".\downloads\autopsy.msi"
}
Clear-Tmp winget

# Chrome - available for installation via dfirws-install.ps1
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading Chrome."
Get-WinGet "Google.Chrome"
if (Test-Path .\tmp\winget\Google*.exe) {
    Copy-Item .\tmp\winget\Google*.exe ".\downloads\chrome.exe"
}
Clear-Tmp winget

# Docker Desktop - available for installation via dfirws-install.ps1
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading Docker Desktop."
Get-WinGet "Docker.DockerDesktop"
if (Test-Path .\tmp\winget\Docker*.exe) {
    Copy-Item .\tmp\winget\Docker*.exe ".\downloads\docker.exe"
}
Clear-Tmp winget

# DotNet 6 runtime - installed during startup
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading DotNet 6 runtime."
Get-WinGet "Microsoft.DotNet.Runtime.6"
if (Test-Path .\tmp\winget\Microsoft*.exe) {
    Copy-Item .\tmp\winget\Microsoft*.exe ".\downloads\dotnet6.exe"
}
Clear-Tmp winget

# IrfanView - installed during startup
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading IrfanView."
Get-WinGet "IrfanSkiljan.IrfanView"
if (Test-Path .\tmp\winget\IrfanView*.exe) {
    Copy-Item .\tmp\winget\IrfanView*.exe ".\downloads\irfanview.exe"
}
Clear-Tmp winget

# Microsoft LogParser - available via git repo Events-Ripper
#Clear-Tmp winget
#Write-SynchronizedLog "winget: Downloading Microsoft LogParser."
#Get-WinGet Microsoft.LogParser
#Copy-Item .\tmp\winget\Log*.msi .\downloads\logparser.msi
#Clear-Tmp winget

# Obsidian - available for installation via dfirws-install.ps1
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading Obsidian."
Get-WinGet "Obsidian.Obsidian"
if (Test-Path .\tmp\winget\Obsidian*.exe) {
    Copy-Item .\tmp\winget\Obsidian*.exe ".\downloads\obsidian.exe"
}
Clear-Tmp winget

# oh-my-posh - available for installation via dfirws-install.ps1
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading oh-my-posh."
Get-WinGet "JanDeDobbeleer.OhMyPosh"
if (Test-Path .\tmp\winget\Oh*.exe) {
    Copy-Item .\tmp\winget\Oh*.exe ".\downloads\oh-my-posh.exe"
}
Clear-Tmp winget

# PowerShell 7 - installed during startup
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading PowerShell 7."
Get-WinGet "Microsoft.PowerShell"
if (Test-Path .\tmp\winget\PowerShell*.msi) {
    Copy-Item .\tmp\winget\PowerShell*.msi ".\downloads\powershell.msi"
}
Clear-Tmp winget

# Putty - available for installation via dfirws-install.ps1
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading Putty."
Get-WinGet "PuTTY.PuTTY"
if (Test-Path .\tmp\winget\PuTTY*.msi) {
    Copy-Item .\tmp\winget\PuTTY*.msi ".\downloads\putty.msi"
}
Clear-Tmp winget

# Qemu - available for installation via dfirws-install.ps1
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading Qemu."
Get-WinGet "SoftwareFreedomConservancy.QEMU"
if (Test-Path .\tmp\winget\QEMU*.exe) {
    Copy-Item .\tmp\winget\QEMU*.exe ".\downloads\qemu.exe"
}
Clear-Tmp winget

# Ruby - available for installation via dfirws-install.ps1
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading Ruby."
Get-WinGet "RubyInstallerTeam.Ruby.3.2"
if (Test-Path .\tmp\winget\Ruby*.exe) {
    Copy-Item .\tmp\winget\Ruby*.exe ".\downloads\ruby.exe"
}
Clear-Tmp winget

# VideoLAN VLC - available for installation via dfirws-install.ps1
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading VLC."
Get-WinGet "VideoLAN.VLC"
if (Test-Path .\tmp\winget\VLC*.msi) {
    Copy-Item .\tmp\winget\VLC*.msi ".\downloads\vlc.msi"
}
Clear-Tmp winget

# VirusTotal CLI
Clear-Tmp winget
Write-SynchronizedLog "winget: Downloading VirusTotal CLI."
Get-WinGet "VirusTotal.vt-cli"
if (Test-Path .\tmp\winget\vt-cli*.zip) {
    Copy-Item .\tmp\winget\vt-cli*.zip ".\downloads\vt.zip"
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\downloads\vt.zip" -o"${TOOLS}\bin" | Out-Null
}
Clear-Tmp winget

Write-SynchronizedLog "winget: Download complete."