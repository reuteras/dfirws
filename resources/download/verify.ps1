. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-Output "" > "${ROOT_PATH}\log\verify.txt"

Write-SynchronizedLog "Verify installed tools."

if (Test-Path -Path "${ROOT_PATH}\log\verify_done" ) {
    Remove-Item -Force "${ROOT_PATH}\log\verify_done" | Out-Null
}

(Get-Content ${ROOT_PATH}\resources\templates\generate_verify.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}/") | Set-Content "${ROOT_PATH}\tmp\generate_verify.wsb"
Start-Process "${ROOT_PATH}\tmp\generate_verify.wsb"


do {
    Start-Sleep 10
    if (Test-Path -Path "${ROOT_PATH}\log\verify_done" ) {
        Stop-Sandbox
        Remove-Item "${ROOT_PATH}\tmp\generate_verify.wsb" | Out-Null
        Remove-Item "${ROOT_PATH}\log\verify_done" | Out-Null
        Start-Sleep 1
    }
} while (
    tasklist | Select-String "(WindowsSandboxClient|WindowsSandboxRemote)"
)

Write-SynchronizedLog "Verify done."
