. ".\resources\download\common.ps1"

${ROOT_PATH} = "${PWD}"

Write-DateLog "Start Sandbox to install or update TI for LogBoost." > "${ROOT_PATH}\log\logboost.txt"

if (Test-Path -Path "${ROOT_PATH}\mount\Tools\logboost" ) {
    (Get-Content "${ROOT_PATH}\resources\templates\generate_logboost.wsb.template").replace("__SANDBOX__", "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_logboost.wsb"
    Start-Process "${ROOT_PATH}\tmp\generate_logboost.wsb"
    Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_logboost.wsb" -WaitForPath "${ROOT_PATH}\mount\Tools\logboost\done"
    Write-DateLog "Logboost done." >> "${ROOT_PATH}\log\logboost.txt"
} else {
    Write-DateLog "Logboost directory not available." >> "${ROOT_PATH}\log\logboost.txt"
}