. ".\resources\download\common.ps1"

$ROOT_PATH = "${PWD}"
$node_packages = @("box-js", "deobfuscator", "docsify-cli", "jsdom")

Write-DateLog "Setup Node and install npm packages in Sandbox." > ${ROOT_PATH}\log\npm.txt

# Create directories for Node and npm packages.
if ( Test-Path -Path "${ROOT_PATH}\tmp\node" ) {
    Remove-Item -r -Force "${ROOT_PATH}\tmp\node"
} elseif ( Test-Path -Path "${ROOT_PATH}\tmp\node\node.txt" ) {
    Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\node\node.txt" 2>&1 | Out-Null
}
New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\node" | Out-Null
if (! (Test-Path -Path "${ROOT_PATH}\mount\Tools\node" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\node" | Out-Null
}
New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\tmp\Lumen" | Out-Null
if (! (Test-Path -Path "${ROOT_PATH}\mount\Tools\Lumen" )) {
    New-Item -ItemType Directory -Force -Path "${ROOT_PATH}\mount\Tools\Lumen" | Out-Null
}

# Check if we have installed packages before.
if (Test-Path -Path "${ROOT_PATH}\mount\Tools\node\node.txt" ) {
    ${CURRENT} = "${ROOT_PATH}\mount\Tools\node\node.txt"
} else {
    ${CURRENT} = "${ROOT_PATH}\README.md"
}

# Get latest versions of npm packages.
foreach ($package in $node_packages) {
    (curl -L --silent https://registry.npmjs.org/$package | ConvertFrom-Json).'dist-tags'[0].latest >> ${ROOT_PATH}\tmp\node\node.txt
}

# Get latest LUMEN release url without downloading.
Get-GitHubRelease Koifman/LUMEN "dummy" "." -download $false >> ${ROOT_PATH}\tmp\node\node.txt

if ((Get-FileHash "${ROOT_PATH}\tmp\node\node.txt").Hash -ne (Get-FileHash ${CURRENT}).Hash) {
    (Get-Content ${ROOT_PATH}\resources\templates\generate_node.wsb.template).replace('__SANDBOX__', "${ROOT_PATH}\") | Set-Content "${ROOT_PATH}\tmp\generate_node.wsb"
    Start-Process "${ROOT_PATH}\tmp\generate_node.wsb"
    Wait-Sandbox -WSBPath "${ROOT_PATH}\tmp\generate_node.wsb" -WaitForPath "${ROOT_PATH}\tmp\node\done"

    rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\node" "${ROOT_PATH}\mount\Tools\node" >> ${ROOT_PATH}\log\npm.txt 2>&1
    rclone.exe sync --verbose --checksum "${ROOT_PATH}\tmp\Lumen" "${ROOT_PATH}\mount\Tools\Lumen" >> ${ROOT_PATH}\log\npm.txt 2>&1
    Write-DateLog "Node and npm packages done." >> ${ROOT_PATH}\log\npm.txt 2>&1
} else {
    Write-DateLog "Node and npm packages already installed and up to date." >> ${ROOT_PATH}\log\npm.txt 2>&1
}

Remove-Item -Recurse -Force "${ROOT_PATH}\tmp\node" 2>&1 | Out-Null
