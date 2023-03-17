# First start logging
Remove-Item "C:\log\npm.txt"
Start-Transcript -Append "C:\log\npm.txt"

# Set variables
$SETUP_PATH="C:\downloads"
$TOOLS="C:\Tools"
$TEMP="C:\tmp"

mkdir "$TEMP" > $null 2>&1

Copy-Item "$SETUP_PATH\7zip.msi" "$TEMP\7zip.msi"
&msiexec /i "$TEMP\7zip.msi" /qn /norestart | Out-String -Stream

Write-Output "Get-Content C:\log\npm.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# This script runs in a Windows sandbox to prebuild the venv environment.
Write-Output "Install npm packages"
# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
&"$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\nodejs.zip" -o"$TOOLS\node" | Out-String -Stream
Set-Location "$TOOLS\node\node-*"
Move-Item * ..

Set-Location $TOOLS\node
Remove-Item -r -Force node-v*
.\npm init -y | Out-String -Stream
.\npm install --global deobfuscator | Out-String -Stream
.\npm install --global jsdom | Out-String -Stream

Write-Output "" > $TOOLS\node\done
Stop-Transcript

shutdown /s /t 1 /c "Done with installing npm packages." /f /d p:4:1
