param (
    [String] $ScriptRoot=$PSScriptRoot
)

${ScriptRoot} = "${ScriptRoot}\resources\download"
${ROOT_PATH} = Resolve-Path "${ScriptRoot}\..\..\"

. "${ScriptRoot}\common.ps1"

Write-DateLog "Start Sandbox to install or update TI for LogBoost." > "${ROOT_PATH}\log\logboost.txt"

$mutex = New-Object System.Threading.Mutex($false, $mutexName)


if (Test-Path -Path "${ROOT_PATH}\mount\Tools\logboost" ) {
    (Get-Content "${ROOT_PATH}\resources\templates\generate_logboost.wsb.template").replace("__SANDBOX__", "${ROOT_PATH}") | Set-Content "${ROOT_PATH}\tmp\generate_logboost.wsb"

    $mutex.WaitOne() | Out-Null
    & "${ROOT_PATH}\tmp\generate_logboost.wsb"
    Start-Sleep 10
    Remove-Item "${ROOT_PATH}\tmp\generate_logboost.wsb" | Out-Null

    Stop-SandboxWhenDone "${ROOT_PATH}\mount\Tools\logboost\done" $mutex | Out-Null

    Write-DateLog "Logboost done." >> "${ROOT_PATH}\log\logboost.txt"
} else {
    Write-DateLog "Logboost directory not available." >> "${ROOT_PATH}\log\logboost.txt"
}