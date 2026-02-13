. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

$ROOT_PATH = "${PWD}"
$node_packages = @("box-js", "deobfuscator", "docsify-cli", "jsdom", "@marp-team/marp-cli")

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

# TODO: Move TOOL_DEFINITIONS to setup/install/install_node.ps1 and add more entries for other Node.js based tools

$TOOL_DEFINITIONS += @{
    Name = "box-js"
    Category = "Files and apps\JavaScript"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\JavaScript\box-js (is a utility to analyze malicious JavaScript files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command box-js --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Node"
    Verify = @()
    FileExtensions = @(".js")
    Tags = @("malware-analysis", "javascript", "dynamic-analysis", "deobfuscation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "deobfuscator"
    Category = "Files and apps\JavaScript"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\JavaScript\deobfuscator (synchrony).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command synchrony --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Node"
    Verify = @()
    FileExtensions = @(".js")
    Tags = @("javascript", "deobfuscation", "malware-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "docsify-cli"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Node"
    Verify = @()
    FileExtensions = @(".md", ".html")
    Tags = @("documentation", "markdown")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jsdom"
    Category = "Files and apps\JavaScript"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\JavaScript\jsdom (opens README in Notepad++).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command notepad++.exe C:\Tools\node\node_modules\jsdom\README.md"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Node"
    Verify = @()
    FileExtensions = @(".html", ".htm", ".js")
    Tags = @("javascript", "html-parsing", "dom")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "LUMEN"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\Lumen (Browser-based EVTX Companion).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command `${HOME}\Documents\tools\utils\lumen.ps1"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Node"
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("log-analysis", "event-log", "forensics", "visualization")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}
