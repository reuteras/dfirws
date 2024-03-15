<#

.SYNOPSIS
    Download files and prepare the sandbox.

.DESCRIPTION
    This script downloads files and prepares the sandbox for DFIRWS.

.EXAMPLE
    .\downloadFiles.ps1
    This will download all files needed for DFIRWS.

.EXAMPLE
    .\downloadFiles.ps1 -Python
    This will download or update packages for Python.

.NOTES
    File Name      : downloadFiles.ps1
    Author         : Peter R

.LINK
    https://github.com/reuteras/dfirws
#>

param(
    [Parameter(HelpMessage = "Download all tools for dfirws.")]
    [Switch]$AllTools,
    [Parameter(HelpMessage = "Update Bash.")]
    [Switch]$Bash,
    [Parameter(HelpMessage = "Update Didier Stevens tools.")]
    [Switch]$Didier,
    [Parameter(HelpMessage = "Update enrichment.")]
    [Switch]$Enrichment,
    [Parameter(HelpMessage = "Update git repositories.")]
    [Switch]$Git,
    [Parameter(HelpMessage = "Update files downloaded via HTTP.")]
    [Switch]$Http,
    [Parameter(HelpMessage = "Don't update Visual Studio Code Extensions via http.")]
    [Switch]$HttpNoVSCodeExtensions,
    [Parameter(HelpMessage = "Update KAPE.")]
    [Switch]$Kape,
    [Parameter(HelpMessage = "Update Node.")]
    [Switch]$Node,
    [Parameter(HelpMessage = "Update PowerShell and modules.")]
    [Switch]$PowerShell,
    [Parameter(HelpMessage = "Update Python.")]
    [Switch]$Python,
    [Parameter(HelpMessage = "Update releases from GitHub.")]
    [Switch]$Release,
    [Parameter(HelpMessage = "Update Rust.")]
    [Switch]$Rust,
    [Parameter(HelpMessage = "Update tools downloaded via winget.")]
    [Switch]$Winget,
    [Parameter(HelpMessage = "Update Zimmerman tools.")]
    [Switch]$Zimmerman
    )

if (Test-Path ".\resources\download\common.ps1") {
    . ".\resources\download\common.ps1"
} else {
    Write-DateLog "Error: common.ps1 not found. Please check your installation."
    Exit
}

if (Test-Path ".\config.ps1") {
    . ".\config.ps1"
} elseif (Test-Path ".\config.ps1.template") {
    . ".\config.ps1.template"
} else {
    Write-DateLog "Error: Neither config.ps1 nor config.ps1.template found. Please check your installation."
    Exit
}

# Ensure that we have the necessary tools installed
if (! (Get-Command "git.exe" -ErrorAction SilentlyContinue)) {
    Write-DateLog "Error: git.exe not found. Please install Git for Windows and add it to PATH."
    Exit
}

if (! (Get-Command "rclone.exe" -ErrorAction SilentlyContinue)) {
    Write-DateLog "Error: rclone.exe not found. Please install rclone and add it to PATH."
    Exit
}

if (! (Get-Command "7z.exe" -ErrorAction SilentlyContinue)) {
    Write-DateLog "Error: 7z.exe not found. Please install 7-Zip and add it to PATH."
    Exit
}

# Ensure configuration exists for rclone
rclone.exe config touch | Out-Null

# Check if sandbox is running
if ( tasklist | Select-String "WindowsSandbox" ) {
    Write-DateLog "Sandbox can't be running during install or upgrade."
    Exit
}

if ($Bash.IsPresent -or $Didier.IsPresent -or $Enrichment.IsPresent -or $Git.IsPresent -or $Http.IsPresent -or $Kape.IsPresent -or $Node.IsPresent -or $PowerShell.IsPresent -or $Python.IsPresent -or $Release.IsPresent -or $Rust.IsPresent -or $Winget.IsPresent -or $Zimmerman.IsPresent) {
    $all = $false
} else {
    Write-DateLog "No arguments given. Will download all tools for dfirws."
    $all = $true
}

