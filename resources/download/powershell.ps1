. ".\resources\download\common.ps1"

Clear-Tmp powershell

# Download PowerShell modules
Write-SynchronizedLog "powershell: Downloading ImportExcel, posh-git and Terminal-Icons."
Save-Module -Name ImportExcel,posh-git,Terminal-Icons -Path .\tmp\powershell -Force

if (! (Test-Path ".\tmp\powershell\ImportExcel")) {
    Write-SynchronizedLog "powershell: ImportExcel module not found. Exiting."
    Exit
}
if (! (Test-Path ".\tmp\powershell\posh-git")) {
    Write-SynchronizedLog "powershell: posh-git module not found. Exiting."
    Exit
}
if (! (Test-Path ".\tmp\powershell\Terminal-Icons")) {
    Write-SynchronizedLog "powershell: Terminal-Icons module not found. Exiting."
    Exit
}

rclone.exe sync --verbose --checksum ".\tmp\powershell" ".\downloads\powershell-modules" 2>&1 | Out-Null
Clear-Tmp powershell

Write-SynchronizedLog "powershell: Download complete."