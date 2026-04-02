$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to scan tools with ClamAV.
Write-DateLog "Install ClamAV and run scan" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | Out-Null

Write-Output "Get-Content C:\log\clamscan.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Install-ClamAV
while (-not (Test-Path -Path "C:\Program Files\ClamAV\clamscan.exe")) {
    Start-Sleep -Seconds 1
}

$ClamDB = "${TOOLS}\ClamAV\db"
$ScanLog = "C:\log\clamav-scan.log"

Write-DateLog "Starting ClamAV scan of C:\Tools, C:\venv and C:\git..." | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

& 'C:\Program Files\ClamAV\clamscan.exe' `
    --recursive `
    --infected `
    --suppress-ok-results `
    --database=$ClamDB `
    --heuristic-alerts=yes `
    --heuristic-scan-precedence=yes `
    --alert-broken=yes `
    --alert-encrypted-archive=yes `
    --alert-macros=yes `
    --alert-exceeds-max=yes `
    --bytecode=yes `
    "--exclude-dir=^C:\\Windows" `
    "--exclude-dir=^C:\\Program Files\\Windows Defender" `
    "--exclude-dir=^C:\\ProgramData\\Microsoft\\Windows Defender" `
    "--exclude-dir=^C:\\Tools\\ClamAV" `
    "--exclude-dir=__pycache__" `
    "--exclude=\.lnk$" `
    "--exclude=\.url$" `
    "--exclude=\.mui$" `
    "--exclude=\.cat$" `
    "--exclude=\.manifest$" `
    "--exclude=\.pyc$" `
    --max-filesize=200M `
    --max-scansize=400M `
    --log=$ScanLog `
    "C:\Tools" "C:\venv" "C:\git" 2>&1 | ForEach-Object{ "$_" } | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

Write-DateLog "ClamAV scan complete. Results saved to $ScanLog" | Tee-Object -FilePath "C:\log\clamscan.txt" -Append

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "C:\log\clamscan_done"
