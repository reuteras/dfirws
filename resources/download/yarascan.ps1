. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to run YARA scan." > "${ROOT_PATH}\log\yarascan.txt"

if (Test-Path -Path "${ROOT_PATH}\log\yarascan_done") {
    Remove-Item "${ROOT_PATH}\log\yarascan_done" | Out-Null
}

(Get-Content ${ROOT_PATH}\resources\templates\generate_yarascan.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}/") | Set-Content "${ROOT_PATH}\tmp\generate_yarascan.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_yarascan.wsb"
Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_yarascan.wsb" -WaitForPath "${ROOT_PATH}\log\yarascan_done"

Write-DateLog "YARA scan done." >> "${ROOT_PATH}\log\yarascan.txt"
