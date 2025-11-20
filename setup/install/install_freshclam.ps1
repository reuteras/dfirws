$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to install node tools.
Write-DateLog "Install ClamAV and run freshclam packages" | Tee-Object -FilePath "C:\log\freshclam.txt" -Append

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | Out-Null

Write-Output "Get-Content C:\log\freshclam.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Install-ClamAV
while (-not (Test-Path -Path "C:\Program Files\ClamAV\freshclam.exe")) {
    Start-Sleep -Seconds 1
}

if (-not (Test-Path -Path "C:\Program Files\ClamAV\freshclam.conf")) {
    (Get-Content 'C:\Program Files\ClamAV\conf_examples\freshclam.conf.sample').Replace("Example", "#Example") | Out-File -FilePath 'C:\Program Files\ClamAV\freshclam.conf' -Encoding "ascii"
    Write-Output 'DatabaseDirectory "C:\Tools\ClamAV\db"' | Out-File -Append 'C:\Program Files\ClamAV\freshclam.conf'
}

& 'C:\Program Files\ClamAV\freshclam.exe' 2>&1 | ForEach-Object{ "$_" } | Tee-Object -FilePath "C:\log\freshclam.txt" -Append

Write-DateLog "Freshclam update done." | Tee-Object -FilePath "C:\log\freshclam.txt" -Append

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "${TOOLS}\ClamAV\done"
