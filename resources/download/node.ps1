param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
$ROOT_PATH = Resolve-Path "$ScriptRoot\..\..\"

. $ScriptRoot\common.ps1

Write-Output "Setup node and install npm packages in Sandbox." > $ROOT_PATH\log\npm.txt

$mutexName = "Global\dfirwsMutex"
$mutex = New-Object System.Threading.Mutex($false, $mutexName)

if (! (Test-Path -Path "$ROOT_PATH\tmp" )) {
    New-Item -ItemType Directory -Force -Path "$ROOT_PATH\tmp" > $null
}

if (! (Test-Path -Path "$ROOT_PATH\mount\Tools\node" )) {
    New-Item -ItemType Directory -Force -Path "$ROOT_PATH\mount\Tools\node" > $null
}

if ( Test-Path -Path "$ROOT_PATH\tmp\node" ) {
    Remove-Item -r -Force "$ROOT_PATH\tmp\node"
}

New-Item -ItemType Directory -Force -Path "$ROOT_PATH\tmp\node" > $null

(Get-Content $ROOT_PATH\resources\templates\generate_node.wsb.template).replace('__SANDBOX__', "$ROOT_PATH") | Set-Content "$ROOT_PATH\tmp\generate_node.wsb"

$mutex.WaitOne()
& "$ROOT_PATH\tmp\generate_node.wsb"
Start-Sleep 10
Remove-Item "$ROOT_PATH\tmp\generate_node.wsb"

Stop-SandboxWhenDone "$ROOT_PATH\tmp\node\done" $mutex
