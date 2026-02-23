. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Start Sandbox to install general tools for dfirws." > "${ROOT_PATH}\log\general.txt"

if (Test-Path -Path "${ROOT_PATH}\log\general_done") {
    Remove-Item "${ROOT_PATH}\log\general_done" | Out-Null
}

(Get-Content "${ROOT_PATH}\resources\templates\generate_general.wsb.template").replace("__SANDBOX__", "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_general.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_general.wsb"
Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_general.wsb" -WaitForPath "${ROOT_PATH}\log\general_done"

Write-DateLog "General sandbox tools done." >> "${ROOT_PATH}\log\general.txt"
