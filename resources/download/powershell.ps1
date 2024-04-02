. "${PSScriptRoot}\common.ps1"

Clear-Tmp powershell

# Terminal-Icons
Write-SynchronizedLog "powershell: Downloading Terminal-Icons."
Save-Module -Name Terminal-Icons -Path .\tmp\powershell -Force

# posh-git
Write-SynchronizedLog "powershell: Downloading posh-git."
Save-Module -Name posh-git -Path .\tmp\powershell -Force

# ImportExcel
Write-SynchronizedLog "powershell: Downloading ImportExcel."
Save-Module -Name ImportExcel -Path .\tmp\powershell -Force

rclone.exe sync --verbose --checksum ".\tmp\powershell" ".\downloads\powershell-modules" 2>&1 | Out-Null
Clear-Tmp powershell

Write-SynchronizedLog "powershell: Download complete."