$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# This script runs in a Windows sandbox to prebuild the venv environment.
Write-DateLog "Install npm packages" >> "C:\log\npm.txt" 2>&1

# Set variables
$SETUP_PATH="C:\downloads"
$TOOLS="C:\Tools"
$TEMP="C:\tmp"

mkdir "$TEMP" > $null 2>&1

Copy-Item "$SETUP_PATH\7zip.msi" "$TEMP\7zip.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\7zip.msi /qn /norestart"
Get-Job | Receive-Job

Write-Output "Get-Content C:\log\npm.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
&"$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\nodejs.zip" -o"$TOOLS\node" >> "C:\log\npm.txt" 2>&1
Set-Location "$TOOLS\node\node-*"
Move-Item * ..

Set-Location $TOOLS\node
Remove-Item -r -Force node-v*
Write-DateLog "Init npm." >> "C:\log\npm.txt" 2>&1
.\npm init -y  | Out-String -Stream >> "C:\log\npm.txt" 2>&1
Write-DateLog "Add npm packages" >> "C:\log\npm.txt" 2>&1
# Obfuscate Javascript
.\npm install --global deobfuscator | Out-String -Stream >> "C:\log\npm.txt" 2>&1
# Create document
.\npm install --global jsdom | Out-String -Stream >> "C:\log\npm.txt" 2>&1

Get-Job | Receive-Job

Write-DateLog "Node installation done."
Write-Output "" > $TOOLS\node\done

shutdown /s /t 1 /c "Done with installing npm packages." /f /d p:4:1
