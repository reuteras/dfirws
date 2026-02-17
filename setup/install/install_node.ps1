$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"
. "C:\Users\WDAGUtilityAccount\Documents\tools\shared.ps1"

$TOOL_DEFINITIONS = @()

# This script runs in a Windows sandbox to install node tools.
Write-Output "Install Node.js."
Write-DateLog "Install npm packages" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
Write-DateLog "Install Git (in the background)." >> "C:\log\npm.txt"
Install-Git 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"

New-Item -ItemType Directory "${WSDFIR_TEMP}" 2>&1 | ForEach-Object{ "$_" } | Out-Null

Copy-Item "${SETUP_PATH}\7zip.msi" "${WSDFIR_TEMP}\7zip.msi"
Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\7zip.msi /qn /norestart"
Get-Job | Receive-Job

Write-Output "Get-Content C:\log\npm.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";C:\Tools\node"
&"${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\nodejs.zip" -o"${TOOLS}\node" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
Set-Location "${TOOLS}\node\node-*"
Move-Item * ..

Set-Location "${TOOLS}\node"
Remove-Item -r -Force node-v*
Write-DateLog "Init npm." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
npm init -y  | Out-String -Stream 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
Write-DateLog "Add npm packages" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
Write-DateLog "Install deobfuscator" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
npm install --global deobfuscator | Out-String -Stream 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
Write-DateLog "Install docsify" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
npm install --global docsify-cli | Out-String -Stream 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
Write-DateLog "Install jsdom" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
npm install --global jsdom | Out-String -Stream 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
Write-DateLog "Install box-js" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
npm install --global box-js | Out-String -Stream 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
Write-DateLog "Install Marp CLI" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
npm install --global @marp-team/marp-cli | Out-String -Stream 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
Write-DateLog "Install opencode-ai" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
npm install --global opencode-ai | Out-String -Stream 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"

if (Test-ToolIncludedSandbox -ToolName "LUMEN") {
    Set-Location "${HOME}"
    git clone --recurse-submodules https://github.com/Koifman/LUMEN.git 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
    Move-Item "${HOME}\LUMEN" "${TOOLS}\Lumen" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
    Set-Location "${TOOLS}\Lumen\LUMEN"
    npm install 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
    npm run build 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"
}

Write-DateLog "Node installation done." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\npm.txt"

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
    Notes = "A tool for studying JavaScript malware."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("nodejs")
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
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
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".js")
    Tags = @("javascript", "deobfuscation", "malware-analysis")
    Notes = "javascript-obfuscator cleaner & deobfuscator"
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("nodejs")
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "docsify-cli"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".md", ".html")
    Tags = @("documentation", "markdown")
    Notes = "A magical documentation generator."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("nodejs")
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
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
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".html", ".htm", ".js")
    Tags = @("javascript", "html-parsing", "dom")
    Notes = "jsdom is a pure-JavaScript implementation of many web standards, notably the WHATWG DOM and HTML Standards, for use with Node.js. In general, the goal of the project is to emulate enough of a subset of a web browser to be useful for testing and scraping real-world web applications."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("nodejs")
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
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
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("log-analysis", "event-log", "forensics", "visualization")
    Notes = "Your Browser-based EVTX Companion."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("nodejs")
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "@marp-team/marp-cli"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".md", ".markdown")
    Tags = @("markdown", "presentation", "documentation")
    Notes = "A CLI interface for Marp and Marpit based converters. Markdown presentations."
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("nodejs")
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "opencode-ai"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".txt", ".md", ".log", ".json")
    Tags = @("ai", "code-generation", "automation", "mcp")
    Notes = "AI coding agent for the terminal with MCP server support. Configured with MCP servers for Ghidra (GhidrAssistMCP), radare2 (r2mcp), and regipy."
    Tips = "MCP servers are disabled by default. Enable them in ~/.config/opencode/opencode.json or local/opencode.json. GhidrAssistMCP requires Ghidra to be running with the plugin enabled."
    Usage = "Run opencode in the terminal. MCP servers extend its capabilities for reverse engineering and registry analysis."
    SampleCommands = @(
        "opencode"
    )
    SampleFiles = @()
    Dependencies = @("nodejs")
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "node"

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > "${TOOLS}\node\done"
