$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to install node tools.
Write-DateLog "Install npm packages" 2>&1 >> "C:\log\npm.txt"

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | Out-Null

Copy-Item "${SETUP_PATH}\7zip.msi" "${WSDFIR_TEMP}\7zip.msi"
Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\7zip.msi /qn /norestart"
Get-Job | Receive-Job

Write-Output "Get-Content C:\log\npm.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";C:\Tools\node"
&"${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\nodejs.zip" -o"${TOOLS}\node" 2>&1 >> "C:\log\npm.txt"
Set-Location "${TOOLS}\node\node-*"
Move-Item * ..

Set-Location "${TOOLS}\node"
Remove-Item -r -Force node-v*
Write-DateLog "Init npm." 2>&1 >> "C:\log\npm.txt"
npm init -y  | Out-String -Stream 2>&1 >> "C:\log\npm.txt"
Write-DateLog "Add npm packages" 2>&1 >> "C:\log\npm.txt"
Write-DateLog "Install deobfuscator" 2>&1 >> "C:\log\npm.txt"
npm install --global deobfuscator | Out-String -Stream 2>&1 >> "C:\log\npm.txt"
Write-DateLog "Install docsify" 2>&1 >> "C:\log\npm.txt"
npm install --global docsify-cli | Out-String -Stream 2>&1 >> "C:\log\npm.txt"
Write-DateLog "Install jsdom" 2>&1 >> "C:\log\npm.txt"
npm install --global jsdom | Out-String -Stream 2>&1 >> "C:\log\npm.txt"
Write-DateLog "Install box-js" 2>&1 >> "C:\log\npm.txt"
npm install --global box-js | Out-String -Stream 2>&1 >> "C:\log\npm.txt"

Get-Job | Receive-Job

Write-DateLog "Node installation done." 2>&1 >> "C:\log\npm.txt"
Write-Output "" > "${TOOLS}\node\done"
