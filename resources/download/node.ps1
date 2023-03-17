param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
$ROOT_PATH=Resolve-Path "$ScriptRoot\..\..\"

Write-Output "Setup node and install npm packages." > $ROOT_PATH\log\npm.txt

. $ScriptRoot\common.ps1

while(Get-Sandbox) {
    Write-Output "Waiting for Sandbox to exit." > $ROOT_PATH\log\npm.txt
    Start-Sleep 1 
}

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

(Get-Content $ROOT_PATH\generate_node.wsb.template).replace('__SANDBOX__', "$ROOT_PATH") | Set-Content "$ROOT_PATH\generate_node.wsb"
& "$ROOT_PATH\generate_node.wsb"
Start-Sleep 10
Remove-Item "$ROOT_PATH\generate_node.wsb"

Stop-SandboxWhenDone "$ROOT_PATH\tmp\node\done"