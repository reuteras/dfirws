# First start logging
Start-Transcript -Append "C:\log\npm.txt"

# Set variables
$SETUP_PATH="C:\downloads"
$TOOLS="C:\Tools"
$TEMP="C:\tmp"

mkdir "$TEMP"

Copy-Item "$SETUP_PATH\7zip.msi" "$TEMP\7zip.msi"
msiexec /i "$TEMP\7zip.msi" /qn /norestart

Write-Output "Get-Content C:\log\npm.txt -Wait" | Out-File -FilePath "C:\Progress.ps1"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd"

# This script runs in a Windows sandbox to prebuild the venv environment.
Write-Output "Install npm packages"
# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\nodejs.zip" -o"$TOOLS\node"
Set-Location "$env:TOOLS\node\node-*"
Move-Item * ..

Set-Location $env:TOOLS\node
Remove-Item -r -Force node-v*
.\npm init -y
.\npm install --global deobfuscator
.\npm install --global jsdom

Write-Output "" > $TOOLS\node\done
Stop-Transcript

shutdown /s /t 1 /c "Done with installing npm packages." /f /d p:4:
