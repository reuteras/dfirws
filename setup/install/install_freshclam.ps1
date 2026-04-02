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

& certutil -generateSSTFromWU roots.sst | Tee-Object -FilePath "C:\log\freshclam.txt" -Append
& certutil -addstore -f root roots.sst | Tee-Object -FilePath "C:\log\freshclam.txt" -Append

& 'C:\Program Files\ClamAV\freshclam.exe' --quiet 2>&1 | ForEach-Object{ "$_" } | Tee-Object -FilePath "C:\log\freshclam.txt" -Append

Write-DateLog "Freshclam update done." | Tee-Object -FilePath "C:\log\freshclam.txt" -Append

# Download additional ClamAV community databases
Write-DateLog "Downloading additional ClamAV databases..." | Tee-Object -FilePath "C:\log\freshclam.txt" -Append
$ProgressPreference = 'SilentlyContinue'
$ClamDBDir = "${TOOLS}\ClamAV\db"

# URLhaus (abuse.ch) - active malware distribution URLs/hashes
try {
    Invoke-WebRequest -Uri "https://urlhaus.abuse.ch/downloads/urlhaus.ndb" -OutFile "${ClamDBDir}\urlhaus.ndb" -UseBasicParsing
    Write-DateLog "Downloaded urlhaus.ndb" | Tee-Object -FilePath "C:\log\freshclam.txt" -Append
} catch {
    Write-DateLog "WARNING: Failed to download urlhaus.ndb: $_" | Tee-Object -FilePath "C:\log\freshclam.txt" -Append
}

Write-DateLog "Additional database downloads complete." | Tee-Object -FilePath "C:\log\freshclam.txt" -Append

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "${TOOLS}\ClamAV\done"
