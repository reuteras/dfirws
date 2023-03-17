param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
$ROOT_PATH = Resolve-Path "$ScriptRoot\..\..\"

Write-Output "Download Python pip packages." > $ROOT_PATH\log\python.txt

. $ScriptRoot\common.ps1

while(Get-Sandbox) {
    Write-Output "Waiting for Sandbox to exit." >> $ROOT_PATH\log\python.txt
    Start-Sleep 1
}

if (Test-Path -Path $ROOT_PATH\tmp\pip ) {
    Remove-Item -r -Force $ROOT_PATH\tmp\pip
}

if (! (Test-Path -Path $ROOT_PATH\tmp\venv )) {
    New-Item -ItemType Directory -Force -Path $ROOT_PATH\tmp\venv > $null
}

if (Test-Path -Path $ROOT_PATH\tmp\venv\done ) {
    Remove-Item $ROOT_PATH\tmp\venv\done > $null
}

New-Item -ItemType Directory -Force -Path $ROOT_PATH\tmp\pip > $null

(Get-Content $ROOT_PATH\generate_venv.wsb.template).replace('__SANDBOX__', $ROOT_PATH) | Set-Content $ROOT_PATH\generate_venv.wsb
& $ROOT_PATH\generate_venv.wsb
Start-Sleep 10
Remove-Item $ROOT_PATH\generate_venv.wsb

Stop-SandboxWhenDone "$ROOT_PATH\tmp\venv\done"
Write-Output "Pip packages done."