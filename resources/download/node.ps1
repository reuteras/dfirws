param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
${ROOT_PATH} = Resolve-Path "$ScriptRoot\..\..\"

. $ScriptRoot\common.ps1

Write-DateLog "Setup Node and install npm packages in Sandbox." > ${ROOT_PATH}\log\npm.txt
Write-DateLog "" > ${ROOT_PATH}\log\npm.txt

$node_packages = @("box-js", "deobfuscator", "jsdom")

if (! (Test-Path -Path "${ROOT_PATH}\tmp" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp" | Out-Null
}

if ( Test-Path -Path "${ROOT_PATH}\tmp\node" ) {
    Remove-Item -r -Force "${ROOT_PATH}\tmp\node"
}

New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\node" | Out-Null

Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\node\node.txt" 2>&1 | Out-Null

foreach ($package in $node_packages) {
    (curl -L --silent https://registry.npmjs.org/$package | ConvertFrom-Json).'dist-tags'[0].latest >> ${ROOT_PATH}\tmp\node\node.txt
}

if (Test-Path -Path "${ROOT_PATH}\mount\Tools\node\node.txt" ) {
    ${CURRENT} = "${ROOT_PATH}\mount\Tools\node\node.txt"
} else {
    ${CURRENT} = "${ROOT_PATH}\README.md"
}

if ((Get-FileHash "${ROOT_PATH}\tmp\node\node.txt").Hash -ne (Get-FileHash ${CURRENT}).Hash) {
    $mutex = New-Object System.Threading.Mutex($false, $mutexName)

    if (! (Test-Path -Path "${ROOT_PATH}\mount\Tools\node" )) {
        New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\node" | Out-Null
    }

    (Get-Content ${ROOT_PATH}\resources\templates\generate_node.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}") | Set-Content "${ROOT_PATH}\tmp\generate_node.wsb"

    $mutex.WaitOne() | Out-Null
    & "${ROOT_PATH}\tmp\generate_node.wsb"
    Start-Sleep 10
    Remove-Item "${ROOT_PATH}\tmp\generate_node.wsb" | Out-Null

    Stop-SandboxWhenDone "${ROOT_PATH}\tmp\node\done" $mutex | Out-Null

    rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\node" "${ROOT_PATH}\mount\Tools\node"
    Write-DateLog "Node and npm packages done." >> ${ROOT_PATH}\log\npm.txt 2>&1
} else {
    Write-DateLog "Node and npm packages already installed and up to date." >> ${ROOT_PATH}\log\npm.txt 2>&1
}

Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\node" 2>&1 | Out-Null

