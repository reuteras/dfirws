param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
$ROOT_PATH = Resolve-Path "$ScriptRoot\..\..\"

. "${ScriptRoot}\common.ps1"

Write-Output "" > "${ROOT_PATH}\log\verify.txt"

Write-SynchronizedLog "Verify installed tools."
Write-SynchronizedLog ""

if (! (Test-Path -Path "${ROOT_PATH}\log\verify_done" )) {
    Remove-Item -Force "${ROOT_PATH}\log\verify_done" | Out-Null
}

$mutex = New-Object System.Threading.Mutex($false, $mutexName)

(Get-Content ${ROOT_PATH}\resources\templates\generate_verify.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}") | Set-Content "${ROOT_PATH}\tmp\generate_verify.wsb"

$mutex.WaitOne() | Out-Null
& "${ROOT_PATH}\tmp\generate_verify.wsb"
Start-Sleep 10
Remove-Item "${ROOT_PATH}\tmp\generate_verify.wsb"

Stop-SandboxWhenDone "${ROOT_PATH}\log\verify_done" ${mutex}

Write-SynchronizedLog "Verify done."
