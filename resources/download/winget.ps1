. $PSScriptRoot\common.ps1


# Autopsy - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading Autopsy."
Get-WinGet SleuthKit.Autopsy .\downloads\autopsy.msi
if (Test-Path .\tmp\winget\Autopsy*.msi) {
    Copy-Item .\tmp\winget\Autopsy*.msi .\downloads\autopsy.msi
}
Clear-Tmp

# DotNet 6 runtime - installed during startup
Clear-Tmp
Write-SynchronizedLog "winget: Downloading DotNet 6 runtime."
Get-WinGet Microsoft.DotNet.Runtime.6 .\downloads\dotnet6.exe
if (Test-Path .\tmp\winget\Microsoft*.exe) {
    Copy-Item .\tmp\winget\Microsoft*.exe .\downloads\dotnet6.exe
}
Clear-Tmp

# GoLang - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading GoLang."
Get-WinGet Golang.Go .\downloads\golang.msi
if (Test-Path .\tmp\winget\Go*.msi) {
    Copy-Item .\tmp\winget\Go*.msi .\downloads\golang.msi
}
Clear-Tmp

# Microsoft LogParser - available via git repo Events-Ripper
#Clear-Tmp
#Write-SynchronizedLog "winget: Downloading Microsoft LogParser."
#Get-WinGet Microsoft.LogParser .\downloads\logparser.msi
#Copy-Item .\tmp\winget\Log*.msi .\downloads\logparser.msi
#Clear-Tmp

# Obsidian - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading Obsidian."
Get-WinGet Obsidian.Obsidian .\downloads\obsidian.exe
if (Test-Path .\tmp\winget\Obsidian*.exe) {
    Copy-Item .\tmp\winget\Obsidian*.exe .\downloads\obsidian.exe
}
Clear-Tmp

# PowerShell 7 - installed during startup
Clear-Tmp
Write-SynchronizedLog "winget: Downloading PowerShell 7."
Get-WinGet	Microsoft.PowerShell .\downloads\powershell.msi
if (Test-Path .\tmp\winget\PowerShell*.msi) {
    Copy-Item .\tmp\winget\PowerShell*.msi .\downloads\powershell.msi
}
Clear-Tmp

# Qemu - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading Qemu."
Get-WinGet	SoftwareFreedomConservancy.QEMU .\downloads\qemu.exe
if (Test-Path .\tmp\winget\QEMU*.exe) {
    Copy-Item .\tmp\winget\QEMU*.exe .\downloads\qemu.exe
}
Clear-Tmp

# Ruby - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading Ruby."
Get-WinGet	RubyInstallerTeam.Ruby.3.2 .\downloads\ruby.exe
if (Test-Path .\tmp\winget\Ruby*.exe) {
    Copy-Item .\tmp\winget\Ruby*.exe .\downloads\ruby.exe
}
Clear-Tmp

# VirusTotal CLI
Clear-Tmp
Write-SynchronizedLog "winget: Downloading VirusTotal CLI."
Get-WinGet	VirusTotal.vt-cli .\downloads\vt.zip
if (Test-Path .\tmp\winget\vt-cli*.zip) {
    Copy-Item .\tmp\winget\vt-cli*.zip .\downloads\vt.zip
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\vt.zip" -o"$TOOLS\bin" | Out-Null
}
Clear-Tmp

Write-SynchronizedLog "winget: Download complete."