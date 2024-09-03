param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
${ROOT_PATH} = Resolve-Path "$ScriptRoot\..\..\"

. "${ScriptRoot}\common.ps1"

Write-DateLog "Setup MSYS2 and install packages in Sandbox." > ${ROOT_PATH}\log\msys2.txt

if (! (Test-Path -Path "${ROOT_PATH}\tmp" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp" | Out-Null
}

New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\msys64" | Out-Null

Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\msys64\msys2.txt" 2>&1 | Out-Null

$mutex = New-Object System.Threading.Mutex($false, $mutexName)

if (! (Test-Path -Path "${ROOT_PATH}\mount\msys64" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\msys64" | Out-Null
}

(Get-Content ${ROOT_PATH}\resources\templates\generate_msys2.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}") | Set-Content "${ROOT_PATH}\tmp\generate_msys2.wsb"

$mutex.WaitOne() | Out-Null
& "${ROOT_PATH}\tmp\generate_msys2.wsb"
Start-Sleep 10
Remove-Item "${ROOT_PATH}\tmp\generate_msys2.wsb" | Out-Null

Stop-SandboxWhenDone "${ROOT_PATH}\tmp\msys64\done" $mutex | Out-Null

rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\msys64" "${ROOT_PATH}\mount\msys64"
Write-DateLog "MSYS2 and packages done." >> ${ROOT_PATH}\log\msys2.txt 2>&1

Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\msys64" 2>&1 | Out-Null
