. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-Output "" > "${ROOT_PATH}\log\verify.txt"
Write-SynchronizedLog "Verify installed tools."

if (Test-Path -Path "${ROOT_PATH}\log\verify_done" ) {
    Remove-Item -Force "${ROOT_PATH}\log\verify_done" | Out-Null
}

(Get-Content ${ROOT_PATH}\resources\templates\generate_verify.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}/") | Set-Content "${ROOT_PATH}\tmp\generate_verify.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_verify.wsb"
Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_verify.wsb" -WaitForPath "${ROOT_PATH}\log\verify_done"

Write-SynchronizedLog "Verify done."
