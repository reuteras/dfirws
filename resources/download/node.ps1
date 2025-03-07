. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Setup Node and install npm packages in Sandbox." > ${ROOT_PATH}\log\npm.txt

$node_packages = @("box-js", "deobfuscator", "docsify-cli", "jsdom")

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
    if (! (Test-Path -Path "${ROOT_PATH}\mount\Tools\node" )) {
        New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\node" | Out-Null
    }

    (Get-Content ${ROOT_PATH}\resources\templates\generate_node.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_node.wsb"
    Start-Process "${ROOT_PATH}\tmp\generate_node.wsb"
    
    do {
        Start-Sleep 10
        if (Test-Path -Path "${ROOT_PATH}\tmp\node\done" ) {
            Stop-Sandbox
            Remove-Item "${ROOT_PATH}\tmp\generate_node.wsb" | Out-Null
            Start-Sleep 1
        }
    } while (
        tasklist | Select-String "(WindowsSandboxClient|WindowsSandboxRemote)"
    )

    rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\node" "${ROOT_PATH}\mount\Tools\node" >> ${ROOT_PATH}\log\npm.txt 2>&1
    Write-DateLog "Node and npm packages done." >> ${ROOT_PATH}\log\npm.txt 2>&1
} else {
    Write-DateLog "Node and npm packages already installed and up to date." >> ${ROOT_PATH}\log\npm.txt 2>&1
}

Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\node" 2>&1 | Out-Null