if ($AllTools.IsPresent) {
    Write-DateLog "Download all tools for dfirws."
    $all = $true
}

if ($all -eq $false) {
    if (! (Test-Path "${TOOLS}\bin" )) {
        Write-DateLog "No tools directory found. You have to run this script without arguments first."
        Exit
    }
}

# Remove old temp files
Remove-Item -Recurse -Force .\tmp\downloads\ 2>&1 | Out-Null

# Create directories
if (!(Test-Path "${SETUP_PATH}")) {
    New-Item -ItemType Directory -Force -Path "${SETUP_PATH}" 2>&1 | Out-Null
}

if (!(Test-Path "${SETUP_PATH}\.etag")) {
    New-Item -ItemType Directory -Force -Path "${SETUP_PATH}\.etag" 2>&1 | Out-Null
}

if (!(Test-Path "${TOOLS}")) {
    New-Item -ItemType Directory -Force -Path "${TOOLS}" 2>&1 | Out-Null
}

if (!(Test-Path "${TOOLS}\bin")) {
    New-Item -ItemType Directory -Force -Path "${TOOLS}\bin" 2>&1 | Out-Null
}

if (!(Test-Path "${TOOLS}\lib")) {
    New-Item -ItemType Directory -Force -Path "${TOOLS}\lib" 2>&1 | Out-Null
}

if (!(Test-Path "${TOOLS}\Zimmerman")) {
    New-Item -ItemType Directory -Force -Path "${TOOLS}\Zimmerman" 2>&1 | Out-Null
}

if (! (Test-Path -Path ".\log" )) {
    New-Item -ItemType Directory -Force -Path ".\log" > $null
}
Get-Date > ".\log\log.txt"
Get-Date > ".\log\jobs.txt"

# Moved file to downloads
if (Test-Path ".\tools_downloaded.csv") {
    Move-Item -Path ".\tools_downloaded.csv" -Destination ".\downloads\tools_downloaded.csv" -Force
}

if ($all -or $Bash -or $Didier -or $Http -or $Python -or $Release) {
    # Get GitHub password from user input
    if ($GITHUB_USERNAME -ne "YOUR GITHUB USERNAME" -and $GITHUB_TOKEN -ne "YOUR GITHUB TOKEN") {
        $GH_USER = "${GITHUB_USERNAME}"
        $GH_PASS = "${GITHUB_TOKEN}"
    } else {
        Write-DateLog "Use GitHub username and token to avoid problems with rate limits on GitHub."
        $GH_USER = Read-Host "Enter GitHub user name"
        $PASS = Read-Host "Enter GitHub token" -AsSecureString
        $GH_PASS =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PASS))
        $null = $GH_PASS
        $null = $GH_USER
    }
}

if ($all -or $Bash -or $Node -or $Python -or $Rust) {
    Write-DateLog "Download files needed in Sandboxes."
    .\resources\download\basic.ps1
}

if ($all -or $Bash) {
    Write-DateLog "Download packages for Git for Windows (Bash)."
    Start-Job -FilePath .\resources\download\bash.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList ${PSScriptRoot} | Out-Null
}

if ($all -or $Node) {
    Write-DateLog "Setup Node and install npm packages."
    Start-Job -FilePath .\resources\download\node.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList ${PSScriptRoot} | Out-Null
}

if ($all -or $Release) {
    Write-DateLog "Download releases from GitHub."
    .\resources\download\release.ps1
}

if ($all -or $Git) {
    Write-DateLog "Download git repositories"
    .\resources\download\git.ps1
}

if ($all -or $Python) {
    Write-Output "" > .\log\python.txt
    Write-DateLog "Setup Python and install packages."
    Start-Job -FilePath .\resources\download\python.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList ${PSScriptRoot} | Out-Null
}

