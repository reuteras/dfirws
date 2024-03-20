param (
    [String] $ScriptRoot=$PSScriptRoot
)

${ScriptRoot} = "${ScriptRoot}\resources\download"
${ROOT_PATH} = Resolve-Path "${ScriptRoot}\..\..\"

. "${ScriptRoot}\common.ps1"

Write-DateLog "Start Sandbox to install ClamAV and run freshclam." > "${ROOT_PATH}\log\freshclam.txt"

$mutex = New-Object System.Threading.Mutex($false, ${mutexName})

if (! (Test-Path -Path "${ROOT_PATH}\mount\Tools\ClamAV   ")) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\ClamAV" | Out-Null
}

if (Test-Path -Path "${ROOT_PATH}\mount\Tools\ClamAV\done") {
    Remove-Item "${ROOT_PATH}\mount\Tools\ClamAV\done" | Out-Null
}

(Get-Content ${ROOT_PATH}\resources\templates\generate_freshclam.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}") | Set-Content "${ROOT_PATH}\tmp\generate_freshclam.wsb"

$mutex.WaitOne() | Out-Null
& "${ROOT_PATH}\tmp\generate_freshclam.wsb"
Start-Sleep 10
Remove-Item "${ROOT_PATH}\tmp\generate_freshclam.wsb" | Out-Null

Stop-SandboxWhenDone "${ROOT_PATH}\mount\Tools\ClamAV\done" $mutex | Out-Null

Write-DateLog "Freshclam update done." >> "${ROOT_PATH}\log\freshclam.txt"