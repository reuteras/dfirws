. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to run ClamAV and YARA scans in parallel." > "${ROOT_PATH}\log\clamscan.txt"

if (Test-Path -Path "${ROOT_PATH}\log\clamscan_done") {
    Remove-Item "${ROOT_PATH}\log\clamscan_done" | Out-Null
}

# Flag file tells install_clamscan.ps1 to also run the YARA scan
Write-Output "" > "${ROOT_PATH}\log\run_yarascan"

(Get-Content ${ROOT_PATH}\resources\templates\generate_clamscan.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}/") | Set-Content "${ROOT_PATH}\tmp\generate_clamscan.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_clamscan.wsb"
Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_clamscan.wsb" -WaitForPath "${ROOT_PATH}\log\clamscan_done"

if (Test-Path -Path "${ROOT_PATH}\log\run_yarascan") {
    Remove-Item "${ROOT_PATH}\log\run_yarascan" | Out-Null
}

Write-DateLog "ClamAV and YARA scans done." >> "${ROOT_PATH}\log\clamscan.txt"
