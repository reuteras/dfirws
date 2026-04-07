. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to run ClamAV and YARA scans in parallel." > "${ROOT_PATH}\log\clamscan.txt"

if (Test-Path -Path "${ROOT_PATH}\log\clamscan_done") {
    Remove-Item "${ROOT_PATH}\log\clamscan_done" | Out-Null
}

(Get-Content ${ROOT_PATH}\resources\templates\generate_clamscan_yarascan.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}/") | Set-Content "${ROOT_PATH}\tmp\generate_clamscan_yarascan.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_clamscan_yarascan.wsb"
Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_clamscan_yarascan.wsb" -WaitForPath "${ROOT_PATH}\log\clamscan_done"

Write-DateLog "ClamAV and YARA scans done." >> "${ROOT_PATH}\log\clamscan.txt"