if ($all -or $Rust) {
    Write-Output "" > .\log\rust.txt
    Write-DateLog "Setup Rust and install packages."
    Start-Job -FilePath .\resources\download\rust.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList ${PSScriptRoot} | Out-Null
}

if ($all -or $Http) {
    Write-DateLog "Download files via HTTP."
    $HTTP_ARGS = ""
    if ($HttpNoVSCodeExtensions) {
        $HTTP_ARGS += "-NoVSCodeExtensions "
    }
    powershell -noprofile .\resources\download\http.ps1 $HTTP_ARGS
}

if ($all -or $Didier) {
    Write-DateLog "Download Didier Stevens tools."
    .\resources\download\didier.ps1
}

if ($all -or $Winget) {
    Write-DateLog "Download tools via winget."
    .\resources\download\winget.ps1
}

if ($all -or $Zimmerman) {
    Write-DateLog "Download Zimmerman tools."
    .\resources\download\zimmerman.ps1
}

if ($all -or $Kape) {
    if (Test-Path ".\local\kape.zip") {
        Write-DateLog "Download KAPE."
        .\resources\download\kape.ps1
    }
}

if ($all -or $PowerShell) {
    Write-DateLog "Download PowerShell and modules."
    .\resources\download\powershell.ps1
}

if ($Enrichment.IsPresent) {
    Write-DateLog "Download enrichment data."
    .\resources\download\enrichment.ps1
}

if ($all -or $bash -or $Node -or $Python -or $Rust) {
    Write-DateLog "Wait for sandboxes."
    Get-Job | Wait-Job | Out-Null
    Get-Job | Receive-Job 2>&1 >> ".\log\jobs.txt"
    Get-Job | Remove-Job | Out-Null
    Write-DateLog "Sandboxes done."
}

Copy-Item "README.md" ".\downloads\" -Force
Copy-Item ".\resources\images\dfirws.jpg" .\downloads\ -Force
Copy-Item ".\setup\utils\PowerSiem.ps1" ".\mount\Tools\bin\" -Force
foreach ($directory in (Get-ChildItem ".\mount\Tools\Ghidra\" -Directory).Name | findstr PUBLIC) {
    Copy-Item ".\mount\git\CapaExplorer\capaexplorer.py" ".\mount\Tools\Ghidra\${directory}\Ghidra\Features\Python\ghidra_scripts" -Force
}
# done.txt is used to check last update in sandbox
Write-Output "" > ".\downloads\done.txt"

# Remove temp files
Remove-Item -Recurse -Force .\tmp\downloads\ 2>&1 | Out-Null
Remove-Item -Recurse -Force .\tmp\enrichment 2>&1 | Out-Null
Remove-Item -Recurse -Force .\tmp\mount\ 2>&1 | Out-Null

$warnings = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "warning" | Where-Object {
    $_.Line -notmatch " INFO " -and
    $_.Line -notmatch "This is taking longer than usual" -and
    $_.Line -notmatch "Installing collected packages" -and
    $_.Line -notmatch "pymispwarninglists" -and
    $_.Line -notmatch "warning: be sure to add"
}

$errors = Get-ChildItem .\log\* -Recurse | Select-String -Pattern "error" | Where-Object {
    $_.Line -notmatch "Error: no test specified" -and
    $_.Line -notmatch "pretty.errors" -and
    $_.Line -notmatch "Copied (replaced existing)" -and
    $_.Line -notmatch "INFO" -and
    $_.Line -notmatch "Downloaded " -and
    $_.Line -notmatch "/cffi/error.py" -and
    $_.Line -notmatch "github/workflows" -and
    $_.Line -notmatch " Compiling "
}

if ($warnings -or $errors) {
    Write-DateLog "Errors or warnings were found in log files. Please check the log files for details."
} else {
    Write-DateLog "Downloads and preparations done."
}
