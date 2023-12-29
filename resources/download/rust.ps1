param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
$ROOT_PATH = Resolve-Path "$ScriptRoot\..\..\"

. $ScriptRoot\common.ps1

Write-DateLog "Start Sandbox to install Rust based tools for dfirws." > $ROOT_PATH\log\python.txt

$mutex = New-Object System.Threading.Mutex($false, $mutexName)

if (! (Test-Path -Path $ROOT_PATH\tmp\cargo )) {
    New-Item -ItemType Directory -Force -Path $ROOT_PATH\tmp\cargo > $null
}

if (! (Test-Path -Path $ROOT_PATH\mount\Tools\cargo )) {
    New-Item -ItemType Directory -Force -Path $ROOT_PATH\mount\Tools\cargo > $null
}

if (Test-Path -Path $ROOT_PATH\tmp\cargo\done ) {
    Remove-Item $ROOT_PATH\tmp\cargo\done > $null
}

(Get-Content $ROOT_PATH\resources\templates\generate_rust.wsb.template).replace('__SANDBOX__', $ROOT_PATH) | Set-Content $ROOT_PATH\tmp\generate_rust.wsb

$mutex.WaitOne() | Out-Null
& $ROOT_PATH\tmp\generate_rust.wsb
Start-Sleep 10
Remove-Item $ROOT_PATH\tmp\generate_rust.wsb | Out-Null

Stop-SandboxWhenDone "$ROOT_PATH\tmp\cargo\done" $mutex | Out-Null

rclone.exe sync --verbose --checksum "$ROOT_PATH\tmp\cargo" "$ROOT_PATH\mount\Tools\cargo"
Remove-Item -Recurse -Force "$ROOT_PATH\tmp\cargo" > $null 2>&1

Write-DateLog "Rust tools done."