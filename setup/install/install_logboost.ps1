# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}

Write-Output "Update Threat Intel for LogBoost."

Write-Output "Get-Content C:\log\logboost.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Set-Location "C:\Tools\logboost"
if (Test-Path -Path "${TOOLS}\logboost\threats.db") {
    Write-DateLog "Do TI update." >> "C:\log\logboost.txt"
    .\logboost.exe -updateti 2>&1 | ForEach-Object{ "$_" } >> "C:\log\logboost.txt"
} else {
    Write-DateLog "Do TI build." >> "C:\log\logboost.txt"
    .\logboost.exe -buildti 2>&1 | ForEach-Object{ "$_" } >> "C:\log\logboost.txt"
}

Write-DateLog "logboost: Done updating logboost TI in sandbox." >> "C:\log\logboost.txt"

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\Tools\logboost\done"
